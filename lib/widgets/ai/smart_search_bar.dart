import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/services/ai/smart_search_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

const List<String> _searchHints = [
  'Find HSE jobs near Ras Laffan...',
  'Rooms in Al Khor under 1500 QR...',
  'Best Indian restaurants near me...',
  'How to renew my Iqama?',
  'Safety Officer jobs in Doha...',
  'Family flat in Al Khor 2BHK...',
  'Pakistani grocery near Industrial Area...',
  'Driver jobs in Qatar urgently...',
];

class SmartSearchBar extends ConsumerStatefulWidget {
  final Function(SmartSearchResult)? onSearchResult;
  final bool showSuggestions;
  final String? initialHint;

  const SmartSearchBar({
    super.key,
    this.onSearchResult,
    this.showSuggestions = true,
    this.initialHint,
  });

  @override
  ConsumerState<SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends ConsumerState<SmartSearchBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _hintIndex = 0;
  Timer? _hintTimer;

  List<String> _suggestions = [];
  bool _showDropdown = false;
  Timer? _debounceTimer;

  SmartSearchResult? _lastResult;
  bool _showResultBar = false;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeController.forward();

    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _startHintRotation();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _showDropdown = false);
      }
    });
  }

  void _startHintRotation() {
    _hintTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _fadeController.reverse();
      if (mounted) {
        setState(() {
          _hintIndex = (_hintIndex + 1) % _searchHints.length;
        });
      }
      if (mounted) await _fadeController.forward();
    });
  }

  String get _currentHint => widget.initialHint ?? _searchHints[_hintIndex];

  UserAIProfile? _resolveProfile() {
    return ref.read(userProfileAIServiceProvider).getCachedProfile() ??
        ref.read(userAIProfileProvider);
  }

  void _onTextChanged(String value) {
    if (!widget.showSuggestions) return;

    _debounceTimer?.cancel();

    if (value.isEmpty) {
      setState(() {
        _suggestions = [];
        _showDropdown = false;
        _showResultBar = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final profile = _resolveProfile();
      final searchService = ref.read(smartSearchServiceProvider);
      final suggestions = searchService.getSuggestions(value, profile);

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _showDropdown = suggestions.isNotEmpty;
        });
      }
    });
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;

    _focusNode.unfocus();
    _hintTimer?.cancel();

    final profile = _resolveProfile();
    final searchService = ref.read(smartSearchServiceProvider);
    final result = searchService.parseQuery(query, profile: profile);

    ref.read(userProfileAIServiceProvider).trackSearch(query);

    setState(() {
      _lastResult = result;
      _showDropdown = false;
      _showResultBar = result.confidence > 0.5;
    });

    if (result.confidence > 0.7) {
      _navigateToIntent(result);
    }

    widget.onSearchResult?.call(result);
  }

  void _navigateToIntent(SmartSearchResult result) {
    switch (result.intent) {
      case SearchIntent.findJob:
        context.push('/jobs');
      case SearchIntent.findHousing:
        context.push('/housing');
      case SearchIntent.findBusiness:
        context.push('/businesses');
      case SearchIntent.findDoctor:
        context.push('/doctors');
      case SearchIntent.checkRate:
        context.push('/money');
      case SearchIntent.visaQuestion:
        context.push('/visa');
      case SearchIntent.communityQuestion:
        context.push('/community');
      default:
        context.push('/ai-chat', extra: {'query': result.displayQuery});
    }
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    _onSearch(suggestion);
  }

  void _dismissResultBar() {
    setState(() => _showResultBar = false);
  }

  String _intentLabel(SearchIntent intent) {
    const labels = {
      SearchIntent.findJob: 'Jobs',
      SearchIntent.findHousing: 'Housing',
      SearchIntent.findBusiness: 'Businesses',
      SearchIntent.findDoctor: 'Doctors',
      SearchIntent.checkRate: 'Exchange Rates',
      SearchIntent.visaQuestion: 'Visa Guide',
      SearchIntent.communityQuestion: 'Community',
      SearchIntent.unknown: 'Results',
    };
    return labels[intent] ?? 'Results';
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _hintTimer?.cancel();
    _debounceTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.glassBorder,
              width: _focusNode.hasFocus ? 1.5 : 1,
            ),
            boxShadow: _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.search_rounded,
                color: _focusNode.hasFocus
                    ? AppColors.primary
                    : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: AppTextStyles.bodyMedium,
                  onChanged: _onTextChanged,
                  onSubmitted: _onSearch,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                    hintText:
                        _controller.text.isEmpty ? _currentHint : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 3),
                    Text(
                      'AI',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    setState(() {
                      _suggestions = [];
                      _showDropdown = false;
                      _showResultBar = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_showDropdown && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: _suggestions
                  .take(5)
                  .map((s) => _buildSuggestionTile(s))
                  .toList(),
            ),
          ),
        if (_showResultBar && _lastResult != null) _buildResultBar(),
      ],
    );
  }

  Widget _buildSuggestionTile(String suggestion) {
    return GestureDetector(
      onTap: () => _selectSuggestion(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.glassBorder, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.textMuted, size: 14),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(suggestion, style: AppTextStyles.bodyMedium),
            ),
            Icon(Icons.north_west_rounded, color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBar() {
    final result = _lastResult!;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Text('🤖', style: TextStyle(fontSize: 13)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Showing ${_intentLabel(result.intent)} · "${result.displayQuery}"',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: _dismissResultBar,
            child: Icon(
              Icons.close_rounded,
              color: AppColors.textMuted,
              size: 15,
            ),
          ),
        ],
      ),
    );
  }
}
