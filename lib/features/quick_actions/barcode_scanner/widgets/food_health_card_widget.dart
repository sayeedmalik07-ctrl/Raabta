import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';

import '../l10n/food_inspector_strings.dart';
import '../models/food_health_card.dart';
import 'allergy_warning_banner.dart';
import 'food_inspector_primitives.dart';
import 'food_inspector_theme.dart';
import 'halal_information_card.dart';

class FoodHealthCardWidget extends StatelessWidget {
  const FoodHealthCardWidget({
    super.key,
    required this.card,
    required this.scoreAnim,
    required this.locale,
  });

  final FoodHealthCard card;
  final Animation<double> scoreAnim;
  final String locale;

  bool get _isRtl => AppLocale.isRtl(locale);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: card.verdictColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          FoodInspectorEntranceReveal(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    card.verdictColor.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (card.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            card.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) =>
                                const SizedBox(width: 60),
                          ),
                        ),
                      if (card.imageUrl != null) const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.productName,
                              style: TextStyle(
                                color: AppColors.isLight
                                    ? AppColors.textPrimary
                                    : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card.brand,
                              style: TextStyle(
                                color: AppColors.isLight
                                    ? AppColors.textOnGlassSecondary
                                    : Colors.white.withValues(alpha: 0.4),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              FoodInspectorStrings.format(
                                'barcode_label',
                                locale,
                                {'code': card.barcode},
                              ),
                              style: TextStyle(
                                color: AppColors.isLight
                                    ? AppColors.textOnGlassMuted
                                    : Colors.white.withValues(alpha: 0.3),
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    card.verdictColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      card.verdictColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                card.verdict,
                                style: TextStyle(
                                  color: card.verdictColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      _ScoreRing(
                        score: card.healthScore,
                        color: card.verdictColor,
                        anim: scoreAnim,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: card.verdictColor.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: card.verdictColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      '✨ ${card.motivationalMessage}',
                      textAlign: _isRtl ? TextAlign.right : TextAlign.center,
                      textDirection:
                          _isRtl ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        color: card.verdictColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (card.allergyWarnings.isNotEmpty)
            FoodInspectorEntranceReveal(
              delay: const Duration(milliseconds: 80),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: AllergyWarningBanner(
                  warnings: card.allergyWarnings,
                  locale: locale,
                ),
              ),
            ),
          FoodInspectorEntranceReveal(
            delay: const Duration(milliseconds: 120),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                card.allergyWarnings.isNotEmpty ? 12 : 0,
                20,
                12,
              ),
              child: HalalInformationCard(
                halalInfo: card.halalInfo,
                locale: locale,
              ),
            ),
          ),
          FoodInspectorEntranceReveal(
            delay: const Duration(milliseconds: 160),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                card.summary,
                textAlign: _isRtl ? TextAlign.right : TextAlign.left,
                textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassSecondary
                      : Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ),
          Divider(
            color: AppColors.isLight
                ? AppColors.glassBorder
                : Colors.white10,
            height: 1,
          ),
          if (card.nutrients.isNotEmpty) ...[
            FoodInspectorEntranceReveal(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: HomeSectionHeader(
                  overline: FoodInspectorStrings.t(
                    'section_nutrition_overline',
                    locale,
                  ),
                  title: FoodInspectorStrings.t('section_nutrition', locale),
                  leadingIcon: Icons.bar_chart_rounded,
                ),
              ),
            ),
            FoodInspectorEntranceReveal(
              delay: const Duration(milliseconds: 240),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  children: card.nutrients
                      .map((n) => _NutrientBar(n: n, isRtl: _isRtl))
                      .toList(),
                ),
              ),
            ),
            Divider(
              color: AppColors.isLight
                  ? AppColors.glassBorder
                  : Colors.white10,
              height: 1,
            ),
          ],
          if (card.additives.isNotEmpty) ...[
            FoodInspectorEntranceReveal(
              delay: const Duration(milliseconds: 280),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: HomeSectionHeader(
                  overline: FoodInspectorStrings.t(
                    'section_additives_overline',
                    locale,
                  ),
                  title: FoodInspectorStrings.t('section_additives', locale),
                  leadingIcon: Icons.science_outlined,
                ),
              ),
            ),
            FoodInspectorEntranceReveal(
              delay: const Duration(milliseconds: 320),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: card.additives
                      .map((a) => _AdditiveRow(a: a, isRtl: _isRtl))
                      .toList(),
                ),
              ),
            ),
          ],
          FoodInspectorEntranceReveal(
            delay: const Duration(milliseconds: 360),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: foodInspectorPurple.withValues(alpha: 0.06),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(
                  top: BorderSide(
                    color: AppColors.isLight
                        ? AppColors.glassBorder
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: foodInspectorPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'R',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    FoodInspectorStrings.format(
                      'footer_scanned_by',
                      locale,
                      {'host': CommonStrings.publicWebsiteHost},
                    ),
                    style: TextStyle(
                      color: AppColors.isLight
                          ? AppColors.textOnGlassMuted
                          : Colors.white.withValues(alpha: 0.3),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.score,
    required this.color,
    required this.anim,
  });

  final int score;
  final Color color;
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, _) => SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: (score / 100) * anim.value,
              strokeWidth: 6,
              backgroundColor: AppColors.isLight
                  ? AppColors.glassSurface
                  : Colors.white.withValues(alpha: 0.07),
              color: color,
              strokeCap: StrokeCap.round,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(score * anim.value).round()}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    height: 1,
                  ),
                ),
                Text(
                  '/100',
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.3),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  const _NutrientBar({required this.n, required this.isRtl});

  final NutrientInfo n;
  final bool isRtl;

  Color get _color {
    if (n.dailyPct < 10) return AppColors.successBright;
    if (n.dailyPct < 25) return const Color(0xFF7BC67E);
    if (n.dailyPct < 50) return AppColors.accentGold;
    return AppColors.errorBright;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                child: Text(
                  n.name,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassSecondary
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                n.amount,
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textPrimary
                      : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 38,
                child: Text(
                  '${n.dailyPct.round()}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (n.dailyPct / 100).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: AppColors.isLight
                  ? AppColors.glassSurface
                  : Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(_color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdditiveRow extends StatelessWidget {
  const _AdditiveRow({required this.a, required this.isRtl});

  final DecodedAdditive a;
  final bool isRtl;

  Color get _color {
    switch (a.status) {
      case 'safe':
        return AppColors.successBright;
      case 'avoid':
        return AppColors.errorBright;
      default:
        return AppColors.accentGold;
    }
  }

  String get _icon {
    switch (a.status) {
      case 'safe':
        return '🟢';
      case 'avoid':
        return '🔴';
      default:
        return '🟡';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              a.code,
              style: TextStyle(
                color: _color,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  a.plainName,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  a.reason,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassSecondary
                        : Colors.white.withValues(alpha: 0.42),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_icon, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
