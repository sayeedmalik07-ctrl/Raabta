import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:raabta/core/colors/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'package:raabta/services/referral/referral_share_enricher.dart';
import '../models/shareable_card_data.dart';
import 'card_renderers.dart';

class ShareCardSheet extends StatefulWidget {
  final ShareableCardData data;

  const ShareCardSheet({super.key, required this.data});

  static Future<void> show(
    BuildContext      context,
    ShareableCardData data,
  ) {
    return showModalBottomSheet(
      context:            context,
      backgroundColor:    Colors.transparent,
      isScrollControlled: true,
      enableDrag:         true,
      builder: (_) => ShareCardSheet(data: data),
    );
  }

  @override
  State<ShareCardSheet> createState() =>
      _ShareCardSheetState();
}

class _ShareCardSheetState extends State<ShareCardSheet> {

  // ✅ RepaintBoundary key — captures the VISIBLE card
  // exactly as rendered, preserving all fonts and colors
  final GlobalKey _repaintKey = GlobalKey();
  bool _isCapturing = false;
  ShareableCardData? _enrichedData;

  @override
  void initState() {
    super.initState();
    _prepareReferralEnrichment();
  }

  Future<void> _prepareReferralEnrichment() async {
    if (!ReferralShareEnricher.isReferralEligible(widget.data.type)) return;
    final enriched = await ReferralShareEnricher.enrich(widget.data);
    if (mounted) setState(() => _enrichedData = enriched);
  }

  ShareableCardData get _activeData => _enrichedData ?? widget.data;

  // ── Capture from the live RepaintBoundary ─────────────
  Future<Uint8List?> _captureCard() async {
    try {
      final boundary = _repaintKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // Wait one extra frame for images to fully render
      await Future.delayed(const Duration(milliseconds: 200));

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  // ── Share via WhatsApp / native sheet ─────────────────
  Future<void> _shareViaWhatsApp() async {
    setState(() { _isCapturing = true; });
    try {
      final bytes = await _captureCard();
      if (bytes == null) {
        _snack('Could not generate card. Try again.');
        return;
      }
      final dir  = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/raabta_card_'
        '${DateTime.now().millisecondsSinceEpoch}.png',
      )..writeAsBytesSync(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: _activeData.shareCaption,
      );
    } catch (e) {
      _snack('Share failed. Try again.');
    } finally {
      if (mounted) setState(() { _isCapturing = false; });
    }
  }

  // ── Download to gallery ───────────────────────────────
  Future<void> _downloadCard() async {
    setState(() { _isCapturing = true; });
    try {
      // Request permission
      var status = await Permission.photos.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          _snack('Please allow photo access in Settings.');
          return;
        }
      }

      final bytes = await _captureCard();
      if (bytes == null) {
        _snack('Could not generate card. Try again.');
        return;
      }

      final name =
          'RAABTA_${widget.data.type.name}_'
          '${DateTime.now().millisecondsSinceEpoch}';

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name:    name,
      );

      if (result['isSuccess'] == true) {
        if (mounted) Navigator.pop(context);
        _snack('✅ Card saved to your Photos!');
      } else {
        _snack('Could not save. Try again.');
      }
    } catch (e) {
      _snack('Download failed. Try again.');
    } finally {
      if (mounted) setState(() { _isCapturing = false; });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:    Text(msg),
        behavior:   SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1035),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.92),
      decoration: BoxDecoration(
        color: AppColors.isLight
            ? AppColors.surfaceElevated
            : const Color(0xFF0D0826),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width:  36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.isLight
                    ? AppColors.glassBorder
                    : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Share Card',
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize:   18,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.isLight
                          ? AppColors.glassSurface
                          : Colors.white.withValues(alpha: 0.08),
                      shape:        BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.isLight
                          ? AppColors.textTertiary
                          : Colors.white54,
                      size:  16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ✅ Card preview — inside RepaintBoundary
          // This is what gets captured — rendered LIVE
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RepaintBoundary(
                key: _repaintKey,
                child: _buildCardRenderer(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── THREE EXPORT BUTTONS ──────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [

                // 1. Share to WhatsApp / Any App
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCapturing
                        ? null
                        : _shareViaWhatsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      disabledBackgroundColor:
                          const Color(0xFF25D366).withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isCapturing
                        ? const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width:  18, height: 18,
                                child:  CircularProgressIndicator(
                                  color:       Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Generating card...',
                                style: TextStyle(
                                  color:      Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize:   15,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                '📤',
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Share via WhatsApp',
                                style: TextStyle(
                                  color:      Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize:   15,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Download to Gallery
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCapturing
                        ? null
                        : _downloadCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sharePurple,
                      disabledBackgroundColor:
                          AppColors.sharePurple.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          '💾',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Download to Photos',
                          style: TextStyle(
                            color:      Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize:   15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 3. Share to other apps (Instagram etc)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isCapturing
                        ? null
                        : _shareViaWhatsApp,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      side: BorderSide(
                        color: AppColors.isLight
                            ? AppColors.glassBorder
                            : Colors.white.withValues(alpha: 0.15),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          '📸',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Share to Instagram / Other',
                          style: TextStyle(
                            color: AppColors.isLight
                                ? AppColors.textOnGlassSecondary
                                : Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                            fontSize:   14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Builds the correct live card widget for preview + capture
  Widget _buildCardRenderer() {
    final data = _activeData;
    switch (data.type) {
      case ShareableCardType.healthScore:
        return HealthScoreCardRenderer(
          data: data as HealthScoreCardData,
        );
      case ShareableCardType.billSplit:
        return BillSplitCardRenderer(
          data: data as BillSplitCardData,
        );
      case ShareableCardType.warrantyAlert:
        return WarrantyAlertCardRenderer(
          data: data as WarrantyAlertCardData,
        );
      case ShareableCardType.waitTime:
        return WaitTimeCardRenderer(
          data: data as WaitTimeCardData,
        );
      case ShareableCardType.documentAlert:
        return DocumentAlertCardRenderer(
          data: data as DocumentAlertCardData,
        );
      case ShareableCardType.eosbSettlement:
        return EosbSettlementCardRenderer(
          data: data as EosbSettlementCardData,
        );
      case ShareableCardType.eosbTruthCertificate:
        return EosbTruthCertificateCardRenderer(
          data: data as EosbTruthCertificateCardData,
        );
      case ShareableCardType.overtimeTruth:
        return OvertimeTruthCardRenderer(
          data: data as OvertimeTruthCardData,
        );
      case ShareableCardType.friendsFamilyLoan:
        return FriendsFamilyLoanCardRenderer(
          data: data as FriendsFamilyLoanCardData,
        );
      case ShareableCardType.healthInsuranceCompliance:
        return HealthInsuranceComplianceCardRenderer(
          data: data as HealthInsuranceComplianceCardData,
        );
      case ShareableCardType.healthInsurancePolicy:
        return HealthInsurancePolicyCardRenderer(
          data: data as HealthInsurancePolicyCardData,
        );
      case ShareableCardType.healthInsuranceDenial:
        return HealthInsuranceDenialCardRenderer(
          data: data as HealthInsuranceDenialCardData,
        );
      case ShareableCardType.tripItinerary:
        return TripItineraryCardRenderer(
          data: data as TripItineraryCardData,
        );
      case ShareableCardType.prayerTimes:
        return PrayerTimesCardRenderer(
          data: data as PrayerTimesCardData,
        );
      case ShareableCardType.personalBudget:
        return PersonalBudgetCardRenderer(
          data: data as PersonalBudgetCardData,
        );
      case ShareableCardType.utilityBills:
        return UtilityBillsCardRenderer(
          data: data as UtilityBillsCardData,
        );
    }
  }
}
