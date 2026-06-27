import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/services/ai/ai_feed_engine.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/widgets/ai/ai_feed_card.dart';
import 'package:raabta/widgets/ai/ai_loading_skeleton.dart';

class AIFeedSection extends ConsumerStatefulWidget {
  const AIFeedSection({super.key});

  @override
  ConsumerState<AIFeedSection> createState() => _AIFeedSectionState();
}

class _AIFeedSectionState extends ConsumerState<AIFeedSection> {
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
  );
  int _currentPage = 0;
  bool _loadAttempted = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  UserAIProfile? _resolveProfile() {
    return ref.read(userProfileAIServiceProvider).getCachedProfile() ??
        ref.read(userAIProfileProvider);
  }

  Future<void> _loadFeed() async {
    final profile = _resolveProfile();
    if (profile == null) return;
    await ref.read(aiFeedProvider.notifier).load(profile);
  }

  Future<void> _refreshFeed() async {
    final profile = _resolveProfile();
    if (profile == null) return;
    await ref.read(aiFeedProvider.notifier).refresh(profile);
  }

  void _ensureFeedLoaded() {
    if (_loadAttempted) return;
    _loadAttempted = true;
    _loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserAIProfile?>(userAIProfileProvider, (previous, next) {
      if (next != null && previous == null) {
        _loadAttempted = true;
        _loadFeed();
      }
    });

    final profile = ref.watch(userAIProfileProvider);
    final feedState = ref.watch(aiFeedProvider);
    final area = profile?.preferredArea ?? 'Al Khor';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profile != null) _ensureFeedLoaded();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🤖 Today\'s AI Insights', style: AppTextStyles.h2),
                  Text(
                    'Personalized for you in $area',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              GestureDetector(
                onTap: _refreshFeed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primary,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (profile == null)
          _buildEmpty()
        else
          feedState.when(
            loading: () => _buildSkeletons(),
            error: (_, _) => _buildError(),
            data: (result) {
              if (result.cards.isEmpty && !_loadAttempted) {
                return _buildSkeletons();
              }
              if (result.cards.isEmpty) return _buildEmpty();
              return _buildCards(result.cards);
            },
          ),
      ],
    );
  }

  Widget _buildCards(List<AIFeedCard> cards) {
    return Column(
      children: [
        SizedBox(
          height: 155,
          child: PageView.builder(
            controller: _pageController,
            itemCount: cards.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: AIFeedCardWidget(card: cards[index]),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            cards.length > 8 ? 8 : cards.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? cards[i].borderColor
                    : AppColors.textMuted,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletons() {
    return SizedBox(
      height: 155,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: 3,
        itemBuilder: (_, _) => Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: AILoadingSkeleton(
            width: 300,
            height: 140,
            borderRadius: AppRadius.xl,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Center(
        child: Column(
          children: [
            const Text('🤖', style: TextStyle(fontSize: 32)),
            const SizedBox(height: AppSpacing.sm),
            Text('No insights today.', style: AppTextStyles.bodyMedium),
            Text('Check back tomorrow.', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Could not load insights.',
              style: AppTextStyles.bodySmall,
            ),
          ),
          GestureDetector(
            onTap: _refreshFeed,
            child: Text('Retry', style: AppTextStyles.labelLarge),
          ),
        ],
      ),
    );
  }
}
