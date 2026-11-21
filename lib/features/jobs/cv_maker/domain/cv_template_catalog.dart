import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';

/// Rule-based ATS compatibility — no AI, static template properties.
enum CvAtsBadgeKind {
  optimized,
  visuallyRich,
}

class CvAtsCompatibility {
  const CvAtsCompatibility({
    required this.badge,
    required this.label,
    required this.hint,
  });

  final CvAtsBadgeKind badge;
  final String label;
  final String hint;

  static CvAtsCompatibility forCv(CvDocument cv) {
    if (cv.templateId == CvTemplateId.premium && cv.hasPhoto) {
      return const CvAtsCompatibility(
        badge: CvAtsBadgeKind.visuallyRich,
        label: 'Visually Rich — may reduce ATS compatibility',
        hint:
            'A photo can affect automated screening. Preview the same content in '
            'Modern before exporting if ATS parse rate matters.',
      );
    }
    return const CvAtsCompatibility(
      badge: CvAtsBadgeKind.optimized,
      label: 'ATS-Optimized',
      hint: 'Single-column layout with standard fonts — recommended for online applications.',
    );
  }
}

/// Visual + copy metadata for each named template.
class CvTemplateDefinition {
  const CvTemplateDefinition({
    required this.id,
    required this.displayName,
    required this.pickerSubtitle,
    required this.supportsPhoto,
    required this.useSerifPreview,
    required this.sectionHeadersAllCaps,
    required this.showSectionRule,
    required this.useBrandAccentInHeader,
    required this.premiumStyledHeader,
    required this.accentColor,
    required this.documentSurface,
  });

  final CvTemplateId id;
  final String displayName;
  final String pickerSubtitle;
  final bool supportsPhoto;
  final bool useSerifPreview;
  final bool sectionHeadersAllCaps;
  final bool showSectionRule;
  final bool useBrandAccentInHeader;
  final bool premiumStyledHeader;
  final Color? accentColor;
  final Color documentSurface;

  CvAtsCompatibility atsFor(CvDocument cv) =>
      CvAtsCompatibility.forCv(cv.copyWith(templateId: id));
}

abstract final class CvTemplateCatalog {
  static const ordered = [
    CvTemplateId.modern,
    CvTemplateId.classic,
    CvTemplateId.professional,
    CvTemplateId.premium,
  ];

  static CvTemplateId parseStoredId(String? raw) {
    switch (raw) {
      case 'minimal':
        return CvTemplateId.classic;
      case 'executive':
        return CvTemplateId.premium;
      case 'classic':
        return CvTemplateId.classic;
      case 'professional':
        return CvTemplateId.professional;
      case 'premium':
        return CvTemplateId.premium;
      case 'modern':
        return CvTemplateId.modern;
      default:
        return CvTemplateId.modern;
    }
  }

  static CvTemplateDefinition definitionFor(CvTemplateId id) {
    return switch (id) {
      CvTemplateId.modern => const CvTemplateDefinition(
          id: CvTemplateId.modern,
          displayName: 'Modern',
          pickerSubtitle:
              'Best for ATS — recommended for most applications.',
          supportsPhoto: false,
          useSerifPreview: false,
          sectionHeadersAllCaps: true,
          showSectionRule: true,
          useBrandAccentInHeader: false,
          premiumStyledHeader: false,
          accentColor: Color(0xFF1A5276),
          documentSurface: Colors.white,
        ),
      CvTemplateId.classic => const CvTemplateDefinition(
          id: CvTemplateId.classic,
          displayName: 'Classic',
          pickerSubtitle:
              'Best for traditional industries — law, government, academia, banking.',
          supportsPhoto: false,
          useSerifPreview: true,
          sectionHeadersAllCaps: false,
          showSectionRule: false,
          useBrandAccentInHeader: false,
          premiumStyledHeader: false,
          accentColor: null,
          documentSurface: Colors.white,
        ),
      CvTemplateId.professional => const CvTemplateDefinition(
          id: CvTemplateId.professional,
          displayName: 'Professional',
          pickerSubtitle:
              'Balanced — professional with a touch of design, works for most corporate and office roles.',
          supportsPhoto: false,
          useSerifPreview: false,
          sectionHeadersAllCaps: true,
          showSectionRule: true,
          useBrandAccentInHeader: true,
          premiumStyledHeader: false,
          accentColor: AppColors.accentGold,
          documentSurface: Colors.white,
        ),
      CvTemplateId.premium => const CvTemplateDefinition(
          id: CvTemplateId.premium,
          displayName: 'Premium',
          pickerSubtitle:
              'Most visually distinctive — great for networking and roles where design sense matters, may reduce ATS parse reliability if a photo is included.',
          supportsPhoto: true,
          useSerifPreview: false,
          sectionHeadersAllCaps: true,
          showSectionRule: true,
          useBrandAccentInHeader: false,
          premiumStyledHeader: true,
          accentColor: AppColors.cyanGlow,
          documentSurface: Color(0xFFFAFBFC),
        ),
    };
  }
}

extension CvDocumentPhotoX on CvDocument {
  bool get hasPhoto =>
      photoLocalPath != null && photoLocalPath!.trim().isNotEmpty;
}

extension CvTemplateIdCatalogX on CvTemplateId {
  CvTemplateDefinition get definition => CvTemplateCatalog.definitionFor(this);

  bool get supportsPhoto => definition.supportsPhoto;
}
