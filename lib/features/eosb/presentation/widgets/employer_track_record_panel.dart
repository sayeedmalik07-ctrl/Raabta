import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/eosb/domain/models/employer_track_record_lookup.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/employer_track_record_result_card.dart';
import 'package:raabta/features/eosb/providers/employer_track_record_providers.dart';

/// Neutral aggregated entitlement signal — shown only when k-anonymity threshold
/// is met (Part D). Never shown for insufficient data or empty employer name.
class EmployerTrackRecordPanel extends ConsumerStatefulWidget {
  const EmployerTrackRecordPanel({
    super.key,
    required this.companyName,
    required this.locale,
  });

  final String companyName;
  final String locale;

  @override
  ConsumerState<EmployerTrackRecordPanel> createState() =>
      _EmployerTrackRecordPanelState();
}

class _EmployerTrackRecordPanelState
    extends ConsumerState<EmployerTrackRecordPanel> {
  EmployerTrackRecordLookup? _lookup;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchLookup();
  }

  @override
  void didUpdateWidget(covariant EmployerTrackRecordPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyName.trim() != widget.companyName.trim()) {
      _fetchLookup();
    }
  }

  Future<void> _fetchLookup() async {
    final name = widget.companyName.trim();
    if (name.isEmpty) {
      setState(() {
        _lookup = null;
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    final service = ref.read(employerTrackRecordServiceProvider);
    service.lookupDebounced(
      companyName: name,
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _lookup = result;
          _loading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    ref.read(employerTrackRecordServiceProvider).cancelPendingLookup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.companyName.trim().isEmpty || _loading) {
      return const SizedBox.shrink();
    }

    final lookup = _lookup;
    if (lookup == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: EmployerTrackRecordResultCard(
        lookup: lookup,
        locale: widget.locale,
        showInsufficientData: false,
      ),
    );
  }
}

@visibleForTesting
String formatEmployerTrackRecordBody({
  required String locale,
  required int totalCalculations,
  required int violationFlaggedCount,
}) {
  return EosbStrings.t('employer_track_record_body', locale)
      .replaceAll('{total}', '$totalCalculations')
      .replaceAll('{violations}', '$violationFlaggedCount');
}

@visibleForTesting
String formatEmployerTrackRecordVelocityLine({
  required String locale,
  required int windowDays,
}) {
  return EosbStrings.t('employer_track_record_velocity_line', locale)
      .replaceAll('{days}', '$windowDays');
}
