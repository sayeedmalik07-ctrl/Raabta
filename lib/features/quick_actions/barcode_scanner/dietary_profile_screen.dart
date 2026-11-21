import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/providers/visa_providers.dart';

import 'l10n/food_inspector_strings.dart';
import 'models/dietary_profile.dart';

final dietaryProfileProvider =
    FutureProvider<DietaryProfile?>((ref) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection(DietaryProfile.firestoreCollection)
        .doc('current_user')
        .get();
    if (!doc.exists) return null;
    return DietaryProfile.fromFirestore(doc);
  } catch (_) {
    return null;
  }
});

class DietaryProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const DietaryProfileScreen({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<DietaryProfileScreen> createState() =>
      _DietaryProfileScreenState();
}

class _DietaryProfileScreenState extends ConsumerState<DietaryProfileScreen> {
  bool _halalRequired = false;
  DietType _dietType = DietType.noRestriction;
  bool _isSaving = false;
  final Set<String> _selectedAllergens = {};

  Future<void> _saveProfile() async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    setState(() {
      _isSaving = true;
    });
    try {
      final profile = DietaryProfile(
        allergies: _selectedAllergens.toList(),
        halalRequired: _halalRequired,
        dietType: _dietType,
        createdAt: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection(DietaryProfile.firestoreCollection)
          .doc('current_user')
          .set(profile.toFirestore());

      ref.invalidate(dietaryProfileProvider);
      widget.onComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              FoodInspectorStrings.format(
                'profile_save_error',
                locale,
                {'error': '$e'},
              ),
            ),
            backgroundColor: AppColors.errorBright,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));

    return GlassScreenScaffold(
      title: FoodInspectorStrings.t('profile_title', locale),
      actions: [
        TextButton(
          onPressed: widget.onComplete,
          child: Text(
            FoodInspectorStrings.t('profile_skip', locale),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
      padding: const EdgeInsets.all(20),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: 12,
              glowColor: AppColors.purpleGlow,
              glowIntensity: 0.1,
              backgroundColor: AppColors.purpleGlow.withValues(alpha: 0.08),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🧬', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      FoodInspectorStrings.t('profile_info', locale),
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textOnGlassSecondary
                            : Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _SectionTitle(
              '🕌  ${FoodInspectorStrings.t('profile_halal_section', locale)}',
            ),
            const SizedBox(height: 10),
            GlassContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              borderRadius: 14,
              glowColor: _halalRequired ? AppColors.success : null,
              glowIntensity: _halalRequired ? 0.1 : 0,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FoodInspectorStrings.t('profile_halal_toggle', locale),
                          style: TextStyle(
                            color: AppColors.isLight
                                ? AppColors.textPrimary
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          FoodInspectorStrings.t('profile_halal_hint', locale),
                          style: TextStyle(
                            color: AppColors.isLight
                                ? AppColors.textOnGlassMuted
                                : Colors.white.withValues(alpha: 0.35),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _halalRequired,
                    activeThumbColor: AppColors.successBright,
                    onChanged: (v) => setState(() => _halalRequired = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _SectionTitle(
              '🥗  ${FoodInspectorStrings.t('profile_diet_section', locale)}',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DietType.values.map((type) {
                final selected = _dietType == type;
                return GestureDetector(
                  onTap: () => setState(() => _dietType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.sharePurple
                          : AppColors.sharePurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.sharePurple
                            .withValues(alpha: selected ? 1.0 : 0.25),
                      ),
                    ),
                    child: Text(
                      FoodInspectorStrings.dietTypeLabel(type, locale),
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.sharePurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            _SectionTitle(
              '⚠️  ${FoodInspectorStrings.t('profile_allergen_section', locale)}',
            ),
            const SizedBox(height: 4),
            Text(
              FoodInspectorStrings.t('profile_allergen_hint', locale),
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassMuted
                    : Colors.white.withValues(alpha: 0.35),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FoodInspectorStrings.allergenStorageKeys.map((key) {
                final selected = _selectedAllergens.contains(key);
                final label = FoodInspectorStrings.allergenLabel(key, locale);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedAllergens.remove(key);
                    } else {
                      _selectedAllergens.add(key);
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.errorBright.withValues(alpha: 0.15)
                          : AppColors.isLight
                              ? AppColors.glassSurface
                              : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.errorBright.withValues(alpha: 0.5)
                            : AppColors.isLight
                                ? AppColors.glassBorder
                                : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          const Icon(
                            Icons.warning_rounded,
                            color: AppColors.errorBright,
                            size: 12,
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            color: selected
                                ? AppColors.errorBright
                                : AppColors.isLight
                                    ? AppColors.textOnGlassSecondary
                                    : Colors.white60,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),
            GlassPrimaryButton(
              label: FoodInspectorStrings.t('profile_save', locale),
              expand: true,
              accentColor: AppColors.sharePurple,
              icon: Icons.check_rounded,
              onPressed: _isSaving ? null : _saveProfile,
            ),
            if (_isSaving) ...[
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.isLight
                        ? AppColors.sharePurple
                        : Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Center(
              child: Text(
                FoodInspectorStrings.t('profile_settings_hint', locale),
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white.withValues(alpha: 0.25),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: AppColors.isLight
              ? AppColors.textPrimary
              : Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      );
}
