import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';

/// Builds a vCard 3.0 payload from existing CV fields (on-device, no AI).
class VcardBuilder {
  static String fromCv(CvDocument cv) {
    final lines = <String>['BEGIN:VCARD', 'VERSION:3.0'];

    final name = cv.fullName.trim();
    if (name.isNotEmpty) {
      lines.add('FN:${_escape(name)}');
      final parts = name.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        lines.add(
          'N:${_escape(parts.last)};${_escape(parts.first)};;;',
        );
      } else {
        lines.add('N:${_escape(name)};;;;');
      }
    }

    final jobTitle = cv.experience
        .map((e) => e.jobTitle.trim())
        .firstWhere((t) => t.isNotEmpty, orElse: () => '');
    if (jobTitle.isNotEmpty) {
      lines.add('TITLE:${_escape(jobTitle)}');
    }

    final phone = _normalizePhone(cv.phone);
    if (phone.isNotEmpty) {
      lines.add('TEL;TYPE=CELL:$phone');
      lines.add('URL:https://wa.me/$phone');
    }

    final email = cv.email.trim();
    if (email.isNotEmpty) {
      lines.add('EMAIL;TYPE=INTERNET:${_escape(email)}');
    }

    if (cv.location.trim().isNotEmpty) {
      lines.add('ADR;TYPE=WORK:;;${_escape(cv.location)};;;;');
    }

    lines.add('END:VCARD');
    return lines.join('\r\n');
  }

  static String _escape(String value) =>
      value.replaceAll('\\', '\\\\').replaceAll(';', r'\;').replaceAll('\n', r'\n');

  static String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('974')) return digits;
    if (digits.length == 8) return '974$digits';
    return digits;
  }
}
