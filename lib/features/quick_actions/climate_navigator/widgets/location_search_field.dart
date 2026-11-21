import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_primitives.dart';

import '../services/location_search_service.dart';

class LocationSearchField extends StatefulWidget {
  final String label;
  final String hint;
  final Color iconColor;
  final IconData prefixIcon;
  final String initialValue;
  final String locale;
  final Function(String) onLocationSelected;

  const LocationSearchField({
    super.key,
    required this.label,
    required this.hint,
    required this.iconColor,
    required this.prefixIcon,
    required this.initialValue,
    required this.onLocationSelected,
    this.locale = 'English',
  });

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  late TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = [];
  bool _showDropdown = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _focus.addListener(() {
      if (mounted) setState(() {});
      if (!_focus.hasFocus) {
        setState(() => _showDropdown = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant LocationSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != _ctrl.text) {
      _ctrl.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    widget.onLocationSelected(value);
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _showDropdown = false;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final results = await LocationSearchService.autocomplete(
        value,
        locale: widget.locale,
      );
      if (mounted) {
        setState(() {
          _suggestions = results;
          _showDropdown = results.isNotEmpty;
          _isSearching = false;
        });
      }
    });
  }

  void _selectSuggestion(PlaceSuggestion suggestion) {
    climateSelectionHaptic();
    _ctrl.text = suggestion.fullText;
    setState(() {
      _showDropdown = false;
      _suggestions = [];
    });
    _focus.unfocus();
    widget.onLocationSelected(suggestion.fullText);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Text(
            widget.label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnGlassSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: AppSpacing.radiusSm,
          glowColor: _focus.hasFocus ? widget.iconColor : null,
          glowIntensity: _focus.hasFocus ? 0.12 : 0,
          child: TextField(
            controller: _ctrl,
            focusNode: _focus,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
            onChanged: _onChanged,
            onTap: () {
              if (_ctrl.text.trim().length >= 2) {
                setState(() => _showDropdown = _suggestions.isNotEmpty);
              }
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.bodySmall.copyWith(
                color: AppColors.textOnGlassMuted,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: widget.iconColor,
                size: AppSpacing.iconSm,
              ),
              suffixIcon: _isSearching
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.iconColor,
                        ),
                      ),
                    )
                  : _ctrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.textOnGlassMuted,
                            size: 16,
                          ),
                          onPressed: () {
                            _ctrl.clear();
                            setState(() {
                              _suggestions = [];
                              _showDropdown = false;
                            });
                            widget.onLocationSelected('');
                          },
                        )
                      : null,
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                borderSide: BorderSide(
                  color: AppColors.glassBorder.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                borderSide: BorderSide(
                  color: widget.iconColor,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
        if (_showDropdown && _suggestions.isNotEmpty)
          GlassContainer(
            margin: const EdgeInsets.only(top: AppSpacing.xs),
            padding: EdgeInsets.zero,
            borderRadius: AppSpacing.radiusSm,
            backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.98),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _suggestions.take(6).map((s) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectSuggestion(s),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.glassBorder.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: widget.iconColor.withValues(alpha: 0.7),
                              size: 15,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.mainText,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (s.secondaryText.isNotEmpty)
                                    Text(
                                      s.secondaryText,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textOnGlassMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
