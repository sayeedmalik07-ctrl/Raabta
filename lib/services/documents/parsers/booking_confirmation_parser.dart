import 'package:raabta/features/trip_planner/domain/models/trip_booking_segment.dart';
import 'package:raabta/services/documents/document_extraction_config.dart';
import 'package:raabta/services/documents/utils/date_parse_utils.dart';
import 'package:raabta/services/documents/utils/ocr_text_utils.dart';

class BookingConfirmationParseResult {
  const BookingConfirmationParseResult({
    this.bookingType,
    this.destinationCity,
    this.destinationCountry,
    this.startDateTime,
    this.endDateTime,
    this.confirmationNumber,
    this.providerName,
    this.guestName,
    required this.confidence,
    this.fieldConfidence = const {},
  });

  final TripBookingType? bookingType;
  final String? destinationCity;
  final String? destinationCountry;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final String? confirmationNumber;
  final String? providerName;
  final String? guestName;
  final double confidence;
  final Map<String, double> fieldConfidence;
}

/// Deterministic booking confirmation extraction before Claude fallback.
class BookingConfirmationParser {
  BookingConfirmationParser._();

  static const _flightKeywords = [
    'flight',
    'airline',
    'boarding pass',
    'pnr',
    'record locator',
    'departure',
    'arrival',
    'passenger',
    'itinerary',
    'e-ticket',
    'رحلة',
    'طيران',
    'مغادرة',
    'وصول',
  ];

  static const _hotelKeywords = [
    'hotel',
    'check-in',
    'check in',
    'check-out',
    'check out',
    'guest',
    'room',
    'reservation',
    'فندق',
    'تسجيل الوصول',
    'مغادرة',
    'حجز',
  ];

  static const _carKeywords = [
    'car rental',
    'rental car',
    'vehicle',
    'pick-up',
    'pick up',
    'drop-off',
    'drop off',
    'hertz',
    'avis',
    'enterprise',
    'budget rent',
    'تأجير',
    'سيارة',
  ];

  static const _confirmationLabels = [
    'confirmation',
    'confirmation number',
    'confirmation #',
    'booking reference',
    'booking ref',
    'reservation number',
    'record locator',
    'pnr',
    'reference number',
    'itinerary number',
    'رقم التأكيد',
    'مرجع الحجز',
  ];

  static const _checkInLabels = [
    'check-in',
    'check in',
    'arrival',
    'departure',
    'depart',
    'pick-up',
    'pick up',
    'from',
    'تسجيل الوصول',
    'مغادرة',
  ];

  static const _checkOutLabels = [
    'check-out',
    'check out',
    'return',
    'arrival',
    'drop-off',
    'drop off',
    'to',
    'until',
    'مغادرة',
    'عودة',
    'وصول',
  ];

  static const _guestLabels = [
    'guest name',
    'guest',
    'passenger',
    'traveler',
    'traveller',
    'name of guest',
    'اسم الضيف',
    'المسافر',
  ];

  static BookingConfirmationParseResult? parse(String ocrText) {
    if (!_looksLikeBookingConfirmation(ocrText)) return null;

    final text = OcrTextUtils.normalize(ocrText);
    final bookingType = _inferType(text);
    final confirmationNumber = _extractConfirmationNumber(text);
    final providerName = _extractProvider(text, bookingType);
    final guestName = _extractGuestName(text);
    final destination = _extractDestination(text);
    final startDateTime = _extractStartDateTime(text, bookingType);
    final endDateTime = _extractEndDateTime(text, bookingType, startDateTime);

    final fieldConfidence = <String, double>{};
    if (bookingType != null) fieldConfidence['bookingType'] = 0.85;
    if (confirmationNumber != null) {
      fieldConfidence['confirmationNumber'] =
          confirmationNumber.length >= 5 ? 0.88 : 0.65;
    }
    if (providerName != null) fieldConfidence['providerName'] = 0.8;
    if (guestName != null) fieldConfidence['guestName'] = 0.75;
    if (destination.city != null) fieldConfidence['destinationCity'] = 0.78;
    if (destination.country != null) {
      fieldConfidence['destinationCountry'] = 0.72;
    }
    if (startDateTime != null) fieldConfidence['startDateTime'] = 0.82;
    if (endDateTime != null) fieldConfidence['endDateTime'] = 0.8;

    var confidence = 0.0;
    if (bookingType != null) confidence += 0.15;
    if (confirmationNumber != null) confidence += 0.25;
    if (startDateTime != null) confidence += 0.2;
    if (endDateTime != null) confidence += 0.15;
    if (providerName != null) confidence += 0.1;
    if (destination.city != null) confidence += 0.1;
    if (guestName != null) confidence += 0.05;

    confidence = confidence.clamp(0.0, 0.92);

    if (confidence < 0.45 &&
        confirmationNumber == null &&
        startDateTime == null) {
      return null;
    }

    if (confidence <
        DocumentExtractionConfig.localExtractionConfidenceThreshold) {
      return BookingConfirmationParseResult(
        bookingType: bookingType,
        destinationCity: destination.city,
        destinationCountry: destination.country,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        confirmationNumber: confirmationNumber,
        providerName: providerName,
        guestName: guestName,
        confidence: confidence,
        fieldConfidence: fieldConfidence,
      );
    }

    return BookingConfirmationParseResult(
      bookingType: bookingType,
      destinationCity: destination.city,
      destinationCountry: destination.country,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      confirmationNumber: confirmationNumber,
      providerName: providerName,
      guestName: guestName,
      confidence: confidence,
      fieldConfidence: fieldConfidence,
    );
  }

  static bool _looksLikeBookingConfirmation(String text) {
    final lower = text.toLowerCase();
    final hits = [
      ..._flightKeywords,
      ..._hotelKeywords,
      ..._carKeywords,
      'confirmation',
      'booking',
      'reservation',
      'itinerary',
      'حجز',
      'تأكيد',
    ].where((k) => lower.contains(k.toLowerCase())).length;

    return hits >= 2 ||
        (hits >= 1 && _confirmationLabels.any((l) => lower.contains(l)));
  }

  static TripBookingType? _inferType(String text) {
    final lower = text.toLowerCase();
    final flightScore =
        _flightKeywords.where((k) => lower.contains(k.toLowerCase())).length;
    final hotelScore =
        _hotelKeywords.where((k) => lower.contains(k.toLowerCase())).length;
    final carScore =
        _carKeywords.where((k) => lower.contains(k.toLowerCase())).length;

    if (flightScore >= hotelScore && flightScore >= carScore && flightScore > 0) {
      return TripBookingType.flight;
    }
    if (carScore > hotelScore && carScore > 0) {
      return TripBookingType.carRental;
    }
    if (hotelScore > 0) return TripBookingType.hotel;
    return null;
  }

  static String? _extractConfirmationNumber(String text) {
    final ordered = [..._confirmationLabels]
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final label in ordered) {
      final pattern = RegExp(
        '${RegExp.escape(label)}\\s*[#:]?\\s*([A-Z0-9]{4,12})',
        caseSensitive: false,
      );
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(1)?.trim();
    }

    final generic = RegExp(
      r'\b(?:PNR|Record\s+Locator)\s*[#:]?\s*([A-Z0-9]{5,10})\b',
      caseSensitive: false,
    );
    return generic.firstMatch(text)?.group(1)?.trim();
  }

  static String? _extractProvider(String text, TripBookingType? type) {
    const airlines = [
      'Qatar Airways',
      'Emirates',
      'Etihad',
      'Flydubai',
      'Turkish Airlines',
      'British Airways',
      'Lufthansa',
      'Air India',
      'IndiGo',
      'SpiceJet',
    ];
    const hotels = [
      'Marriott',
      'Hilton',
      'Hyatt',
      'Sheraton',
      'InterContinental',
      'Radisson',
      'Mövenpick',
      'Movenpick',
      'Four Seasons',
      'St. Regis',
      'W Doha',
      'Mandarin Oriental',
    ];
    const carRentals = [
      'Hertz',
      'Avis',
      'Enterprise',
      'Budget',
      'Sixt',
      'Europcar',
      'Thrifty',
    ];

    final candidates = switch (type) {
      TripBookingType.flight => airlines,
      TripBookingType.hotel => hotels,
      TripBookingType.carRental => carRentals,
      null => [...airlines, ...hotels, ...carRentals],
    };

    for (final name in candidates) {
      if (text.toLowerCase().contains(name.toLowerCase())) return name;
    }

    return OcrTextUtils.firstLineLikelyVendor(text);
  }

  static String? _extractGuestName(String text) {
    for (final label in _guestLabels) {
      final pattern = RegExp(
        '$label[:\\s]+([^\\n\\r]{2,60})',
        caseSensitive: false,
      );
      final match = pattern.firstMatch(text);
      if (match != null) {
        final raw = match.group(1)?.trim();
        if (raw != null && RegExp(r"^[A-Za-z .'-]{2,60}$").hasMatch(raw)) {
          return raw;
        }
      }
    }
    return null;
  }

  static ({String? city, String? country}) _extractDestination(String text) {
    const cities = [
      'Doha',
      'Lusail',
      'Al Wakrah',
      'Al Khor',
      'Hamad International',
    ];
    const countries = ['Qatar', 'UAE', 'United Arab Emirates', 'قطر'];

    String? city;
    String? country;
    for (final c in cities) {
      if (RegExp('\\b${RegExp.escape(c)}\\b', caseSensitive: false)
          .hasMatch(text)) {
        city = c == 'Hamad International' ? 'Doha' : c;
        break;
      }
    }
    for (final c in countries) {
      if (text.toLowerCase().contains(c.toLowerCase())) {
        country = c == 'قطر' ? 'Qatar' : c;
        break;
      }
    }
    if (city != null && country == null && city == 'Doha') {
      country = 'Qatar';
    }
    return (city: city, country: country);
  }

  static DateTime? _extractStartDateTime(
    String text,
    TripBookingType? type,
  ) {
    final labels = type == TripBookingType.flight
        ? ['departure', 'depart', 'outbound', ..._checkInLabels]
        : _checkInLabels;
    return DateParseUtils.parseNearLabels(text, labels) ??
        DateParseUtils.parseFirst(text);
  }

  static DateTime? _extractEndDateTime(
    String text,
    TripBookingType? type,
    DateTime? start,
  ) {
    final labels = type == TripBookingType.flight
        ? ['arrival', 'return', 'inbound', ..._checkOutLabels]
        : _checkOutLabels;
    final parsed = DateParseUtils.parseNearLabels(text, labels);
    if (parsed != null &&
        start != null &&
        parsed.isAtSameMomentAs(start)) {
      return null;
    }
    return parsed;
  }
}
