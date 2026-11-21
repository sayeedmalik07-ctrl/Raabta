import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_chip_urgency_thresholds.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/services/legal_deadline_service.dart';

void main() {
  group('TruthChipEngineRoutes', () {
    test('homeRoute round-trips fromHomeRoute', () {
      for (final engine in TruthChipEngine.values) {
        expect(
          TruthChipEngineRoutes.fromHomeRoute(engine.homeRoute),
          engine,
        );
      }
    });
  });

  group('TruthChipStatus', () {
    test('invite hides pill and progress', () {
      const status = TruthChipStatus(
        engine: TruthChipEngine.eosb,
        state: TruthChipState.invite,
        tone: TruthChipTone.neutral,
        titleKey: 'home_tool_eosb',
        statusText: 'Check your gratuity',
        freshnessText: '',
        deepLink: '/eosb',
      );
      expect(status.isInvite, isTrue);
      expect(status.showsPill, isFalse);
      expect(status.showsProgressBar, isFalse);
      expect(status.countsTowardAttentionBadge, isFalse);
    });

    test('attention with pill counts toward section badge', () {
      const status = TruthChipStatus(
        engine: TruthChipEngine.tenancy,
        state: TruthChipState.attention,
        tone: TruthChipTone.amber,
        titleKey: 'home_tool_tenancy',
        statusText: 'Lease ends in 45 days',
        pillText: '45d',
        progress: 0.6,
        freshnessText: 'From your lease entry',
        deepLink: '/tenancy',
      );
      expect(status.showsPill, isTrue);
      expect(status.showsProgressBar, isTrue);
      expect(status.countsTowardAttentionBadge, isTrue);
    });

    test('stale suppresses progress bar', () {
      const status = TruthChipStatus(
        engine: TruthChipEngine.healthInsurance,
        state: TruthChipState.stale,
        tone: TruthChipTone.neutral,
        titleKey: 'home_tool_health',
        statusText: 'Last checked a while ago',
        pillText: 'Refresh',
        progress: 0.9,
        freshnessText: 'From your policy check',
        deepLink: '/health-insurance',
      );
      expect(status.showsPill, isTrue);
      expect(status.showsProgressBar, isFalse);
      expect(status.countsTowardAttentionBadge, isFalse);
    });

    test('loading factory', () {
      const loading = TruthChipStatus.loading(
        engine: TruthChipEngine.sponsorshipTransfer,
        titleKey: 'home_tool_transfer',
        deepLink: '/sponsorship-transfer',
      );
      expect(loading.isLoading, isTrue);
      expect(loading.isInvite, isFalse);
      expect(loading.isUnavailable, isFalse);
      expect(loading.statusText, isEmpty);
    });

    test('unavailable is not invite and hides chrome', () {
      const status = TruthChipStatus.unavailable(
        engine: TruthChipEngine.eosb,
        titleKey: 'tool_eosb_title',
        statusText: 'Status unavailable',
        deepLink: '/eosb',
      );
      expect(status.isUnavailable, isTrue);
      expect(status.isInvite, isFalse);
      expect(status.showsPill, isFalse);
      expect(status.countsTowardAttentionBadge, isFalse);
    });
  });

  group('TruthChipUrgencyThresholds — document tracker bands', () {
    test('matches DocumentDeadline.urgency boundaries', () {
      DeadlineUrgency expected(int days) {
        if (days < TruthChipUrgencyThresholds.documentRedBelowDays) {
          return DeadlineUrgency.red;
        }
        if (days <= TruthChipUrgencyThresholds.documentAmberThroughDays) {
          return DeadlineUrgency.amber;
        }
        return DeadlineUrgency.green;
      }

      for (final days in [29, 30, 90, 91]) {
        expect(
          TruthChipUrgencyThresholds.documentUrgencyForDaysRemaining(days),
          expected(days),
        );
      }
    });

    test('tone mapping for document urgency', () {
      expect(
        TruthChipUrgencyThresholds.toneForDocumentUrgency(DeadlineUrgency.red),
        TruthChipTone.red,
      );
      expect(
        TruthChipUrgencyThresholds.toneForDocumentUrgency(
          DeadlineUrgency.amber,
        ),
        TruthChipTone.amber,
      );
      expect(
        TruthChipUrgencyThresholds.toneForDocumentUrgency(
          DeadlineUrgency.green,
        ),
        TruthChipTone.ok,
      );
    });
  });

  group('TruthChipUrgencyThresholds — legal deadline bands', () {
    test('delegates to LegalDeadlineService.urgencyForDaysRemaining', () {
      for (final days in [-1, 0, 14, 15, 60, 61]) {
        expect(
          TruthChipUrgencyThresholds.legalUrgencyForDaysRemaining(days),
          LegalDeadlineService.urgencyForDaysRemaining(days),
        );
      }
    });
  });

  group('TruthChipUrgencyThresholds — stale', () {
    final now = DateTime(2026, 6, 1);

    test('is stale after staleDataAgeDays', () {
      final saved = now.subtract(
        Duration(days: TruthChipUrgencyThresholds.staleDataAgeDays + 1),
      );
      expect(
        TruthChipUrgencyThresholds.isStale(lastSavedAt: saved, now: now),
        isTrue,
      );
    });

    test('is not stale within staleDataAgeDays', () {
      final saved = now.subtract(
        Duration(days: TruthChipUrgencyThresholds.staleDataAgeDays),
      );
      expect(
        TruthChipUrgencyThresholds.isStale(lastSavedAt: saved, now: now),
        isFalse,
      );
    });
  });
}
