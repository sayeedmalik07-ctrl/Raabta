import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/employer_track_record_lookup.dart';
import 'package:raabta/features/eosb/domain/services/employer_track_record_service.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/screens/employer_track_record_lookup_screen.dart';
import 'package:raabta/features/eosb/presentation/widgets/employer_track_record_result_card.dart';
import 'package:raabta/features/eosb/providers/employer_track_record_providers.dart';

/// Inline Employer Track Record on Jobs listing detail — same API as Parts A–F.
class JobEmployerTrackRecordCard extends ConsumerStatefulWidget {
  const JobEmployerTrackRecordCard({
    super.key,
    required this.companyName,
    required this.locale,
  });

  final String companyName;
  final String locale;

  @override
  ConsumerState<JobEmployerTrackRecordCard> createState() =>
      _JobEmployerTrackRecordCardState();
}

class _JobEmployerTrackRecordCardState
    extends ConsumerState<JobEmployerTrackRecordCard> {
  EmployerTrackRecordLookup? _lookup;
  bool _loading = false;
  EmployerTrackRecordService? _trackRecordService;

  @override
  void initState() {
    super.initState();
    _trackRecordService = ref.read(employerTrackRecordServiceProvider);
    _fetchLookup();
  }

  @override
  void didUpdateWidget(covariant JobEmployerTrackRecordCard oldWidget) {
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
    _trackRecordService ??= ref.read(employerTrackRecordServiceProvider);
    _trackRecordService!.lookupDebounced(
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
    _trackRecordService?.cancelPendingLookup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.companyName.trim();
    if (name.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          EosbStrings.t('employer_track_record_check_employer_button', widget.locale),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_lookup != null)
          EmployerTrackRecordResultCard(
            lookup: _lookup!,
            locale: widget.locale,
            showInsufficientData: true,
          ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => context.push(
            EmployerTrackRecordLookupScreen.route(employerName: name),
          ),
          icon: const Icon(Icons.search_rounded, size: 18),
          label: Text(
            EosbStrings.t('employer_track_record_lookup_action', widget.locale),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.cyanGlow,
            side: BorderSide(
              color: AppColors.cyanGlow.withValues(alpha: 0.45),
            ),
          ),
        ),
      ],
    );
  }
}
