import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';

void showEosbCloudSyncFailedNoticeIfPending(
  BuildContext context,
  WidgetRef ref,
  String locale,
) {
  if (!ref.read(eosbProvider).cloudSyncNoticePending) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(EosbStrings.t(eosbCloudSyncFailedNoticeKey, locale)),
    ),
  );
  ref.read(eosbProvider.notifier).clearCloudSyncNotice();
}

void showOvertimeCloudSyncFailedNoticeIfPending(
  BuildContext context,
  WidgetRef ref,
  String locale,
) {
  if (!ref.read(overtimeTruthProvider).cloudSyncNoticePending) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(EosbStrings.t(eosbCloudSyncFailedNoticeKey, locale)),
    ),
  );
  ref.read(overtimeTruthProvider.notifier).clearCloudSyncNotice();
}
