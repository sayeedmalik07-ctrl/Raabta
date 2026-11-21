import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:raabta/features/eosb/data/migrant_support_catalog.dart';
import 'package:raabta/models/intelligence/evidence_entry.dart';
import 'package:raabta/services/intelligence/evidence_service.dart';
import 'package:share_plus/share_plus.dart';

/// Summary of a Document Vault attachment referenced by an evidence entry.
class EvidenceAttachmentSummary {
  const EvidenceAttachmentSummary({
    required this.documentId,
    required this.label,
    this.category,
    this.imageUrl,
    this.localImagePath,
    this.metadataLine,
  });

  final String documentId;
  final String label;
  final String? category;
  final String? imageUrl;
  final String? localImagePath;
  final String? metadataLine;
}

/// ADLSA Unified Complaints Portal — same channel as EOSB dispute routing.
const evidenceExportPortalUrl = 'https://www.mol.gov.qa';

/// Labour evidence trail PDF — follows [EosbPdfService] / [TenancyPdfService] pattern.
class EvidencePdfService {
  static const versionLabel = 'Raabta Evidence Trail v1';

  /// Builds ordered plain-text lines for each entry (testable without PDF I/O).
  static List<String> buildEntryLines({
    required List<EvidenceEntry> entries,
    required Map<String, EvidenceAttachmentSummary> attachmentsById,
  }) {
    final ordered = EvidenceService.sortedForExport(entries);
    return ordered.map((entry) {
      final claim = EvidenceClaimTypes.labelFor(entry.claimType);
      final date = _formatDate(entry.entryDate);
      final attachment = entry.attachmentDocumentId == null
          ? ''
          : ' | Attachment: ${attachmentsById[entry.attachmentDocumentId]?.label ?? entry.attachmentDocumentId}';
      final metadata = entry.attachmentDocumentId == null
          ? ''
          : () {
              final line = entry.attachmentMetadata.displayLine(
                fallbackRecordedAt: entry.createdAt,
              );
              return line.isEmpty ? '' : ' | $line';
            }();
      final amend = entry.supersedesEntryId == null
          ? ''
          : ' | Supplements entry ${entry.supersedesEntryId}';
      return '$date - $claim - ${entry.note.trim()}$attachment$metadata$amend';
    }).toList();
  }

  Future<File> generateTrail({
    required List<EvidenceEntry> entries,
    required Map<String, EvidenceAttachmentSummary> attachmentsById,
    String workerName = 'Worker',
    String employerName = '',
    DateTime? generatedAt,
  }) async {
    final bytes = await buildTrailPdfBytes(
      entries: entries,
      attachmentsById: attachmentsById,
      workerName: workerName,
      employerName: employerName,
      generatedAt: generatedAt,
    );
    final generated = generatedAt ?? DateTime.now();
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/evidence_trail_${generated.millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<Uint8List> buildTrailPdfBytes({
    required List<EvidenceEntry> entries,
    required Map<String, EvidenceAttachmentSummary> attachmentsById,
    String workerName = 'Worker',
    String employerName = '',
    DateTime? generatedAt,
  }) async {
    final ordered = EvidenceService.sortedForExport(entries);
    final generated = generatedAt ?? DateTime.now();
    final claimTypes = ordered.map((e) => e.claimType).toSet();
    final attachmentCount =
        ordered.where((e) => e.attachmentDocumentId != null).length;

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Raabta Labour Evidence Trail',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(versionLabel, style: const pw.TextStyle(fontSize: 9)),
          pw.Text(
            'Informational record only - not legal advice. '
            'Human-written entries preserved in chronological order. '
            'For official filing use ADLSA channels (below) - Raabta does not submit on your behalf.',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Cover summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pw.Text('Worker: $workerName'),
                    if (employerName.isNotEmpty) pw.Text('Employer: $employerName'),
                    pw.Text('Entries: ${ordered.length}'),
                    pw.Text('Claim types: ${claimTypes.map(EvidenceClaimTypes.labelFor).join('; ')}'),
                    pw.Text('Attachments referenced: $attachmentCount'),
                    pw.Text('Generated: ${generated.toLocal()}'),
                  ],
                ),
              ),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: evidenceExportPortalUrl,
                width: 72,
                height: 72,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Scan for ADLSA Unified Complaints Portal (mol.gov.qa, NAS login). '
            'Helpline: ADLSA 16008 (24/7). SMS: 5+QID to 92727.',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Chronological evidence log',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ...ordered.asMap().entries.map((indexed) {
            final index = indexed.key + 1;
            final entry = indexed.value;
            final attachment = entry.attachmentDocumentId == null
                ? null
                : attachmentsById[entry.attachmentDocumentId];
            final metadataLine = entry.attachmentDocumentId == null
                ? ''
                : entry.attachmentMetadata.displayLine(
                    fallbackRecordedAt: entry.createdAt,
                  );
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '$index. ${_formatDate(entry.entryDate)} - '
                    '${EvidenceClaimTypes.labelFor(entry.claimType)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('Recorded: ${_formatDateTime(entry.createdAt)}'),
                  if (entry.supersedesEntryId != null)
                    pw.Text(
                      'Supplements earlier entry ${entry.supersedesEntryId}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  pw.SizedBox(height: 4),
                  pw.Text(entry.note.trim()),
                  if (attachment != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Attachment (Document Vault): ${attachment.label}'
                      '${attachment.category != null ? ' [${attachment.category}]' : ''} '
                      '(id: ${attachment.documentId})',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    if (metadataLine.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        metadataLine,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ],
                ],
              ),
            );
          }),
          pw.SizedBox(height: 12),
          pw.Text(
            'Official channels (navigate only - not filed by Raabta):',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          ...MigrantSupportCatalog.qatarProcedureChannels.map(
            (channel) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                '- ${channel.url ?? channel.titleKey}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  Future<void> shareTrail(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text:
          'Raabta labour evidence trail — for your records. '
          'File officially via ADLSA Unified Complaints Portal (mol.gov.qa).',
    );
  }

  static String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static String _formatDateTime(DateTime dt) => dt.toLocal().toString();
}

final evidencePdfServiceProvider = Provider<EvidencePdfService>(
  (ref) => EvidencePdfService(),
);
