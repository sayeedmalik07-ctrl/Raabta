import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:share_plus/share_plus.dart';

class DocScannerScreen extends StatefulWidget {
  const DocScannerScreen({super.key});

  @override
  State<DocScannerScreen> createState() => _DocScannerScreenState();
}

class _DocScannerScreenState extends State<DocScannerScreen> {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _imagePicker = ImagePicker();

  String? _scannedImagePath;
  String _extractedText = '';
  String _aiAnalysis = '';
  bool _isScanning = false;
  bool _isProcessing = false;
  bool _isExporting = false;

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _scanWithCamera() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      _showSnack('Camera scanning only available on iPhone/Android');
      return;
    }
    setState(() {
      _isScanning = true;
      _aiAnalysis = '';
      _extractedText = '';
      _scannedImagePath = null;
    });
    try {
      final List<String>? pictures =
          await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: false,
      );
      if (pictures != null && pictures.isNotEmpty) {
        setState(() {
          _scannedImagePath = pictures.first;
        });
        await _processImage(pictures.first);
      }
    } catch (e) {
      _showSnack('Camera scan failed: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _uploadFromGallery() async {
    setState(() {
      _isScanning = true;
      _aiAnalysis = '';
      _extractedText = '';
      _scannedImagePath = null;
    });
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked != null) {
        setState(() {
          _scannedImagePath = picked.path;
        });
        await _processImage(picked.path);
      }
    } catch (e) {
      _showSnack('Gallery upload failed: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _processImage(String path) async {
    setState(() {
      _isProcessing = true;
    });
    try {
      final inputImage = InputImage.fromFilePath(path);
      final recognized = await _textRecognizer.processImage(inputImage);
      setState(() {
        _extractedText = recognized.text;
      });
      await _analyzeWithAI(recognized.text);
    } catch (e) {
      _showSnack('Processing failed: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _analyzeWithAI(String text) async {
    if (text.trim().isEmpty) {
      setState(() {
        _aiAnalysis = 'No readable text found in this document.';
      });
      return;
    }
    try {
      final res = await http.post(
        Uri.parse(
          'https://raabta-backend-production.up.railway.app/api/analyze-document',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'language': 'auto'}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _aiAnalysis =
              data['analysis'] as String? ?? 'Document analyzed successfully.';
        });
      } else {
        setState(() {
          _aiAnalysis =
              'Text extracted successfully. AI analysis unavailable right now.';
        });
      }
    } catch (_) {
      setState(() {
        _aiAnalysis =
            'Text extracted. Connect to RAABTA backend for full AI analysis.';
      });
    }
  }

  Future<Uint8List> _applyWatermark(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return bytes;

    final watermarkText = 'Scanned by RAABTA  •  raabta.app';
    final yPos = original.height - 52;

    img.fillRect(
      original,
      x1: 0,
      y1: yPos - 10,
      x2: original.width,
      y2: yPos + 52,
      color: img.ColorRgba8(0, 0, 0, 170),
    );
    img.drawString(
      original,
      watermarkText,
      font: img.arial24,
      x: 20,
      y: yPos,
      color: img.ColorRgba8(255, 255, 255, 220),
    );
    return Uint8List.fromList(img.encodeJpg(original, quality: 92));
  }

  Future<void> _exportAsJpg() async {
    if (_scannedImagePath == null) return;
    setState(() {
      _isExporting = true;
    });
    try {
      final watermarked = await _applyWatermark(_scannedImagePath!);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/RAABTA_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(watermarked);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'RAABTA Scanned Document',
      );
    } catch (e) {
      _showSnack('JPG export failed: $e');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportAsPdf() async {
    if (_scannedImagePath == null) return;
    setState(() {
      _isExporting = true;
    });
    try {
      final watermarked = await _applyWatermark(_scannedImagePath!);
      final doc = pdf_widgets.Document();
      doc.addPage(
        pdf_widgets.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pdf_widgets.Center(
            child: pdf_widgets.Image(
              pdf_widgets.MemoryImage(watermarked),
              fit: pdf_widgets.BoxFit.contain,
            ),
          ),
        ),
      );
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/RAABTA_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await doc.save());
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'RAABTA Scanned Document',
      );
    } catch (e) {
      _showSnack('PDF export failed: $e');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _resetScan() {
    setState(() {
      _scannedImagePath = null;
      _extractedText = '';
      _aiAnalysis = '';
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1A1035),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0826),
        elevation: 0,
        title: const Text(
          'Doc Scanner',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_scannedImagePath != null)
            TextButton(
              onPressed: _resetScan,
              child: const Text(
                'Rescan',
                style: TextStyle(
                  color: Color(0xFF00B4D8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF6C3FC5).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF6C3FC5).withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: _scannedImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(_scannedImagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner_rounded,
                          size: 52,
                          color: const Color(0xFF6C3FC5).withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No document scanned yet',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use Camera or Gallery below',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isScanning || _isProcessing)
                        ? null
                        : _scanWithCamera,
                    icon: (_isScanning && _scannedImagePath == null)
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                    label: Text(
                      (_isScanning && _scannedImagePath == null)
                          ? 'Scanning...'
                          : 'Use Camera',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C3FC5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      disabledBackgroundColor:
                          const Color(0xFF6C3FC5).withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (_isScanning || _isProcessing)
                        ? null
                        : _uploadFromGallery,
                    icon: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFFFFB627),
                      size: 20,
                    ),
                    label: const Text(
                      'Upload Photo',
                      style: TextStyle(
                        color: Color(0xFFFFB627),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: const Color(0xFFFFB627).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                '📄  Supports Arabic & English  •  JPG & PDF export',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11,
                ),
              ),
            ),
            if (_isProcessing) ...[
              const SizedBox(height: 28),
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C3FC5),
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Running OCR + AI Analysis...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            if (_extractedText.isNotEmpty) ...[
              const SizedBox(height: 28),
              const Text(
                '📄  Extracted Text',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  _extractedText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
            ],
            if (_aiAnalysis.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                '🤖  AI Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C3FC5).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF6C3FC5).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _aiAnalysis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
              ),
            ],
            if (_scannedImagePath != null && !_isProcessing) ...[
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB627).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFFB627).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFFFB627),
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Free Plan: RAABTA watermark added to exported files.',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Upgrade',
                        style: TextStyle(
                          color: Color(0xFFFFB627),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportAsJpg,
                      icon: const Icon(
                        Icons.image_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        _isExporting ? 'Exporting...' : 'Save as JPG',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C3FC5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isExporting ? null : _exportAsPdf,
                      icon: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Color(0xFFE63946),
                        size: 18,
                      ),
                      label: const Text(
                        'Save as PDF',
                        style: TextStyle(
                          color: Color(0xFFE63946),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: Color(0xFFE63946),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isExporting)
                const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFB627),
                      strokeWidth: 2,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
