import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/visahelp/deadline_tracker.dart';
import 'package:raabta/screens/visahelp/document_scan_screen.dart';
import 'package:raabta/screens/visahelp/visa_guide_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class VisaHomeScreen extends ConsumerWidget {
  const VisaHomeScreen({super.key});

  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _emergencyRed = Color(0xFFDC2626);

  Future<void> _showEmergencyHelp(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.emergency, color: _emergencyRed),
                  SizedBox(width: 8),
                  Text(
                    'Emergency Help',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Official Qatar emergency and visa support contacts',
                style: TextStyle(color: _subtitleColor, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...emergencyContacts.map((contact) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    contact.description,
                    style: const TextStyle(color: _subtitleColor, fontSize: 12),
                  ),
                  trailing: FilledButton(
                    onPressed: () async {
                      final uri = Uri.parse('tel:${contact.number}');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _emergencyRed,
                    ),
                    child: Text(contact.number),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visa & Documents',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Step-by-step guides for Qatar residents',
                            style: TextStyle(color: _subtitleColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showEmergencyHelp(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: _emergencyRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.emergency),
                    label: const Text(
                      'Emergency Help',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 168,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = visaCategories[index];
                    return _CategoryCard(
                      category: category,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VisaGuideScreen(
                              categoryId: category.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: visaCategories.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DocumentScanScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _cyanColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _cyanColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.document_scanner_outlined,
                              color: _cyanColor),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '📷 Scan Document',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ref.watch(documentScanUsageProvider).when(
                                    data: (usage) => Text(
                                      'AI reads your Qatar documents · ${usage.remaining} free scans left',
                                      style: const TextStyle(
                                        color: _subtitleColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    loading: () => const SizedBox.shrink(),
                                    error: (_, _) => const Text(
                                      'Upload Iqama, contract, or letters',
                                      style: TextStyle(
                                        color: _subtitleColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: _cyanColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              sliver: const SliverToBoxAdapter(
                child: DeadlineTrackerWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final VisaCategory category;
  final VoidCallback onTap;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 32)),
            const Spacer(),
            Text(
              category.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _cyanColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${category.steps} steps',
                    style: const TextStyle(
                      color: _cyanColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '⏱ ${category.estimatedTime}',
                    style: const TextStyle(color: _subtitleColor, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
