import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';

class QueueStatusBadge extends StatelessWidget {
  const QueueStatusBadge({
    super.key,
    required this.status,
    required this.locale,
    this.estimatedMinutes,
  });

  final ExchangeQueueStatus status;
  final String locale;
  final int? estimatedMinutes;

  Color get _color {
    switch (status) {
      case ExchangeQueueStatus.low:
        return AppColors.success;
      case ExchangeQueueStatus.moderate:
        return AppColors.warning;
      case ExchangeQueueStatus.busy:
        return const Color(0xFFFF8C42);
      case ExchangeQueueStatus.closed:
        return AppColors.error;
    }
  }

  String get _label => ExchangeLocatorStrings.formatQueueBadgeLabel(
        status,
        estimatedMinutes,
        locale,
      );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: ExchangeLocatorStrings.format(
        'queue_status_a11y',
        locale,
        params: {'label': _label},
      ),
      child: StatusBadge(label: _label, color: _color),
    );
  }
}

/// Marker hue helper — green=open/low, orange=busy, red=closed.
double markerHueForBranch(ExchangeBranch branch) {
  if (!branch.isOpenNow || branch.queueStatus == ExchangeQueueStatus.closed) {
    return BitmapDescriptor.hueRed;
  }
  switch (branch.queueStatus) {
    case ExchangeQueueStatus.low:
      return BitmapDescriptor.hueGreen;
    case ExchangeQueueStatus.moderate:
      return BitmapDescriptor.hueYellow;
    case ExchangeQueueStatus.busy:
      return BitmapDescriptor.hueOrange;
    case ExchangeQueueStatus.closed:
      return BitmapDescriptor.hueRed;
  }
}
