import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/cooling_resource.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/cooling_resources_service.dart';
import 'package:raabta/features/quick_actions/climate_navigator/utils/climate_platform.dart';
import 'package:raabta/features/quick_actions/climate_navigator/utils/cooling_map_clusterer.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_feature_empty_state.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_primitives.dart';
import 'package:url_launcher/url_launcher.dart';

final coolingResourcesServiceProvider =
    Provider((ref) => CoolingResourcesService());

/// Map + nearest-list panel surfaced inside Climate Navigator only.
class CoolingResourcesPanel extends ConsumerStatefulWidget {
  const CoolingResourcesPanel({
    super.key,
    required this.locale,
    this.onSetDestination,
  });

  final String locale;
  final ValueChanged<String>? onSetDestination;

  @override
  ConsumerState<CoolingResourcesPanel> createState() =>
      _CoolingResourcesPanelState();

  @visibleForTesting
  static bool shouldOfferNearestPublicStop({
    required bool usingDeviceLocation,
    required CoolingResource? stop,
  }) {
    if (!usingDeviceLocation) return false;
    return stop != null;
  }
}

class _CoolingResourcesPanelState extends ConsumerState<CoolingResourcesPanel> {
  static const _doha = LatLng(25.2854, 51.5310);

  final _locationService = PrayerLocationService();
  GoogleMapController? _mapController;

  double? _latitude;
  double? _longitude;
  String? _locationLabel;
  bool _locationLoading = true;
  bool _permissionDenied = false;

  String? _typeFilter;
  String? _capabilityFilter;
  List<CoolingResource> _verified = const [];
  List<CoolingResource> _liveResults = const [];
  Set<Marker> _markers = {};
  double _zoom = 11;
  bool _showLiveResults = false;
  bool _liveSearchLoading = false;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _resolveLocation();
  }

  Future<void> _resolveLocation() async {
    setState(() {
      _locationLoading = true;
      _permissionDenied = false;
    });

    final granted = await _locationService.ensurePermission();
    if (!granted) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _locationLoading = false;
        _latitude = _doha.latitude;
        _longitude = _doha.longitude;
        _locationLabel = ClimateStrings.t('cooling_location_doha', widget.locale);
      });
      _loadResources();
      return;
    }

    try {
      final result = await _locationService.resolve(autoLocation: true);
      if (!mounted) return;
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _locationLabel = result.label;
        _locationLoading = false;
      });
      _loadResources();
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(result.latitude, result.longitude)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _locationLoading = false;
        _latitude = _doha.latitude;
        _longitude = _doha.longitude;
        _locationLabel = ClimateStrings.t('cooling_location_doha', widget.locale);
      });
      _loadResources();
    }
  }

  void _loadResources() {
    final lat = _latitude ?? _doha.latitude;
    final lng = _longitude ?? _doha.longitude;
    final service = ref.read(coolingResourcesServiceProvider);
    final verified = service.verifiedNearby(
      latitude: lat,
      longitude: lng,
      typeFilter: _typeFilter,
      capabilityFilter: _capabilityFilter,
    );
    setState(() {
      _verified = verified;
      if (!_showLiveResults) _liveResults = const [];
    });
    _rebuildMarkers();
  }

  List<CoolingResource> get _displayResources {
    if (_showLiveResults && _liveResults.isNotEmpty) {
      final merged = [..._verified, ..._liveResults];
      merged.sort(
        (a, b) =>
            (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0),
      );
      var filtered = merged;
      if (_typeFilter != null) {
        filtered = filtered.where((r) => r.type == _typeFilter).toList();
      }
      if (_capabilityFilter != null) {
        filtered = filtered
            .where(
              (r) => _capabilityFilter == 'ac_rest' ? r.acRest : r.respite,
            )
            .toList();
      }
      return filtered;
    }
    return _verified;
  }

  void _rebuildMarkers() {
    if (!mounted) return;
    setState(() {
      _markers = CoolingMapClusterer.buildMarkers(
        resources: _displayResources,
        zoom: _zoom,
        onResourceTap: _onResourceTap,
        onClusterTap: (center, _) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(center, (_zoom + 2).clamp(11, 18)),
          );
        },
      );
    });
  }

  void _onResourceTap(CoolingResource resource) {
    setState(() => _selectedId = resource.id);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(resource.latitude, resource.longitude),
        15,
      ),
    );
  }

  Future<void> _searchLivePlaces() async {
    if (CoolingResourcesService.googlePlacesApiKey.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ClimateStrings.t('cooling_places_no_key', widget.locale),
          ),
        ),
      );
      return;
    }

    setState(() => _liveSearchLoading = true);
    final lat = _latitude ?? _doha.latitude;
    final lng = _longitude ?? _doha.longitude;
    final service = ref.read(coolingResourcesServiceProvider);
    final live = await service.searchGooglePlacesNearby(
      latitude: lat,
      longitude: lng,
    );
    if (!mounted) return;
    setState(() {
      _liveResults = live;
      _showLiveResults = true;
      _liveSearchLoading = false;
    });
    _rebuildMarkers();
  }

  Future<void> _enableLocation() async {
    climateLightHaptic();
    await Geolocator.openAppSettings();
    await _resolveLocation();
  }

  Future<void> _openDirections(CoolingResource resource) async {
    climateLightHaptic();
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${resource.latitude},${resource.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _setAsDestination(CoolingResource resource) {
    climateSelectionHaptic();
    final destination = resource.address?.isNotEmpty == true
        ? resource.address!
        : '${resource.name}, Qatar';
    widget.onSetDestination?.call(destination);
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'mall':
        return ClimateStrings.t('cooling_type_mall', widget.locale);
      case 'metro':
        return ClimateStrings.t('cooling_type_metro', widget.locale);
      case 'mosque':
        return ClimateStrings.t('cooling_type_mosque', widget.locale);
      case 'hospital':
        return ClimateStrings.t('cooling_type_hospital', widget.locale);
      case 'library':
        return ClimateStrings.t('cooling_type_library', widget.locale);
      case 'shaded_area':
        return ClimateStrings.t('cooling_type_shaded', widget.locale);
      default:
        return type;
    }
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '';
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _walkTimeLabel(CoolingResource resource) {
    final meters = resource.distanceMeters;
    if (meters == null) return '';
    final km = meters / 1000;
    final minutes = PrayerLocationService.estimateWalkMinutes(km);
    return ClimateStrings.format(
      'cooling_nearest_walk_approx',
      widget.locale,
      params: {'minutes': '$minutes'},
    );
  }

  bool get _usingDeviceLocation => !_permissionDenied && !_locationLoading;

  CoolingResource? _nearestPublicStop() {
    if (!_usingDeviceLocation) return null;
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null) return null;
    return ref.read(coolingResourcesServiceProvider).nearestPublicAccessStop(
          latitude: lat,
          longitude: lng,
          typeFilter: _typeFilter,
        );
  }

  String? _provenanceLabel(CoolingResource resource) {
    final key = resource.classificationProvenanceKey;
    if (key == null || key.isEmpty) return null;
    return ClimateStrings.t(key, widget.locale);
  }

  @override
  Widget build(BuildContext context) {
    final nearest = _displayResources.take(5).toList();
    final nearestPublicCandidate = _nearestPublicStop();
    final showNearestPublic = CoolingResourcesPanel.shouldOfferNearestPublicStop(
      usingDeviceLocation: _usingDeviceLocation,
      stop: nearestPublicCandidate,
    );
    final nearestPublic = showNearestPublic ? nearestPublicCandidate : null;
    CoolingResource? selectedResource;
    if (_selectedId != null) {
      for (final r in _displayResources) {
        if (r.id == _selectedId) {
          selectedResource = r;
          break;
        }
      }
    }

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.ac_unit_rounded, color: AppColors.cyanGlow, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ClimateStrings.t('cooling_title', widget.locale),
                      style: AppTypography.title.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ClimateStrings.t('cooling_subtitle', widget.locale),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_locationLoading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else if (_locationLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              _permissionDenied
                  ? ClimateStrings.t('cooling_location_fallback', widget.locale)
                  : ClimateStrings.format(
                      'cooling_location_near',
                      widget.locale,
                      params: {'location': _locationLabel!},
                    ),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          if (_permissionDenied && !_locationLoading) ...[
            const SizedBox(height: AppSpacing.md),
            ClimateFeatureEmptyState(
              compact: true,
              icon: Icons.location_disabled_rounded,
              title: ClimateStrings.t(
                'empty_cooling_location_title',
                widget.locale,
              ),
              description: ClimateStrings.t(
                'empty_cooling_location_body',
                widget.locale,
              ),
              actionLabel:
                  ClimateStrings.t('cooling_enable_location', widget.locale),
              onAction: _enableLocation,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _TypeChip(
                  label: ClimateStrings.t('cooling_filter_all', widget.locale),
                  selected: _typeFilter == null,
                  onTap: () {
                    setState(() => _typeFilter = null);
                    _loadResources();
                  },
                ),
                for (final type in const [
                  'mall',
                  'metro',
                  'mosque',
                  'hospital',
                  'library',
                  'shaded_area',
                ])
                  _TypeChip(
                    label: _typeLabel(type),
                    selected: _typeFilter == type,
                    onTap: () {
                      setState(
                        () => _typeFilter =
                            _typeFilter == type ? null : type,
                      );
                      _loadResources();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _TypeChip(
                  label: ClimateStrings.t(
                    'cooling_cap_filter_all',
                    widget.locale,
                  ),
                  selected: _capabilityFilter == null,
                  onTap: () {
                    setState(() => _capabilityFilter = null);
                    _loadResources();
                  },
                ),
                _TypeChip(
                  label: ClimateStrings.t('cooling_tag_ac_rest', widget.locale),
                  selected: _capabilityFilter == 'ac_rest',
                  onTap: () {
                    setState(
                      () => _capabilityFilter =
                          _capabilityFilter == 'ac_rest' ? null : 'ac_rest',
                    );
                    _loadResources();
                  },
                ),
                _TypeChip(
                  label: ClimateStrings.t('cooling_tag_respite', widget.locale),
                  selected: _capabilityFilter == 'respite',
                  onTap: () {
                    setState(
                      () => _capabilityFilter =
                          _capabilityFilter == 'respite' ? null : 'respite',
                    );
                    _loadResources();
                  },
                ),
              ],
            ),
          ),
          if (nearestPublic != null) ...[
            const SizedBox(height: 12),
            _NearestPublicStopCard(
              resource: nearestPublic,
              locale: widget.locale,
              walkLabel: _walkTimeLabel(nearestPublic),
              distanceLabel: _formatDistance(nearestPublic.distanceMeters),
              onTap: () => _onResourceTap(nearestPublic),
              onDirections: () => _openDirections(nearestPublic),
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: climateMapHeight(context),
              child: _locationLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _latitude ?? _doha.latitude,
                          _longitude ?? _doha.longitude,
                        ),
                        zoom: 11,
                      ),
                      markers: _markers,
                      myLocationButtonEnabled: !_permissionDenied,
                      myLocationEnabled: !_permissionDenied,
                      zoomControlsEnabled: false,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _rebuildMarkers();
                      },
                      onCameraMove: (position) => _zoom = position.zoom,
                      onCameraIdle: _rebuildMarkers,
                    ),
            ),
          ),
          if (_showLiveResults && _liveResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              ClimateStrings.t('cooling_live_banner', widget.locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (nearest.isEmpty)
            ClimateFeatureEmptyState(
              compact: true,
              icon: Icons.ac_unit_rounded,
              title: ClimateStrings.t('empty_cooling_title', widget.locale),
              description: _capabilityFilter != null
                  ? ClimateStrings.t('cooling_empty', widget.locale)
                  : ClimateStrings.t('empty_cooling_body', widget.locale),
            )
          else
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: nearest.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final resource = nearest[index];
                  final selected = resource.id == _selectedId;
                  return _ResourceCarouselCard(
                    resource: resource,
                    selected: selected,
                    typeLabel: _typeLabel(resource.type),
                    distanceLabel: _formatDistance(resource.distanceMeters),
                    acRestLabel:
                        ClimateStrings.t('cooling_tag_ac_rest', widget.locale),
                    respiteLabel:
                        ClimateStrings.t('cooling_tag_respite', widget.locale),
                    provenanceLabel: _provenanceLabel(resource),
                    verifiedLabel: resource.isVerified
                        ? ClimateStrings.t('cooling_verified', widget.locale)
                        : ClimateStrings.t('cooling_unverified', widget.locale),
                    directionsLabel:
                        ClimateStrings.t('cooling_directions', widget.locale),
                    setDestinationLabel: ClimateStrings.t(
                      'cooling_set_destination',
                      widget.locale,
                    ),
                    showSetDestination: widget.onSetDestination != null,
                    onTap: () => _onResourceTap(resource),
                    onDirections: () => _openDirections(resource),
                    onSetDestination: () => _setAsDestination(resource),
                  );
                },
              ),
            ),
          if (selectedResource != null &&
              (selectedResource.acRest ||
                  selectedResource.respite ||
                  _provenanceLabel(selectedResource) != null)) ...[
            const SizedBox(height: 10),
            _ClassificationDetailCard(
              resource: selectedResource,
              locale: widget.locale,
              typeLabel: _typeLabel(selectedResource.type),
              provenanceLabel: _provenanceLabel(selectedResource),
              acRestLabel:
                  ClimateStrings.t('cooling_tag_ac_rest', widget.locale),
              respiteLabel:
                  ClimateStrings.t('cooling_tag_respite', widget.locale),
              detailLabel:
                  ClimateStrings.t('cooling_detail_heading', widget.locale),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: GlassSecondaryButton(
              label: ClimateStrings.t('cooling_search_places', widget.locale),
              icon: _liveSearchLoading ? null : Icons.search_rounded,
              onPressed: _liveSearchLoading ? null : _searchLivePlaces,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.cyanGlow.withValues(alpha: 0.2),
        checkmarkColor: AppColors.cyanGlow,
        labelStyle: TextStyle(
          color: selected ? AppColors.cyanGlow : AppColors.textSecondary,
        ),
        side: BorderSide(
          color: selected
              ? AppColors.cyanGlow.withValues(alpha: 0.5)
              : AppColors.glassBorder,
        ),
      ),
    );
  }
}

class _ResourceCarouselCard extends StatelessWidget {
  const _ResourceCarouselCard({
    required this.resource,
    required this.selected,
    required this.typeLabel,
    required this.distanceLabel,
    required this.acRestLabel,
    required this.respiteLabel,
    required this.provenanceLabel,
    required this.verifiedLabel,
    required this.directionsLabel,
    required this.setDestinationLabel,
    required this.showSetDestination,
    required this.onTap,
    required this.onDirections,
    required this.onSetDestination,
  });

  final CoolingResource resource;
  final bool selected;
  final String typeLabel;
  final String distanceLabel;
  final String acRestLabel;
  final String respiteLabel;
  final String? provenanceLabel;
  final String verifiedLabel;
  final String directionsLabel;
  final String setDestinationLabel;
  final bool showSetDestination;
  final VoidCallback onTap;
  final VoidCallback onDirections;
  final VoidCallback onSetDestination;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        glowColor: selected ? AppColors.cyanGlow : null,
        glowIntensity: selected ? 0.25 : 0,
        child: SizedBox(
          width: 210,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resource.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (resource.acRest || resource.respite) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (resource.acRest)
                      _CapabilityTag(label: acRestLabel, icon: Icons.ac_unit),
                    if (resource.respite)
                      _CapabilityTag(
                        label: respiteLabel,
                        icon: Icons.park_outlined,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    typeLabel,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.cyanGlow,
                      fontSize: 11,
                    ),
                  ),
                  if (distanceLabel.isNotEmpty) ...[
                    Text(
                      ' · $distanceLabel',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              if (provenanceLabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  provenanceLabel!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textOnGlassMuted,
                    height: 1.25,
                  ),
                ),
              ],
              const Spacer(),
              if (showSetDestination) ...[
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onSetDestination,
                    icon: Icon(
                      Icons.flag_rounded,
                      size: 14,
                      color: AppColors.cyanGlow,
                    ),
                    label: Text(
                      setDestinationLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.cyanGlow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (resource.isVerified
                              ? AppColors.success
                              : AppColors.warning)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      verifiedLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: resource.isVerified
                            ? AppColors.successBright
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    color: AppColors.cyanGlow,
                    onPressed: onDirections,
                    tooltip: directionsLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapabilityTag extends StatelessWidget {
  const _CapabilityTag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.cyanGlow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.cyanGlow.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.cyanGlow),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.cyanGlow,
            ),
          ),
        ],
      ),
    );
  }
}

class _NearestPublicStopCard extends StatelessWidget {
  const _NearestPublicStopCard({
    required this.resource,
    required this.locale,
    required this.walkLabel,
    required this.distanceLabel,
    required this.onTap,
    required this.onDirections,
  });

  final CoolingResource resource;
  final String locale;
  final String walkLabel;
  final String distanceLabel;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ClimateStrings.t('cooling_nearest_stop_title', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.cyanGlow,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              resource.name,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
            if (distanceLabel.isNotEmpty || walkLabel.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                [distanceLabel, walkLabel].where((s) => s.isNotEmpty).join(' · '),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
            if (resource.publicAccessEvidence != null) ...[
              const SizedBox(height: 6),
              Text(
                ClimateStrings.t('cooling_public_access_note', locale),
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textOnGlassMuted,
                  height: 1.3,
                ),
              ),
            ],
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.directions_rounded, size: 20),
                color: AppColors.cyanGlow,
                onPressed: onDirections,
                tooltip: ClimateStrings.t('cooling_directions', locale),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassificationDetailCard extends StatelessWidget {
  const _ClassificationDetailCard({
    required this.resource,
    required this.locale,
    required this.typeLabel,
    required this.provenanceLabel,
    required this.acRestLabel,
    required this.respiteLabel,
    required this.detailLabel,
  });

  final CoolingResource resource;
  final String locale;
  final String typeLabel;
  final String? provenanceLabel;
  final String acRestLabel;
  final String respiteLabel;
  final String detailLabel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detailLabel,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.cyanGlow,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${resource.name} · $typeLabel',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
          if (resource.acRest || resource.respite) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (resource.acRest)
                  _CapabilityTag(label: acRestLabel, icon: Icons.ac_unit),
                if (resource.respite)
                  _CapabilityTag(
                    label: respiteLabel,
                    icon: Icons.park_outlined,
                  ),
              ],
            ),
          ],
          if (provenanceLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              provenanceLabel!,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                color: AppColors.textOnGlassMuted,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
