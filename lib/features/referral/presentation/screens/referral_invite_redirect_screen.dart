import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/services/referral/pending_referral_store.dart';
import 'package:raabta/services/referral/referral_analytics_service.dart';

/// Resolves `/invite/:code` into EOSB entry with pending attribution stored.
class ReferralInviteRedirectScreen extends StatefulWidget {
  const ReferralInviteRedirectScreen({super.key, required this.code});

  final String code;

  @override
  State<ReferralInviteRedirectScreen> createState() =>
      _ReferralInviteRedirectScreenState();
}

class _ReferralInviteRedirectScreenState
    extends State<ReferralInviteRedirectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    final normalized = widget.code.trim().toUpperCase();
    await PendingReferralStore.save(normalized);
    await ReferralAnalyticsService.referralLinkOpened(normalized);
    if (!mounted) return;
    context.go('/eosb/employee-info?ref=$normalized');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
