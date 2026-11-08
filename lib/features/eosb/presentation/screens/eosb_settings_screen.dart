import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';

class EosbSettingsScreen extends ConsumerWidget {
  const EosbSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (currentLocale) => GlassScreenScaffold(
        title: EosbStrings.t('eosb_settings', currentLocale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: ListView(
          children: [
            const ListTile(
              title: Text('Language'),
              subtitle: Text('Applies to EOSB screens'),
            ),
            ...EosbStrings.supportedLocales.map(
              (locale) => RadioListTile<String>(
                title: Text(locale),
                value: locale,
                groupValue: currentLocale,
                onChanged: (v) async {
                  if (v == null) return;
                  final repo = await ref.read(eosbRepositoryProvider.future);
                  await repo.setLocale(v);
                  ref.invalidate(eosbLocaleProvider);
                },
              ),
            ),
            FutureBuilder<bool>(
              future: ref
                  .read(eosbRepositoryProvider.future)
                  .then((r) => r.salaryConsent()),
              builder: (context, snapshot) {
                final consent = snapshot.data ?? false;
                return SwitchListTile(
                  title: Text(
                    EosbStrings.t('eosb_save_consent', currentLocale),
                  ),
                  value: consent,
                  onChanged: (v) async {
                    final repo =
                        await ref.read(eosbRepositoryProvider.future);
                    await repo.setSalaryConsent(v);
                    ref.invalidate(eosbRepositoryProvider);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
