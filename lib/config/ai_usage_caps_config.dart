import 'package:raabta/features/arabic_companion/arabic_companion_config.dart';
import 'package:raabta/features/post_engine/config/post_engine_config.dart';
import 'package:raabta/features/scam_shield/scam_shield_config.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_planner_config.dart';

/// Central AI usage cap constants — extend here as new gated features ship.
abstract final class AiUsageCapsConfig {
  static const scamShieldMonthlyFree = ScamShieldConfig.freeMonthlyAiLimit;
  static const scamShieldMonthlyPremium = ScamShieldConfig.premiumMonthlyAiLimit;
  static const scamShieldRequestType = ScamShieldConfig.aiRequestType;

  static const arabicCompanionMonthlyFree =
      ArabicCompanionConfig.freeMonthlyAiLimit;
  static const arabicCompanionRequestType =
      ArabicCompanionConfig.aiRequestType;

  static const tripPlannerBookingImportRequestType =
      TripPlannerConfig.bookingImportRequestType;

  // Post Engine — PENDING SAYEED CONFIRMATION before production enforcement.
  static const postEngineDetectCategoryRequestType =
      PostEngineConfig.detectCategoryRequestType;
  static const postEngineExtractAttributesRequestType =
      PostEngineConfig.extractAttributesRequestType;
  static const postEngineGenerateTitleRequestType =
      PostEngineConfig.generateTitleRequestType;
  static const postEngineMonthlyDetectCategory =
      PostEngineConfig.freeMonthlyDetectCategory;
  static const postEngineMonthlyExtractAttributes =
      PostEngineConfig.freeMonthlyExtractAttributes;
  static const postEngineMonthlyGenerateTitle =
      PostEngineConfig.freeMonthlyGenerateTitle;
  static const postEngineExtractServiceRequestRequestType =
      PostEngineConfig.extractServiceRequestRequestType;
  static const postEngineMonthlyExtractServiceRequest =
      PostEngineConfig.freeMonthlyExtractServiceRequest;
}
