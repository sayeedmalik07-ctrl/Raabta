import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';

/// Feed footer compliance notice — standard hub padding (Housing reference).
class HubFeedFooterNotice extends StatelessWidget {
  const HubFeedFooterNotice({
    super.key,
    required this.locale,
    this.dense = true,
  });

  final String locale;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        dense ? 100 : AppSpacing.xxl,
      ),
      child: HubNoticeBanner.hostNotice(locale: locale),
    );
  }
}
