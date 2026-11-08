import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/contract_scam_patterns/contract_scam_pattern_models.dart';
import 'package:raabta/features/scam_shield/domain/payment_check_models.dart';

abstract final class ContractScamPatternNavigation {
  static void openNextStep(
    BuildContext context,
    ContractScamPatternNextStep step,
  ) {
    switch (step) {
      case ContractScamPatternNextStep.paymentCheck:
        context.push(
          '/scam-shield/payment-check',
          extra: const PaymentCheckPrefill(),
        );
      case ContractScamPatternNextStep.inCallAssistant:
        context.push('/scam-shield/in-call-assistant');
      case ContractScamPatternNextStep.officialDirectory:
        context.push('/scam-shield/directory');
      case ContractScamPatternNextStep.beforeYouSign:
        context.push('/eosb/employee-info');
      case ContractScamPatternNextStep.contractAnalyzer:
        context.push('/eosb/contract-analysis');
    }
  }
}
