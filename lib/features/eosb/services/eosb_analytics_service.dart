import 'package:flutter/foundation.dart';

/// Anonymous EOSB analytics — debug logging only until Firebase Analytics wired.
class EosbAnalyticsService {
  void trackCalculatorUsed({required double totalEntitlement}) {
    debugPrint('[EOSB Analytics] calculator_used total=$totalEntitlement');
  }

  void trackComparisonViewed({required double difference}) {
    debugPrint('[EOSB Analytics] comparison_viewed diff=$difference');
  }

  void trackDocumentGenerated({required String type}) {
    debugPrint('[EOSB Analytics] document_generated type=$type');
  }
}
