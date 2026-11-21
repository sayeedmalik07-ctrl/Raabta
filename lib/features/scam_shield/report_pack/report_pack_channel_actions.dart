import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_channel_catalog.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_models.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_temp_files.dart';

abstract final class ReportPackChannelActions {
  static Future<void> call(
    ReportPackChannel channel, {
    required ReportPackDraft draft,
  }) async {
    final number = channel.isUserBankLine
        ? draft.bankFraudLine.trim()
        : channel.callNumber;
    if (number == null || number.isEmpty) return;
    await launchUrl(Uri.parse('tel:$number'));
  }

  static Future<void> openVerifyUrl(ReportPackChannel channel) async {
    final url = channel.verifyUrl;
    if (url == null || url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  static Future<void> copyPlainText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Returns false when [userConfirmed] is false (no clipboard write).
  static Future<bool> copyPlainTextIfAllowed({
    required bool userConfirmed,
    required String text,
  }) async {
    if (!userConfirmed) return false;
    await copyPlainText(text);
    return true;
  }

  static Future<void> sharePdfAndText({
    required String plainText,
    required String pdfPath,
  }) async {
    try {
      await Share.shareXFiles(
        [XFile(pdfPath, mimeType: 'application/pdf')],
        text: plainText,
      );
    } catch (_) {
      rethrow;
    }
    await ReportPackTempFiles.markShared(pdfPath);
  }

  static Future<void> mailtoCompose({
    required ReportPackChannel channel,
    required String plainText,
    required String pdfPath,
  }) async {
    final email = channel.email;
    if (email != null && email.isNotEmpty) {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': 'Report', 'body': plainText},
      );
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri);
        if (launched) {
          await ReportPackTempFiles.discard(pdfPath);
        }
        return;
      }
    }
    await sharePdfAndText(plainText: plainText, pdfPath: pdfPath);
  }
}
