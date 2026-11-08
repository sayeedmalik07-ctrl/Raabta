import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_delivery.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_guidance_catalog.dart'
    show SecurityGuidanceCatalog, SecurityGuidanceTopic;
import 'package:raabta/features/scam_shield/security_alerts/security_guidance_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScamShieldSecurityTipScreen extends ConsumerStatefulWidget {
  const ScamShieldSecurityTipScreen({super.key, required this.topicId});

  final String topicId;

  @override
  ConsumerState<ScamShieldSecurityTipScreen> createState() =>
      _ScamShieldSecurityTipScreenState();
}

class _ScamShieldSecurityTipScreenState
    extends ConsumerState<ScamShieldSecurityTipScreen> {
  @override
  void initState() {
    super.initState();
    SecurityAlertDelivery.recordTipOpened();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: SecurityGuidanceStrings.t('ss_sec_push_tip_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      body: FutureBuilder(
        future: SecurityGuidanceCatalog.loadTopics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final topics = snapshot.data!;
          SecurityGuidanceTopic? topic;
          for (final t in topics) {
            if (t.id == widget.topicId) {
              topic = t;
              break;
            }
          }
          if (topic == null) {
            return Center(
              child: Text(
                SecurityGuidanceStrings.t('ss_sec_tip_not_found', locale),
              ),
            );
          }
          final variant = topic.variantKeys.isNotEmpty
              ? topic.variantKeys.first
              : '';
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                SecurityGuidanceStrings.t(topic.titleKey, locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                SecurityGuidanceStrings.t(variant, locale),
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                SecurityGuidanceStrings.t(topic.sourceLabelKey, locale),
                style: AppTypography.caption,
              ),
            ],
          );
        },
      ),
    );
  }
}
