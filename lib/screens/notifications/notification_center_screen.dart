import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/providers/notification_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/notifications/l10n/notification_center_strings.dart';

/// Semantic accent for unread inbox items (design kit alert red).
@visibleForTesting
Color notificationCenterUnreadAccentColor() => AppColors.error;

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return GlassScreenScaffold(
      title: NotificationCenterStrings.t('center_title', locale),
      leading: GlassIconButton(
        icon: Icons.arrow_back,
        tooltip: CommonActionStrings.t('action_back', locale),
        onPressed: () => context.pop(),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final repo =
                await ref.read(notificationRepositoryProvider.future);
            await repo.markAllRead();
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brandFamilyText,
            minimumSize: const Size(48, 48),
          ),
          child: Text(
            NotificationCenterStrings.t('center_mark_all_read', locale),
            style: AppTypography.link.copyWith(
              color: AppColors.brandFamilyText,
            ),
          ),
        ),
      ],
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: GlassLoadingCard(height: 120, width: 240),
        ),
        error: (e, _) => Center(
          child: GlassErrorState(message: '$e'),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: GlassEmptyState(
                icon: Icons.notifications_outlined,
                title: NotificationCenterStrings.t('center_empty_title', locale),
                description: NotificationCenterStrings.t(
                  'center_empty_desc',
                  locale,
                ),
              ),
            );
          }

          final unreadCount =
              notifications.where((notification) => !notification.read).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (unreadCount > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        color: notificationCenterUnreadAccentColor()
                            .withValues(alpha: 0.12),
                        border: Border.all(
                          color: notificationCenterUnreadAccentColor()
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: notificationCenterUnreadAccentColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '$unreadCount',
                              style: AppTypography.caption.copyWith(
                                color: notificationCenterUnreadAccentColor(),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return _NotificationTile(notification: n);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = DateFormat('MMM d · HH:mm').format(notification.createdAt);
    final unread = !notification.read;
    final accent = notificationCenterUnreadAccentColor();

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: GlassContainer(
        borderRadius: AppSpacing.radiusMd,
        glowColor: AppColors.error,
        glowIntensity: 0.12,
        backgroundColor: AppColors.error.withValues(alpha: 0.12),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ),
      ),
      onDismissed: (_) async {
        final repo = await ref.read(notificationRepositoryProvider.future);
        await repo.deleteNotification(notification.id);
      },
      child: GlassCard(
        onTap: () async {
          final repo = await ref.read(notificationRepositoryProvider.future);
          await repo.markRead(notification.id);
          if (context.mounted) {
            context.push(
              ComplianceFlagsGate.resolveNotificationRoute(notification.route),
            );
          }
        },
        glowColor: unread ? accent : null,
        glowIntensity: unread ? 0.1 : 0,
        borderRadius: AppSpacing.radiusMd,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (unread)
                Container(
                  width: 3,
                  margin: const EdgeInsets.only(
                    right: AppSpacing.sm,
                    top: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              _NotificationTypeChip(type: notification.type),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight:
                            unread ? FontWeight.w800 : FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.body,
                      style: AppTypography.bodySmall.copyWith(
                        color: unread
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      time,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (unread) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  key: Key('notification_unread_dot_${notification.id}'),
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTypeChip extends StatelessWidget {
  const _NotificationTypeChip({required this.type});

  final NotificationType type;

  static const double _chipSize = 44;
  static const double _chipRadius = 14;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _chipSize,
      height: _chipSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_chipRadius),
        color: AppColors.brandFamilyMain.withValues(alpha: 0.2),
        border: Border.all(
          color: AppColors.brandFamilyMain.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        notificationTypeEmoji(type),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

/// Test hook — inbox tile without dismissible/repository wiring.
@visibleForTesting
Widget buildNotificationCenterTileForTest(AppNotification notification) {
  return _NotificationTile(notification: notification);
}
