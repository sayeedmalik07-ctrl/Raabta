import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/classifieds_chat_safety_strings.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/providers/classifieds_chat_safety_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/profile_tab_scaffold.dart';

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final blockedAsync = ref.watch(blockedUsersListProvider);

    return ProfileTabScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            ClassifiedsChatSafetyStrings.t('blocked_users_title', locale),
            style: AppTypography.headline2,
          ),
        ),
        body: blockedAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.cyanGlow),
          ),
          error: (_, __) => Center(
            child: Text(
              CommonActionStrings.t('action_retry', locale),
              style: AppTypography.body,
            ),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    ClassifiedsChatSafetyStrings.t(
                      'blocked_users_empty',
                      locale,
                    ),
                    style: AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final shortUid = entry.blockedUid.length > 12
                    ? '${entry.blockedUid.substring(0, 6)}…${entry.blockedUid.substring(entry.blockedUid.length - 4)}'
                    : entry.blockedUid;

                return GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ClassifiedsChatSafetyStrings.format(
                                'blocked_user_row_label',
                                locale,
                                params: {'uid': shortUid},
                              ),
                              style: AppTypography.bodySmall,
                            ),
                            if (entry.createdAt != null)
                              Text(
                                entry.createdAt!.toLocal().toString(),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(blockUserRepositoryProvider)
                              .unblockUser(entry.blockedUid);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ClassifiedsChatSafetyStrings.t(
                                  'unblock_success',
                                  locale,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          ClassifiedsChatSafetyStrings.t(
                            'unblock_action',
                            locale,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
