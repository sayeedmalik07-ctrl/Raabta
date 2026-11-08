import 'package:flutter/material.dart';
import 'receipt_scanner_widget.dart';

class ExtractionConfidenceBanner extends StatelessWidget {
  final ScannedReceiptData data;
  final String locale;

  const ExtractionConfidenceBanner({
    super.key,
    required this.data,
    this.locale = 'English',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 10,
      ),
      decoration: BoxDecoration(
        color: data.confidenceColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: data.confidenceColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            data.isHighConfidence
                ? Icons.check_circle_outline_rounded
                : data.isMediumConfidence
                    ? Icons.info_outline_rounded
                    : Icons.warning_amber_rounded,
            color: data.confidenceColor,
            size: 15,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.confidenceLabel(locale),
              style: TextStyle(
                color: data.confidenceColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Confidence percentage
          Text(
            '${(data.confidence * 100).round()}%',
            style: TextStyle(
              color: data.confidenceColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
