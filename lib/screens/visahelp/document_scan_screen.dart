import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/visa_api_service.dart';

class DocumentScanScreen extends ConsumerStatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  ConsumerState<DocumentScanScreen> createState() =>
      _DocumentScanScreenState();
}

class _DocumentScanScreenState extends ConsumerState<DocumentScanScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _greenColor = Color(0xFF22C55E);

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  DocumentScanResult? _result;
  bool _isScanning = false;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _error = null;
      _result = null;
    });

    final picked = source == ImageSource.camera
        ? await _picker.pickImage(source: source, imageQuality: 85)
        : await _picker.pickImage(source: source, imageQuality: 85);

    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _scanDocument() async {
    if (_selectedImage == null) {
      setState(() => _error = 'Please select a document photo first');
      return;
    }

    final isPremium = await ref.read(isPremiumUserProvider.future);
    final usage = await ref.read(documentScanUsageProvider.future);

    if (!isPremium && !usage.hasRemaining) {
      setState(() {
        _error =
            'Free limit reached (3 scans/month). Upgrade to Premium for unlimited scans.';
      });
      return;
    }

    setState(() {
      _isScanning = true;
      _error = null;
      _result = null;
    });

    try {
      final language = await ref.read(userLanguageProvider.future);
      final api = ref.read(visaApiServiceProvider);
      final result = await api.scanDocument(
        imageFile: _selectedImage!,
        language: language,
        isPremium: isPremium,
      );

      if (!isPremium) {
        await DocumentScanUsage.increment();
        ref.invalidate(documentScanUsageProvider);
      }

      if (!mounted) return;
      setState(() => _result = result);
    } on VisaApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        if (!isPremium) {
          _result = fallbackScanResult();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Scan failed: $e';
        _result = fallbackScanResult();
      });
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usageAsync = ref.watch(documentScanUsageProvider);
    final isPremiumAsync = ref.watch(isPremiumUserProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        title: const Text('Document Scan'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            usageAsync.when(
              data: (usage) {
                final isPremium = isPremiumAsync.valueOrNull ?? false;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPremium
                        ? '⭐ Premium: Unlimited document scans'
                        : '📊 Free scans remaining this month: ${usage.remaining}/${DocumentScanUsage.freeLimit}',
                    style: TextStyle(
                      color: isPremium ? _greenColor : _subtitleColor,
                      fontSize: 13,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload a photo of your Qatar document',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Iqama, employment contract, sponsor letter, or any official document',
              style: TextStyle(color: _subtitleColor, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isScanning
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _cyanColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isScanning
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _cyanColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, color: _subtitleColor, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'No document selected',
                      style: TextStyle(color: _subtitleColor),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isScanning ? null : _scanDocument,
                style: FilledButton.styleFrom(
                  backgroundColor: _cyanColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isScanning
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Analyze Document with AI',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 24),
              _ResultSection(
                title: 'Document Type',
                child: Text(
                  _result!.documentType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _ResultSection(
                title: 'Summary',
                child: Text(
                  _result!.summary,
                  style: const TextStyle(color: _subtitleColor, height: 1.5),
                ),
              ),
              _ResultSection(
                title: 'Key Dates',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _result!.keyDates
                      .map(
                        (d) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $d',
                              style: const TextStyle(color: Colors.white)),
                        ),
                      )
                      .toList(),
                ),
              ),
              _ResultSection(
                title: 'Important Info',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _result!.importantInfo
                      .map(
                        (info) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $info',
                              style: const TextStyle(color: _subtitleColor)),
                        ),
                      )
                      .toList(),
                ),
              ),
              _ResultSection(
                title: 'Action Needed',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cyanColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _cyanColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _result!.actionNeeded,
                    style: const TextStyle(color: _cyanColor, height: 1.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
