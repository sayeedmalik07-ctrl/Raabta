import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_strings.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';

class CaseTimelineLinkButton extends StatelessWidget {
  const CaseTimelineLinkButton({
    super.key,
    required this.engine,
    required this.caseId,
    required this.locale,
    this.eosbIncludeSettlement = true,
    this.expand = true,
  });

  final CaseTimelineEngineType engine;
  final String caseId;
  final String locale;
  final bool eosbIncludeSettlement;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    if (caseId.isEmpty) return const SizedBox.shrink();

    final path = CaseTimelineNavigation.routePath(
      engine: engine,
      caseId: caseId,
    );
    final query = engine == CaseTimelineEngineType.eosb &&
            !eosbIncludeSettlement
        ? '?settlement=0'
        : '';

    return GlassPrimaryButton(
      label: CaseTimelineStrings.t('ct_open_timeline', locale),
      icon: Icons.timeline_outlined,
      expand: expand,
      onPressed: () => context.push('$path$query'),
    );
  }
}
