import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/features/admin/widgets/admin_widgets.dart';
import 'package:raabta/features/exchange_locator/domain/models/branch_filters.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_company.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/exchange_locator/presentation/providers/exchange_locator_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class AdminExchangeLocatorScreen extends ConsumerStatefulWidget {
  const AdminExchangeLocatorScreen({super.key});

  @override
  ConsumerState<AdminExchangeLocatorScreen> createState() =>
      _AdminExchangeLocatorScreenState();
}

class _AdminExchangeLocatorScreenState
    extends ConsumerState<AdminExchangeLocatorScreen> {
  bool _loading = true;
  String? _error;
  List<ExchangeCompany> _companies = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = await ref.read(exchangeLocatorRepositoryProvider.future);
      final page = await repo.fetchCompanies(limit: 100);
      setState(() {
        _companies = page.items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminAppBar(
        title: ExchangeLocatorStrings.t('screen_title', locale),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCompanyForm,
        backgroundColor: AdminAppBar.adminAccent,
        icon: const Icon(Icons.add_business),
        label: Text(ExchangeLocatorStrings.t('admin_add_company', locale)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? GlassErrorState(message: _error!, onRetry: _load)
              : _companies.isEmpty
                  ? GlassEmptyState(
                      icon: Icons.account_balance_outlined,
                      title: ExchangeLocatorStrings.t(
                        'admin_no_companies_title',
                        locale,
                      ),
                      description: ExchangeLocatorStrings.t(
                        'admin_no_companies_description',
                        locale,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: _companies.length,
                        itemBuilder: (context, index) {
                          final c = _companies[index];
                          return Card(
                            color: AppColors.glassSurface,
                            child: ListTile(
                              title: Text(c.name, style: AppTypography.title),
                              subtitle: Text(
                                ExchangeLocatorStrings.format(
                                  'admin_company_subtitle',
                                  locale,
                                  params: {
                                    'count': '${c.totalBranches}',
                                    'rating': c.rating.toStringAsFixed(1),
                                  },
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (action) async {
                                  if (action == 'edit') {
                                    await _showCompanyForm(company: c);
                                  } else if (action == 'branch') {
                                    await _showBranchForm(companyId: c.id);
                                  } else if (action == 'delete') {
                                    await _deleteCompany(c.id);
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(
                                      ExchangeLocatorStrings.t(
                                        'admin_menu_edit',
                                        locale,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'branch',
                                    child: Text(
                                      ExchangeLocatorStrings.t(
                                        'admin_menu_add_branch',
                                        locale,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      ExchangeLocatorStrings.t(
                                        'admin_menu_delete',
                                        locale,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Future<void> _deleteCompany(String id) async {
    final repo = await ref.read(exchangeLocatorRepositoryProvider.future);
    await repo.deleteCompany(id);
    await _load();
  }

  Future<void> _showCompanyForm({ExchangeCompany? company}) async {
    final locale = ref.read(userLanguageProvider);
    final nameCtrl = TextEditingController(text: company?.name ?? '');
    final descCtrl = TextEditingController(text: company?.description ?? '');
    final phoneCtrl = TextEditingController(text: company?.supportPhone ?? '');
    var featured = company?.isFeatured ?? false;
    var verified = company?.isVerified ?? false;
    String? logoUrl = company?.logo;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
            top: AppSpacing.lg,
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      company == null
                          ? ExchangeLocatorStrings.t('admin_add_company_title', locale)
                          : ExchangeLocatorStrings.t('admin_edit_company_title', locale),
                      style: AppTypography.headline2,
                    ),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: ExchangeLocatorStrings.t('admin_label_name', locale),
                      ),
                    ),
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        labelText: ExchangeLocatorStrings.t(
                          'admin_label_description',
                          locale,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: phoneCtrl,
                      decoration: InputDecoration(
                        labelText: ExchangeLocatorStrings.t(
                          'admin_label_support_phone',
                          locale,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: Text(
                        ExchangeLocatorStrings.t('status_featured', locale),
                      ),
                      value: featured,
                      onChanged: (v) => setLocal(() => featured = v),
                    ),
                    SwitchListTile(
                      title: Text(
                        ExchangeLocatorStrings.t('status_verified', locale),
                      ),
                      value: verified,
                      onChanged: (v) => setLocal(() => verified = v),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final file = await picker.pickImage(source: ImageSource.gallery);
                        if (file == null) return;
                        final storage = ref.read(exchangeLocatorStorageProvider);
                        final id = company?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
                        logoUrl = await storage.uploadCompanyLogo(File(file.path), id);
                        setLocal(() {});
                      },
                      icon: const Icon(Icons.upload),
                      label: Text(
                        logoUrl == null
                            ? ExchangeLocatorStrings.t('admin_upload_logo', locale)
                            : ExchangeLocatorStrings.t('admin_logo_uploaded', locale),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () async {
                        final repo = await ref.read(exchangeLocatorRepositoryProvider.future);
                        await repo.upsertCompany(
                          ExchangeCompany(
                            id: company?.id ?? '',
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            supportPhone: phoneCtrl.text.trim(),
                            logo: logoUrl,
                            isFeatured: featured,
                            isVerified: verified,
                          ),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _load();
                      },
                      child: Text(ExchangeLocatorStrings.t('admin_save', locale)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    nameCtrl.dispose();
    descCtrl.dispose();
    phoneCtrl.dispose();
  }

  Future<void> _showBranchForm({
    required String companyId,
    ExchangeBranch? branch,
  }) async {
    final locale = ref.read(userLanguageProvider);
    final nameCtrl = TextEditingController(text: branch?.branchName ?? '');
    final areaCtrl = TextEditingController(text: branch?.area ?? '');
    final addressCtrl = TextEditingController(text: branch?.address ?? '');
    final phoneCtrl = TextEditingController(text: branch?.phone ?? '');
    final latCtrl = TextEditingController(
      text: (branch?.latitude ?? 25.2854).toString(),
    );
    final lngCtrl = TextEditingController(
      text: (branch?.longitude ?? 51.5310).toString(),
    );
    var openNow = branch?.isOpenNow ?? true;
    var queue = branch?.queueStatus ?? ExchangeQueueStatus.low;
    var wait = branch?.estimatedWaitingMinutes ?? 5;
    var detailsVerified = branch?.detailsVerified ?? false;
    var services = branch?.services ?? <String>['Currency Exchange', 'Money Transfer'];
    String? photoUrl = branch?.branchPhoto;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
            top: AppSpacing.lg,
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      branch == null
                          ? ExchangeLocatorStrings.t('admin_add_branch_title', locale)
                          : ExchangeLocatorStrings.t('admin_edit_branch_title', locale),
                      style: AppTypography.headline2,
                    ),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: ExchangeLocatorStrings.t(
                          'admin_label_branch_name',
                          locale,
                        ),
                      ),
                    ),
                    TextField(
                      controller: areaCtrl,
                      decoration: InputDecoration(
                        labelText: ExchangeLocatorStrings.t('admin_label_area', locale),
                      ),
                    ),
                    TextField(
                      controller: addressCtrl,
                      decoration: InputDecoration(
                        labelText: ExchangeLocatorStrings.t(
                          'admin_label_address',
                          locale,
                        ),
                      ),
                    ),
                    TextField(
                      controller: phoneCtrl,
                      decoration: InputDecoration(
                        labelText: ExchangeLocatorStrings.t('admin_label_phone', locale),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latCtrl,
                            decoration: InputDecoration(
                              labelText: ExchangeLocatorStrings.t(
                                'admin_label_lat',
                                locale,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: lngCtrl,
                            decoration: InputDecoration(
                              labelText: ExchangeLocatorStrings.t(
                                'admin_label_lng',
                                locale,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: Text(
                        ExchangeLocatorStrings.t('admin_switch_open_now', locale),
                      ),
                      value: openNow,
                      onChanged: (v) => setLocal(() => openNow = v),
                    ),
                    SwitchListTile(
                      title: Text(
                        ExchangeLocatorStrings.t(
                          'admin_switch_details_verified',
                          locale,
                        ),
                      ),
                      subtitle: Text(
                        ExchangeLocatorStrings.t(
                          'admin_switch_details_verified_hint',
                          locale,
                        ),
                      ),
                      value: detailsVerified,
                      onChanged: (v) => setLocal(() => detailsVerified = v),
                    ),
                    DropdownButtonFormField<ExchangeQueueStatus>(
                      value: queue,
                      decoration: InputDecoration(
                        labelText: ExchangeLocatorStrings.t(
                          'admin_label_queue_status',
                          locale,
                        ),
                      ),
                      items: ExchangeQueueStatus.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                ExchangeLocatorStrings.queueStatusLabel(s, locale),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocal(() => queue = v ?? queue),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: ExchangeLocatorStrings.t(
                          'admin_label_est_wait',
                          locale,
                        ),
                        hintText: '$wait',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => wait = int.tryParse(v) ?? wait,
                    ),
                    Wrap(
                      spacing: 4,
                      children: kExchangeServiceNames.take(6).map((s) {
                        final selected = services.contains(s);
                        return FilterChip(
                          label: Text(
                            ExchangeLocatorStrings.serviceName(s, locale),
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: selected,
                          onSelected: (v) {
                            setLocal(() {
                              if (v) {
                                services = [...services, s];
                              } else {
                                services = services.where((x) => x != s).toList();
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final file = await picker.pickImage(source: ImageSource.gallery);
                        if (file == null) return;
                        final storage = ref.read(exchangeLocatorStorageProvider);
                        final id = branch?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
                        photoUrl = await storage.uploadBranchPhoto(File(file.path), id);
                        setLocal(() {});
                      },
                      icon: const Icon(Icons.upload),
                      label: Text(
                        photoUrl == null
                            ? ExchangeLocatorStrings.t('admin_upload_photo', locale)
                            : ExchangeLocatorStrings.t('admin_photo_uploaded', locale),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () async {
                        final repo = await ref.read(exchangeLocatorRepositoryProvider.future);
                        await repo.upsertBranch(
                          ExchangeBranch(
                            id: branch?.id ?? '',
                            companyId: companyId,
                            branchName: nameCtrl.text.trim(),
                            area: areaCtrl.text.trim(),
                            address: addressCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            latitude: double.tryParse(latCtrl.text) ?? 25.2854,
                            longitude: double.tryParse(lngCtrl.text) ?? 51.5310,
                            isOpenNow: openNow,
                            queueStatus: queue,
                            estimatedWaitingMinutes: wait,
                            services: services,
                            branchPhoto: photoUrl,
                            detailsVerified: detailsVerified,
                          ),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _load();
                      },
                      child: Text(
                        ExchangeLocatorStrings.t('admin_save_branch', locale),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    nameCtrl.dispose();
    areaCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    latCtrl.dispose();
    lngCtrl.dispose();
  }
}
