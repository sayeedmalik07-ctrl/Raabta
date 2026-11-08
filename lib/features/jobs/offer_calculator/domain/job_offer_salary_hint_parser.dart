/// Extracts a numeric salary hint from free-text listing salary fields.
abstract final class JobOfferSalaryHintParser {
  JobOfferSalaryHintParser._();

  static double? fromListingText(String? salaryText) {
    if (salaryText == null || salaryText.trim().isEmpty) return null;
    final match = RegExp(r'[\d,]+').firstMatch(salaryText);
    if (match == null) return null;
    return double.tryParse(match.group(0)!.replaceAll(',', ''));
  }
}
