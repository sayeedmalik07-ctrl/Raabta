import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:raabta/services/documents/utils/date_parse_utils.dart';
import 'package:raabta/services/documents/utils/ocr_text_utils.dart';

/// JSON-driven Qatar utility bill extractor (Kahramaa, Ooredoo, Vodafone, …).
class BillProviderParser {
  BillProviderParser._();

  static List<BillProviderTemplate>? _templates;
  static Future<void>? _loadFuture;

  static Future<void> ensureLoaded() {
    _loadFuture ??= _loadTemplates();
    return _loadFuture!;
  }

  static Future<void> _loadTemplates() async {
    final raw = await rootBundle.loadString(
      'assets/documents/bill_provider_templates.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = (json['providers'] as List<dynamic>)
        .map((e) => BillProviderTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
    _templates = list;
  }

  static BillParseResult? parse(String ocrText) {
    final templates = _templates;
    if (templates == null || templates.isEmpty) return null;

    final matched = _detectProvider(ocrText, templates);
    if (matched == null) return null;

    final account = OcrTextUtils.valueAfterLabel(
          ocrText,
          matched.accountLabels,
          valuePattern: RegExp(r'^[\d\s\-/]+$'),
        ) ??
        _regexFirst(ocrText, matched.accountRegex);

    final amount = OcrTextUtils.amountNearAnchors(ocrText, matched.amountLabels) ??
        _regexAmount(ocrText, matched.amountRegex);

    final dueDate =
        DateParseUtils.parseNearLabels(ocrText, matched.dueDateLabels);

    var confidence = 0.0;
    if (amount != null && amount > 0) confidence += 0.4;
    if (dueDate != null) confidence += 0.25;
    if (account != null && account.isNotEmpty) confidence += 0.25;
    confidence += 0.1; // provider keyword hit

    final normalizedAccount =
        account?.replaceAll(RegExp(r'[\s\-/]'), '').trim();

    return BillParseResult(
      provider: matched.displayName,
      amount: amount,
      dueDate: dueDate,
      accountNumber:
          normalizedAccount?.isNotEmpty == true ? normalizedAccount : null,
      confidence: confidence.clamp(0.0, 0.93),
    );
  }

  static BillProviderTemplate? _detectProvider(
    String text,
    List<BillProviderTemplate> templates,
  ) {
    for (final template in templates) {
      if (OcrTextUtils.containsAny(text, template.detectKeywords)) {
        return template;
      }
    }
    return null;
  }

  static String? _regexFirst(String text, String pattern) {
    final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
    return match?.group(1)?.trim();
  }

  static double? _regexAmount(String text, String pattern) {
    final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
    if (match == null) return null;
    final raw = match.group(1)?.replaceAll(',', '');
    return raw != null ? double.tryParse(raw) : null;
  }
}

class BillProviderTemplate {
  const BillProviderTemplate({
    required this.id,
    required this.displayName,
    required this.detectKeywords,
    required this.accountLabels,
    required this.amountLabels,
    required this.dueDateLabels,
    required this.amountRegex,
    required this.accountRegex,
  });

  factory BillProviderTemplate.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) =>
        (json[key] as List<dynamic>).map((e) => e as String).toList();

    return BillProviderTemplate(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      detectKeywords: strings('detectKeywords'),
      accountLabels: strings('accountLabels'),
      amountLabels: strings('amountLabels'),
      dueDateLabels: strings('dueDateLabels'),
      amountRegex: json['amountRegex'] as String,
      accountRegex: json['accountRegex'] as String,
    );
  }

  final String id;
  final String displayName;
  final List<String> detectKeywords;
  final List<String> accountLabels;
  final List<String> amountLabels;
  final List<String> dueDateLabels;
  final String amountRegex;
  final String accountRegex;
}

class BillParseResult {
  const BillParseResult({
    this.provider,
    this.amount,
    this.dueDate,
    this.accountNumber,
    required this.confidence,
  });

  final String? provider;
  final double? amount;
  final DateTime? dueDate;
  final String? accountNumber;
  final double confidence;
}
