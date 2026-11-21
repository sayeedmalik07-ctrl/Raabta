import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/eosb/presentation/screens/agency_verification_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/employer_track_record_lookup_screen.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_action_id.dart';

/// Central navigation handler for Global Search action results (S2).
abstract final class SearchActionExecutor {
  static void execute(BuildContext context, GlobalSearchResultItem item) {
    if (!item.isAction) {
      context.push(item.routePath);
      return;
    }

    switch (item.actionId) {
      case SearchActionId.verifyEmployer:
        _openEmployerVerification(context, item);
      case SearchActionId.verifyAgency:
        context.push(AgencyVerificationScreen.route());
      case SearchActionId.calculateEosb:
        context.push('/eosb/employee-info');
      case SearchActionId.scanDocument:
        context.push('/scanner/capture');
      case SearchActionId.convertCurrency:
        _openCurrencyComparator(context, item);
      case SearchActionId.askAi:
        break;
      case null:
        if (item.routePath.isNotEmpty) {
          context.push(item.routePath);
        }
    }
  }

  static void _openEmployerVerification(
    BuildContext context,
    GlobalSearchResultItem item,
  ) {
    final employer = item.queryParameters?['employer']?.trim() ?? '';
    context.push(
      EmployerTrackRecordLookupScreen.route(
        employerName: employer.isEmpty ? null : employer,
      ),
    );
  }

  static void _openCurrencyComparator(
    BuildContext context,
    GlobalSearchResultItem item,
  ) {
    final params = item.queryParameters;
    if (params == null || params.isEmpty) {
      context.push('/money-services/corridor-comparator');
      return;
    }

    final query = params.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');
    context.push('/money-services/corridor-comparator?$query');
  }
}
