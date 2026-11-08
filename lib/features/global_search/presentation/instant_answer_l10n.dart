import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/global_search/domain/instant_answer.dart';
import 'package:raabta/features/global_search/domain/search_distance_formatter.dart';
import 'package:raabta/features/global_search/presentation/global_search_category_l10n.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';

/// Localized copy for [InstantAnswer] presentation.
abstract final class InstantAnswerL10n {
  static String heading(String locale) {
    return AppShellStrings.t('global_search_instant_answer_heading', locale);
  }

  static String primaryLine(InstantAnswer answer, String locale) {
    return _format(answer.primaryLineKey, locale, answer.primaryLineParams);
  }

  static String? supportingLine(InstantAnswer answer, String locale) {
    final key = answer.supportingLineKey;
    if (key == null) return null;

    if (key == 'global_search_instant_answer_nearest_service_detail') {
      final title = answer.supportingLineParams['title'] ?? '';
      final meters = int.tryParse(answer.supportingLineParams['distance'] ?? '');
      final distance = SearchDistanceFormatter.labelForMeters(meters, locale);
      if (distance == null) return title;
      return AppShellStrings.format(
        key,
        locale,
        params: {'title': title, 'distance': distance},
      );
    }

    return _format(key, locale, answer.supportingLineParams);
  }

  static String? actionLabel(InstantAnswer answer, String locale) {
    final key = answer.actionLabelKey;
    if (key == null) return null;

    final params = Map<String, String>.from(answer.actionLabelParams);
    final categoryKey = params['category'];
    if (categoryKey != null && categoryKey.startsWith('global_search_category_')) {
      params['category'] = AppShellStrings.t(categoryKey, locale);
    }

    return _format(key, locale, params);
  }

  static String semanticLabel(
    InstantAnswer answer,
    String locale, {
    required bool fromCache,
  }) {
    final parts = <String>[
      heading(locale),
      primaryLine(answer, locale),
    ];
    final supporting = supportingLine(answer, locale);
    if (supporting != null && supporting.isNotEmpty) {
      parts.add(supporting);
    }
    if (fromCache) {
      parts.add(AppShellStrings.t('global_search_instant_answer_cached', locale));
    }
    final action = actionLabel(answer, locale);
    if (action != null && action.isNotEmpty) {
      parts.add(action);
    }
    return parts.join('. ');
  }

  static String _format(
    String key,
    String locale,
    Map<String, String> params,
  ) {
    final resolved = Map<String, String>.from(params);
    final categoryKey = resolved['category'];
    if (categoryKey != null && categoryKey.startsWith('global_search_category_')) {
      resolved['category'] = AppShellStrings.t(categoryKey, locale);
    }
    if (resolved.isEmpty) {
      return AppShellStrings.t(key, locale);
    }
    return AppShellStrings.format(key, locale, params: resolved);
  }

  static String categoryLabel(GlobalSearchCategory category, String locale) {
    return GlobalSearchCategoryL10n.label(category, locale);
  }
}
