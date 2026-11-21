import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/check_number/number_facts.dart';
import 'package:raabta/features/scam_shield/check_number/number_facts_parser.dart';
import 'package:raabta/features/scam_shield/check_number/number_guidance_resolver.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/operator_reporting_section.dart';
import 'package:raabta/features/scam_shield/data/scam_authority_directory_config.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldCheckNumberScreen extends ConsumerStatefulWidget {
  const ScamShieldCheckNumberScreen({super.key, this.prefillNumber});

  final String? prefillNumber;

  @override
  ConsumerState<ScamShieldCheckNumberScreen> createState() =>
      _ScamShieldCheckNumberScreenState();
}

class _ScamShieldCheckNumberScreenState
    extends ConsumerState<ScamShieldCheckNumberScreen> {
  late final TextEditingController _numberController;
  CheckNumberReachChannel? _channel;
  String? _claimedId;
  NumberFacts? _facts;
  List<NumberGuidanceCard> _cards = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.prefillNumber ?? '');
    if (widget.prefillNumber != null && widget.prefillNumber!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _analyze());
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    setState(() => _loading = true);
    final facts = await NumberFactsParser.parse(_numberController.text);
    final cards = await NumberGuidanceResolver.resolve(
      NumberGuidanceInput(
        facts: facts,
        channel: _channel,
        claimedAuthorityId: _claimedId,
      ),
    );
    if (mounted) {
      setState(() {
        _facts = facts;
        _cards = cards;
        _loading = false;
      });
    }
  }

  Future<void> _showCnap() async {
    final card = await NumberGuidanceResolver.cnapCard();
    if (!mounted) return;
    if (card == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ScamShieldStrings.t('ss_cn_cnap_unavailable', locale)),
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          ScamShieldStrings.t(card.textKey, locale),
          style: AppTypography.body,
        ),
      ),
    );
  }

  String get locale => AppLocale.normalize(ref.watch(userLanguageProvider));

  @override
  Widget build(BuildContext context) {
    final isRtl = AppLocale.isRtl(locale);
    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_cn_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: ListView(
          children: [
            Text(
              ScamShieldStrings.t('ss_cn_subtitle', locale),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: ScamShieldStrings.t('ss_cn_input_label', locale),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              ScamShieldStrings.t('ss_cn_channel_label', locale),
              style: AppTypography.caption,
            ),
            Wrap(
              spacing: 8,
              children: CheckNumberReachChannel.values.map((c) {
                return ChoiceChip(
                  label: Text(_channelLabel(c, locale)),
                  selected: _channel == c,
                  onSelected: (_) => setState(() => _channel = c),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ScamShieldStrings.t('ss_cn_claimed_label', locale),
              style: AppTypography.caption,
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final entry in ScamAuthorityDirectoryConfig.entries)
                  FilterChip(
                    label: Text(ScamShieldStrings.t(entry.nameKey, locale)),
                    selected: _claimedId == entry.id,
                    onSelected: (on) => setState(
                      () => _claimedId = on ? entry.id : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: ScamShieldStrings.t('ss_cn_analyze', locale),
              expand: true,
              onPressed: _loading ? null : _analyze,
            ),
            TextButton(
              onPressed: _showCnap,
              child: Text(ScamShieldStrings.t('ss_cn_cnap_link', locale)),
            ),
            if (_loading) const LinearProgressIndicator(),
            if (_facts != null) ...[
              const SizedBox(height: AppSpacing.lg),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ScamShieldStrings.t('ss_cn_facts_heading', locale),
                      style: AppTypography.subtitle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _formatFactLine(_facts!, locale),
                      style: AppTypography.body,
                    ),
                    if (_facts!.normalizedE164 != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        ScamShieldStrings.format(
                          'ss_cn_e164',
                          locale,
                          {'e164': _facts!.normalizedE164!},
                        ),
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
              ),
              if (_claimedId != null) ...[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => context.push('/scam-shield/directory'),
                  icon: const Icon(Icons.contact_phone_outlined),
                  label: Text(
                    ScamShieldStrings.format(
                      'ss_cn_directory_contact',
                      locale,
                      {
                        'entity': ScamShieldStrings.t(
                          ScamAuthorityDirectoryConfig.findById(_claimedId!)!
                              .nameKey,
                          locale,
                        ),
                      },
                    ),
                  ),
                ),
              ],
              for (final card in _cards) ...[
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ScamShieldStrings.t(card.textKey, locale),
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        card.sourceLabel,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.xl),
            OperatorReportingSection(locale: locale),
          ],
        ),
      ),
    );
  }

  String _channelLabel(CheckNumberReachChannel c, String locale) {
    return ScamShieldStrings.t(
      switch (c) {
        CheckNumberReachChannel.phoneCall => 'ss_cn_channel_call',
        CheckNumberReachChannel.sms => 'ss_cn_channel_sms',
        CheckNumberReachChannel.whatsAppOrVoip => 'ss_cn_channel_voip',
        CheckNumberReachChannel.otherApp => 'ss_cn_channel_other',
      },
      locale,
    );
  }

  String _formatFactLine(NumberFacts facts, String locale) {
    if (facts.type == NumberFactType.international) {
      final country = locale == 'Arabic'
          ? (facts.internationalCountryAr ?? facts.internationalCountryEn)
          : facts.internationalCountryEn;
      return ScamShieldStrings.format(
        facts.factLineKey(locale),
        locale,
        {'country': country ?? ''},
      );
    }
    return ScamShieldStrings.t(facts.factLineKey(locale), locale);
  }
}
