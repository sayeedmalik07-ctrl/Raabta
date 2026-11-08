import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:raabta/core/l10n/app_locale.dart';

/// Bundled PDF fonts for certificate rendering.
class PdfFontBundle {
  const PdfFontBundle({required this.base, required this.bold});

  final pw.Font base;
  final pw.Font bold;
}

/// Loads locale-appropriate PDF fonts — Noto Sans Arabic for RTL locales.
abstract final class PdfFontLoader {
  static PdfFontBundle? _rtlCache;
  static PdfFontBundle? _ltrCache;
  static Future<PdfFontBundle>? _bilingualLatinFuture;
  static Future<PdfFontBundle>? _bilingualArabicFuture;

  static Future<PdfFontBundle> forLocale(String locale) async {
    final normalized = AppLocale.normalize(locale);
    if (AppLocale.isRtl(normalized)) {
      _rtlCache ??= await _loadRtl();
      return _rtlCache!;
    }
    _ltrCache ??= _loadLtr();
    return _ltrCache!;
  }

  /// Latin + Arabic bundles for mixed-script PDFs (e.g. report-ready pack).
  static Future<({PdfFontBundle latin, PdfFontBundle arabic})> forBilingualPack() async {
    _bilingualLatinFuture ??= Future.value(_loadLtr());
    _bilingualArabicFuture ??= _loadRtl();
    final results = await Future.wait([
      _bilingualLatinFuture!,
      _bilingualArabicFuture!,
    ]);
    return (latin: results[0], arabic: results[1]);
  }

  /// Clears cached fonts — for tests only.
  static void clearCacheForTests() {
    _rtlCache = null;
    _ltrCache = null;
    _bilingualLatinFuture = null;
    _bilingualArabicFuture = null;
  }

  static Future<PdfFontBundle> _loadRtl() async {
    final data = await rootBundle.load('assets/fonts/NotoSansArabic.ttf');
    final font = pw.Font.ttf(data);
    return PdfFontBundle(base: font, bold: font);
  }

  static PdfFontBundle _loadLtr() {
    return PdfFontBundle(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );
  }
}
