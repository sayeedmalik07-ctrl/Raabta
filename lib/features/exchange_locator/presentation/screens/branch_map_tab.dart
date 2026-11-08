import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/exchange_locator/presentation/providers/exchange_locator_providers.dart';
import 'package:raabta/features/exchange_locator/presentation/utils/branch_map_clusterer.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/queue_status_badge.dart';
import 'package:raabta/providers/visa_providers.dart';

class BranchMapTab extends ConsumerStatefulWidget {
  const BranchMapTab({super.key});

  @override
  ConsumerState<BranchMapTab> createState() => _BranchMapTabState();
}

class _BranchMapTabState extends ConsumerState<BranchMapTab> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<ExchangeBranch> _branches = [];
  double _zoom = 11;

  static const _doha = LatLng(25.2854, 51.5310);

  void _rebuildMarkers() {
    if (!mounted || _branches.isEmpty) return;
    setState(() {
      _markers = BranchMapClusterer.buildMarkers(
        branches: _branches,
        zoom: _zoom,
        onBranchTap: _showBranchSheet,
        onClusterTap: (center, _) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(center, (_zoom + 2).clamp(11, 18)),
          );
        },
      );
    });
  }

  void _showBranchSheet(ExchangeBranch branch) {
    final locale = ref.read(userLanguageProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(branch.branchName, style: AppTypography.title),
              Text(branch.displayLocation, style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.sm),
              QueueStatusBadge(
                status: branch.queueStatus,
                locale: locale,
                estimatedMinutes: branch.estimatedWaitingMinutes,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push('/exchange-locator/branch/${branch.id}');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.goldFamilyMain,
                    foregroundColor: AppColors.background,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    ExchangeLocatorStrings.t('view_full_details', locale),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final branchesAsync = ref.watch(mapBranchesProvider);

    return branchesAsync.when(
      loading: () => LayoutBuilder(
        builder: (context, constraints) {
          final padding = moneyHubScreenPadding.copyWith(top: AppSpacing.sm);
          final contentWidth =
              constraints.maxWidth - padding.horizontal;
          final contentHeight =
              constraints.maxHeight - padding.vertical;
          return Padding(
            padding: padding,
            child: HubLoadingPlaceholder(
              width: contentWidth,
              height: contentHeight.clamp(120, double.infinity),
            ),
          );
        },
      ),
      error: (e, _) => GlassErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(mapBranchesProvider),
      ),
      data: (branches) {
        if (branches.isEmpty) {
          return Padding(
            padding: moneyHubScreenPadding.copyWith(top: AppSpacing.sm),
            child: MoneyHubEmptyState(
              icon: Icons.map_outlined,
              title: ExchangeLocatorStrings.t('no_map_branches_title', locale),
              description: ExchangeLocatorStrings.t(
                'no_map_branches_description',
                locale,
              ),
            ),
          );
        }

        if (_branches.length != branches.length) {
          _branches = branches;
          WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildMarkers());
        }

        return RefreshIndicator(
          color: moneyHubAccent,
          backgroundColor: AppColors.surface,
          onRefresh: () => refreshMapBranches(ref),
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(target: _doha, zoom: 11),
            markers: _markers,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              _rebuildMarkers();
            },
            onCameraMove: (position) => _zoom = position.zoom,
            onCameraIdle: _rebuildMarkers,
          ),
        );
      },
    );
  }
}
