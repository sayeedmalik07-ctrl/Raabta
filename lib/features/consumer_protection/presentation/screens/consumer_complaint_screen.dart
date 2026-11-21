import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/consumer_protection/presentation/l10n/consumer_protection_strings.dart';
import 'package:raabta/features/consumer_protection/presentation/widgets/moci_consumer_complaint_card.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Standalone linkable MOCI consumer-complaint reference.
class ConsumerComplaintScreen extends ConsumerWidget {
  const ConsumerComplaintScreen({super.key});

  static const route = '/consumer-complaint';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: ConsumerProtectionStrings.t('cp_screen_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          MociConsumerComplaintCard(
            locale: locale,
            showRegulatorContrast: true,
          ),
        ],
      ),
    );
  }
}
