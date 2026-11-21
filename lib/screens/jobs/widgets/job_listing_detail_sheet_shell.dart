import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/jobs/widgets/job_detail_action_bar.dart';

typedef JobListingDetailSheetContentBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
  String locale,
);

/// Shared modal + [DraggableScrollableSheet] chrome for job listing detail.
Future<void> showJobListingDetailBottomSheet({
  required BuildContext context,
  required JobListingDetailSheetContentBuilder buildContent,
  required String localeWhenNotWatching,
  bool watchLocale = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      if (watchLocale) {
        return Consumer(
          builder: (context, ref, _) {
            final locale = ref.watch(userLanguageProvider);
            return JobListingDetailDraggableShell(
              locale: locale,
              buildContent: buildContent,
            );
          },
        );
      }
      return JobListingDetailDraggableShell(
        locale: localeWhenNotWatching,
        buildContent: buildContent,
      );
    },
  );
}

class JobListingDetailDraggableShell extends StatelessWidget {
  const JobListingDetailDraggableShell({
    super.key,
    required this.locale,
    required this.buildContent,
  });

  final String locale;
  final JobListingDetailSheetContentBuilder buildContent;

  static const double initialChildSize = 0.88;
  static const double minChildSize = 0.5;
  static const double maxChildSize = 0.95;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return buildContent(context, scrollController, locale);
      },
    );
  }
}

/// Sheet layout: draggable scroll region + sticky [actionBar] (kit DetailActionBar).
class JobListingDetailSheetScaffold extends StatelessWidget {
  const JobListingDetailSheetScaffold({
    super.key,
    required this.scrollController,
    required this.job,
    required this.body,
    required this.actionBar,
  });

  final ScrollController scrollController;
  final JobListing job;
  final Widget body;
  final Widget actionBar;

  static const Key listViewKey = Key('jobs_detail_sheet_scroll');

  static const Key scaffoldKey = Key('jobs_detail_sheet_scaffold');

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scrollClearance =
        JobDetailActionBar.scrollBottomInset(context, job: job);
    final bottomPadding = 16 + scrollClearance + media.viewInsets.bottom;

    return Column(
      key: scaffoldKey,
      children: [
        Expanded(
          child: ListView(
            key: listViewKey,
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
            children: [
              const JobListingDetailSheetHandle(),
              const SizedBox(height: 16),
              body,
            ],
          ),
        ),
        actionBar,
      ],
    );
  }
}

class JobListingDetailSheetHandle extends StatelessWidget {
  const JobListingDetailSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
