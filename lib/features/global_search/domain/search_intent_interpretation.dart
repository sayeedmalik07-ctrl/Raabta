import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Header tone for the intent interpretation strip.
enum SearchIntentInterpretationHeader {
  lookingFor,
  searching,
}

/// Structured segment derived only from [SearchAnalysis] fields.
sealed class SearchIntentInterpretationSegment {
  const SearchIntentInterpretationSegment();
}

final class SearchIntentInterpretationIntentSegment
    extends SearchIntentInterpretationSegment {
  const SearchIntentInterpretationIntentSegment(this.intent);

  final SearchIntent intent;
}

final class SearchIntentInterpretationAreaSegment
    extends SearchIntentInterpretationSegment {
  const SearchIntentInterpretationAreaSegment(this.area);

  final String area;
}

final class SearchIntentInterpretationNearMeSegment
    extends SearchIntentInterpretationSegment {
  const SearchIntentInterpretationNearMeSegment();
}

final class SearchIntentInterpretationMaxPriceSegment
    extends SearchIntentInterpretationSegment {
  const SearchIntentInterpretationMaxPriceSegment(this.amount);

  final int amount;
}

final class SearchIntentInterpretationMinPriceSegment
    extends SearchIntentInterpretationSegment {
  const SearchIntentInterpretationMinPriceSegment(this.amount);

  final int amount;
}

final class SearchIntentInterpretationBedroomsSegment
    extends SearchIntentInterpretationSegment {
  const SearchIntentInterpretationBedroomsSegment(this.count);

  final int count;
}

final class SearchIntentInterpretationTextSegment
    extends SearchIntentInterpretationSegment {
  const SearchIntentInterpretationTextSegment(this.value);

  final String value;
}

final class SearchIntentInterpretationCurrencyPairSegment
    extends SearchIntentInterpretationSegment {
  const SearchIntentInterpretationCurrencyPairSegment({
    required this.from,
    required this.to,
    this.amount,
  });

  final String from;
  final String to;
  final double? amount;
}

/// Deterministic interpretation model for presentation — no AI, no invented filters.
class SearchIntentInterpretation {
  const SearchIntentInterpretation({
    required this.header,
    required this.segments,
  });

  final SearchIntentInterpretationHeader header;
  final List<SearchIntentInterpretationSegment> segments;

  bool get isMeaningful => segments.isNotEmpty;
}

/// Builds a compact interpretation from existing [SearchAnalysis] only.
abstract final class SearchIntentInterpretationBuilder {
  static SearchIntentInterpretation? build(SearchAnalysis? analysis) {
    if (analysis == null) return null;

    final hasStructuredFilters = _hasStructuredFilters(analysis);
    if (analysis.intent == SearchIntent.unknown && !hasStructuredFilters) {
      return null;
    }

    final segments = <SearchIntentInterpretationSegment>[];

    if (analysis.intent != SearchIntent.unknown || hasStructuredFilters) {
      segments.add(
        SearchIntentInterpretationIntentSegment(analysis.intent),
      );
    }

    final area = analysis.area?.trim();
    if (area != null && area.isNotEmpty) {
      segments.add(SearchIntentInterpretationAreaSegment(area));
    }

    if (analysis.nearMe) {
      segments.add(const SearchIntentInterpretationNearMeSegment());
    }

    if (analysis.maxPrice != null) {
      segments.add(SearchIntentInterpretationMaxPriceSegment(analysis.maxPrice!));
    }

    if (analysis.minPrice != null) {
      segments.add(SearchIntentInterpretationMinPriceSegment(analysis.minPrice!));
    }

    if (analysis.bedrooms != null) {
      segments.add(SearchIntentInterpretationBedroomsSegment(analysis.bedrooms!));
    }

    final jobTitle = analysis.jobTitle?.trim();
    if (jobTitle != null && jobTitle.isNotEmpty) {
      segments.add(SearchIntentInterpretationTextSegment(jobTitle));
    }

    final serviceTrade = analysis.serviceTrade?.trim();
    if (serviceTrade != null && serviceTrade.isNotEmpty) {
      segments.add(SearchIntentInterpretationTextSegment(serviceTrade));
    }

    final employer = analysis.employerName?.trim();
    if (employer != null && employer.isNotEmpty) {
      segments.add(SearchIntentInterpretationTextSegment(employer));
    }

    final agency = analysis.agencyName?.trim();
    if (agency != null && agency.isNotEmpty) {
      segments.add(SearchIntentInterpretationTextSegment(agency));
    }

    final visaTopic = analysis.visaTopic?.trim();
    if (visaTopic != null && visaTopic.isNotEmpty) {
      segments.add(SearchIntentInterpretationTextSegment(visaTopic));
    }

    final propertyType = analysis.propertyType?.trim();
    if (propertyType != null && propertyType.isNotEmpty) {
      segments.add(SearchIntentInterpretationTextSegment(propertyType));
    }

    if (analysis.fromCurrency != null && analysis.toCurrency != null) {
      segments.add(
        SearchIntentInterpretationCurrencyPairSegment(
          from: analysis.fromCurrency!,
          to: analysis.toCurrency!,
          amount: analysis.conversionAmount,
        ),
      );
    }

    if (segments.isEmpty) return null;

    return SearchIntentInterpretation(
      header: _headerFor(analysis.intent),
      segments: segments,
    );
  }

  static bool _hasStructuredFilters(SearchAnalysis analysis) {
    return analysis.area?.trim().isNotEmpty == true ||
        analysis.nearMe ||
        analysis.minPrice != null ||
        analysis.maxPrice != null ||
        analysis.minSalary != null ||
        analysis.maxSalary != null ||
        analysis.bedrooms != null ||
        analysis.jobTitle?.trim().isNotEmpty == true ||
        analysis.serviceTrade?.trim().isNotEmpty == true ||
        analysis.employerName?.trim().isNotEmpty == true ||
        analysis.agencyName?.trim().isNotEmpty == true ||
        analysis.visaTopic?.trim().isNotEmpty == true ||
        analysis.propertyType?.trim().isNotEmpty == true ||
        analysis.jobCategory?.trim().isNotEmpty == true ||
        analysis.businessCategory?.trim().isNotEmpty == true ||
        (analysis.fromCurrency != null && analysis.toCurrency != null);
  }

  static SearchIntentInterpretationHeader _headerFor(SearchIntent intent) {
    return switch (intent) {
      SearchIntent.findJob ||
      SearchIntent.findHousing ||
      SearchIntent.findBusiness ||
      SearchIntent.findService ||
      SearchIntent.findDoctor =>
        SearchIntentInterpretationHeader.lookingFor,
      _ => SearchIntentInterpretationHeader.searching,
    };
  }
}
