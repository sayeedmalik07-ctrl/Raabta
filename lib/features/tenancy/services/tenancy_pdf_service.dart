import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry.dart';
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_strings.dart';
import 'package:raabta/features/case_timeline/services/case_timeline_service.dart';
import 'package:raabta/features/tenancy/data/tenancy_dispute_checklist_catalog.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_claim_basis_builder.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_condition_room_matcher.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';

/// Dispute preparation packet PDF — cover sheet only, NOT a filed Arabic claim form.
class TenancyPdfService {
  Future<File> generateDisputePacket({
    required TenancyLeaseInput input,
    required TenancyComplianceResult result,
    required Set<String> collectedItemIds,
    required String locale,
    List<CaseTimelineEntry> timelineEntries = const [],
  }) async {
    final claimKeys = TenancyClaimBasisBuilder.basisKeys(
      result: result,
      input: input,
    );

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              TenancyStrings.t('tenancy_packet_title', locale),
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            TenancyStrings.t('tenancy_packet_disclaimer', locale),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            TenancyStrings.t('tenancy_law_disambiguation', locale),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            TenancyStrings.t('tenancy_packet_summary_heading', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          if (input.landlordName.isNotEmpty)
            pw.Text(
              TenancyStrings.format('tenancy_packet_landlord', locale, {
                'name': input.landlordName,
              }),
            ),
          if (input.monthlyRent > 0)
            pw.Text(
              TenancyStrings.format('tenancy_packet_rent', locale, {
                'amount': input.monthlyRent.toStringAsFixed(0),
              }),
            ),
          if (input.securityDeposit > 0)
            pw.Text(
              TenancyStrings.format('tenancy_packet_deposit', locale, {
                'amount': input.securityDeposit.toStringAsFixed(0),
              }),
            ),
          pw.SizedBox(height: 16),
          pw.Text(
            TenancyStrings.t('tenancy_packet_claim_basis_heading', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...claimKeys.map(
            (key) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text('• ${TenancyStrings.t(key, locale)}'),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            TenancyStrings.t('tenancy_packet_docs_heading', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...TenancyDisputeChecklistCatalog.items.map((def) {
            final collected = collectedItemIds.contains(def.id);
            final mark = collected ? '[x]' : '[ ]';
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                '$mark ${TenancyStrings.t(def.titleKey, locale)}',
              ),
            );
          }),
          if (timelineEntries.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              CaseTimelineStrings.t('ct_packet_appendix_heading', locale),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            ...CaseTimelineService.sortedChronologically(timelineEntries).map(
              (e) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  '${e.entryDate.toIso8601String().split('T').first} — ${e.title}',
                ),
              ),
            ),
          ],
          pw.SizedBox(height: 16),
          pw.Text(
            TenancyStrings.t('tenancy_packet_not_claim_form', locale),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/tenancy_dispute_packet_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<void> sharePacket(File file, {required String locale}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: TenancyStrings.t('tenancy_packet_share_text', locale),
    );
  }

  Future<File> generateConditionReport({
    required TenancyLeaseInput input,
    required TenancyConditionRecord moveIn,
    TenancyConditionRecord? moveOut,
    required String locale,
  }) async {
    final comparisons = moveOut != null
        ? TenancyConditionRoomMatcher.compare(
            moveInRooms: moveIn.rooms,
            moveOutRooms: moveOut.rooms,
          )
        : const <TenancyConditionRoomComparison>[];

    final imageCache = await _loadVaultImageBytes([
      ...moveIn.rooms.expand((r) => r.photos),
      if (moveOut != null) ...moveOut.rooms.expand((r) => r.photos),
    ]);
    final moveInSections = _roomSections(moveIn, locale, imageCache);
    final moveOutSections = moveOut != null
        ? _roomSections(moveOut, locale, imageCache)
        : const <pw.Widget>[];

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              TenancyStrings.t('tenancy_condition_report_pdf_title', locale),
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            TenancyStrings.t('tenancy_packet_disclaimer', locale),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          if (input.monthlyRent > 0)
            pw.Text(
              TenancyStrings.format('tenancy_packet_rent', locale, {
                'amount': input.monthlyRent.toStringAsFixed(0),
              }),
            ),
          if (input.securityDeposit > 0)
            pw.Text(
              TenancyStrings.format('tenancy_packet_deposit', locale, {
                'amount': input.securityDeposit.toStringAsFixed(0),
              }),
            ),
          pw.SizedBox(height: 16),
          pw.Text(
            TenancyStrings.t('tenancy_condition_move_in', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          ...moveInSections,
          if (moveOut != null) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              TenancyStrings.t('tenancy_condition_move_out', locale),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            ...moveOutSections,
          ],
          if (comparisons.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              TenancyStrings.t('tenancy_condition_comparison_notes_heading', locale),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            for (final cmp in comparisons)
              if (moveOut?.roomComparisonNotes[cmp.displayLabel]?.isNotEmpty ??
                  false)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(
                    '${cmp.displayLabel}: ${moveOut!.roomComparisonNotes[cmp.displayLabel]}',
                  ),
                ),
          ],
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/tenancy_condition_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<Map<String, Uint8List>> _loadVaultImageBytes(
    Iterable<TenancyConditionPhoto> photos,
  ) async {
    final cache = <String, Uint8List>{};
    final ids = photos.map((p) => p.photoRef).where((id) => id.isNotEmpty).toSet();
    if (ids.isEmpty) return cache;

    for (final id in ids) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('scanned_documents')
            .doc(id)
            .get();
        final data = snap.data();
        if (data == null) continue;

        final paths = <String>[];
        final localPath = data['localImagePath'] as String?;
        if (localPath != null && localPath.isNotEmpty) {
          paths.add(localPath);
        }
        final pagePaths = data['pagePaths'];
        if (pagePaths is List) {
          for (final path in pagePaths) {
            if (path is String && path.isNotEmpty) paths.add(path);
          }
        }

        for (final path in paths) {
          final file = File(path);
          if (file.existsSync()) {
            cache[id] = await file.readAsBytes();
            break;
          }
        }
      } catch (_) {
        continue;
      }
    }
    return cache;
  }

  List<pw.Widget> _roomSections(
    TenancyConditionRecord record,
    String locale,
    Map<String, Uint8List> imageCache,
  ) {
    final widgets = <pw.Widget>[];
    for (final room in record.rooms) {
      widgets.add(pw.SizedBox(height: 8));
      widgets.add(
        pw.Text(room.roomLabel, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      );
      for (final photo in room.photos) {
        final t = photo.capturedAt.toLocal();
        final time =
            '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
        final source = photo.timestampSource ==
                TenancyConditionTimestampSource.vaultScanDate
            ? TenancyStrings.t('tenancy_condition_photo_time_vault', locale)
            : TenancyStrings.t('tenancy_condition_photo_time_linked', locale);
        widgets.add(pw.Text('  • $time — $source'));
        if (photo.note.isNotEmpty) {
          widgets.add(pw.Text('    ${photo.note}'));
        }

        final bytes = imageCache[photo.photoRef];
        if (bytes != null) {
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4, bottom: 8),
              child: pw.Image(
                pw.MemoryImage(bytes),
                width: 220,
                fit: pw.BoxFit.contain,
              ),
            ),
          );
        } else {
          widgets.add(
            pw.Text(
              TenancyStrings.format(
                'tenancy_condition_pdf_photo_unavailable',
                locale,
                {'ref': photo.photoRef},
              ),
              style: const pw.TextStyle(fontSize: 9),
            ),
          );
        }
      }
    }
    return widgets;
  }

  Future<void> shareConditionReport(File file, {required String locale}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: TenancyStrings.t('tenancy_condition_report_share', locale),
    );
  }
}

final tenancyPdfServiceProvider = Provider<TenancyPdfService>(
  (ref) => TenancyPdfService(),
);
