import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/config/compliance_config_fetch.dart';
import 'package:raabta/config/compliance_flags.dart';
import 'package:raabta/features/admin/models/admin_config.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/features/admin/widgets/admin_broadcast_section.dart';
import 'package:raabta/features/admin/widgets/admin_post_schemas_section.dart';
import 'package:raabta/features/admin/widgets/admin_widgets.dart';

class AdminConfigScreen extends ConsumerStatefulWidget {
  const AdminConfigScreen({super.key});

  @override
  ConsumerState<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends ConsumerState<AdminConfigScreen> {
  final _minVersionController = TextEditingController();
  final _maintenanceMessageController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _minVersionController.dispose();
    _maintenanceMessageController.dispose();
    super.dispose();
  }

  Future<void> _patch(Map<String, dynamic> patch) async {
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateAppConfig(patch);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(adminAppConfigProvider);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AdminAppBar(title: 'Config & Flags'),
        body: configAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (config) {
            if (_minVersionController.text.isEmpty) {
              _minVersionController.text = config.minimumVersion;
            }
            if (_maintenanceMessageController.text.isEmpty) {
              _maintenanceMessageController.text = config.maintenanceMessage;
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (_saving)
                  const LinearProgressIndicator(
                    color: AdminAppBar.adminAccent,
                  ),
                SwitchListTile(
                  title: const Text('Maintenance mode'),
                  subtitle: const Text('Non-admin users see maintenance screen'),
                  value: config.maintenanceMode,
                  onChanged: _saving
                      ? null
                      : (v) => _patch({'maintenanceMode': v}),
                ),
                TextField(
                  controller: _maintenanceMessageController,
                  decoration: const InputDecoration(
                    labelText: 'Maintenance message',
                  ),
                  onSubmitted: (v) => _patch({'maintenanceMessage': v}),
                ),
                const Divider(height: 32),
                SwitchListTile(
                  title: const Text('Force update'),
                  subtitle: const Text('Block app below minimum version'),
                  value: config.forceUpdate,
                  onChanged: _saving ? null : (v) => _patch({'forceUpdate': v}),
                ),
                TextField(
                  controller: _minVersionController,
                  decoration: const InputDecoration(
                    labelText: 'Minimum required version (e.g. 1.0.0)',
                  ),
                  onSubmitted: (v) => _patch({'minimumVersion': v.trim()}),
                ),
                const Divider(height: 32),
                Text('Quick Action feature flags', style: AppTypography.headline2),
                const SizedBox(height: AppSpacing.sm),
                for (final key in AdminAppConfig.featureFlagKeys)
                  SwitchListTile(
                    title: Text(_labelForFlag(key)),
                    value: config.featureFlags[key] ?? true,
                    onChanged: _saving
                        ? null
                        : (v) => _patch({
                              'featureFlags': {
                                ...config.featureFlags,
                                key: v,
                              },
                            }),
                  ),
                const Divider(height: 32),
                Text('Decision 25 compliance flags', style: AppTypography.headline2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  !ComplianceConfigFetch.hasSuccessfulFetch
                      ? 'No successful client fetch yet — app treats flags as OFF (except job applications).'
                      : ComplianceConfigFetch.isFetchStale
                          ? 'Last successful config fetch is older than 7 days — flags OFF (except job applications).'
                          : 'Last successful config fetch is within 7 days — flag map from Firestore applies.',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final key in ComplianceFlagKeys.all)
                  SwitchListTile(
                    title: Text(_complianceLabel(key)),
                    subtitle: Text(
                      config.complianceFlagsRaw[key]?.toString() ??
                          'default: ${ComplianceFlagKeys.defaultForKey(key)}',
                    ),
                    value: _complianceToggleValue(config, key),
                    onChanged: _saving
                        ? null
                        : (v) => _onComplianceToggle(context, config, key, v),
                  ),
                const Divider(height: 32),
                const AdminPostSchemasSection(),
                const Divider(height: 32),
                AdminBroadcastSection(
                  saving: _saving,
                  onSavingChanged: (v) => setState(() => _saving = v),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _complianceToggleValue(AdminAppConfig config, String key) {
    final resolved = config.complianceFlags;
    return switch (key) {
      ComplianceFlagKeys.offersEnabled => resolved.offersEnabled,
      ComplianceFlagKeys.viewingsEnabled => resolved.viewingsEnabled,
      ComplianceFlagKeys.quotesEnabled => resolved.quotesEnabled,
      ComplianceFlagKeys.paidBoostsEnabled => resolved.paidBoostsEnabled,
      ComplianceFlagKeys.businessAdsEnabled => resolved.businessAdsEnabled,
      ComplianceFlagKeys.jobApplicationStatusEnabled =>
        resolved.jobApplicationStatusEnabled,
      ComplianceFlagKeys.businessQuotesEnabled => resolved.businessQuotesEnabled,
      ComplianceFlagKeys.businessAppointmentsEnabled =>
        resolved.businessAppointmentsEnabled,
      _ => false,
    };
  }

  Future<void> _onComplianceToggle(
    BuildContext context,
    AdminAppConfig config,
    String key,
    bool value,
  ) async {
    if (value) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enable compliance flag?'),
          content: const Text(
            'Turning this on requires a valid CR and MoCI e-commerce licence '
            'for the specific activity, plus in-app licence disclosure and '
            'payment options where required. Continue only after legal clearance.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enable')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final next = <String, bool>{
      for (final k in ComplianceFlagKeys.all)
        k: config.complianceFlagsRaw[k] ?? ComplianceFlagKeys.defaultForKey(k),
    };
    next[key] = value;
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateComplianceFlags(next);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _complianceLabel(String key) {
    return switch (key) {
      ComplianceFlagKeys.offersEnabled => 'Marketplace offers',
      ComplianceFlagKeys.viewingsEnabled => 'Housing viewings',
      ComplianceFlagKeys.quotesEnabled => 'Services quotes',
      ComplianceFlagKeys.paidBoostsEnabled => 'Paid listing boosts',
      ComplianceFlagKeys.businessAdsEnabled => 'Business advertising',
      ComplianceFlagKeys.jobApplicationStatusEnabled => 'Job application status',
      ComplianceFlagKeys.businessQuotesEnabled => 'Business quote requests',
      ComplianceFlagKeys.businessAppointmentsEnabled => 'Business appointments',
      _ => key,
    };
  }

  String _labelForFlag(String key) {
    return switch (key) {
      'doc_scanner' => 'Doc Scanner / PDF Studio',
      'food_inspector' => 'Food Inspector (Barcode)',
      'arabic_companion' => 'Arabic Companion',
      'bill_splitter' => 'Bill Splitter',
      'warranty_shield' => 'Warranty Shield',
      'climate_navigator' => 'Climate Navigator',
      'queue_avoidance' => 'Queue Avoidance',
      'bill_tracker' => 'Bill Tracker',
      'scam_domain_age' => 'Scam Shield domain age (RDAP relay)',
      'scam_link_unroll' => 'Scam Shield short-link unroll (evidence)',
      _ => key,
    };
  }
}
