import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActionsHub extends StatelessWidget {
  const QuickActionsHub({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const QuickActionsHub(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1035),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '⚡ Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Smart tools built for expat life in Qatar',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
          const SizedBox(height: 24),

          // 2-column grid of action tiles
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: [
              _ActionTile(
                icon: Icons.document_scanner_rounded,
                label: 'Doc Scanner',
                subtitle: 'Scan & translate documents',
                color: const Color(0xFF6C3FC5),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/scanner');
                },
              ),
              _ActionTile(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Barcode & Price',
                subtitle: 'Scan any product barcode',
                color: const Color(0xFF00B4D8),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/barcode-scanner');
                },
              ),
              _ActionTile(
                icon: Icons.location_on_rounded,
                label: 'Landmark Translator',
                subtitle: 'Turn address to Arabic GPS',
                color: const Color(0xFF2DC653),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/landmark-translator');
                },
              ),
              _ActionTile(
                icon: Icons.restaurant_menu_rounded,
                label: 'Bill Splitter',
                subtitle: 'Split bills in any currency',
                color: const Color(0xFFFFB627),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/bill-splitter');
                },
              ),
              _ActionTile(
                icon: Icons.shield_rounded,
                label: 'Warranty Shield',
                subtitle: 'Track your Qatar warranties',
                color: const Color(0xFFE63946),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/warranty-shield');
                },
              ),
              _ActionTile(
                icon: Icons.thermostat_rounded,
                label: 'Heat Navigator',
                subtitle: 'Indoor & shaded routes',
                color: const Color(0xFFFF6B35),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/climate-navigator');
                },
              ),
              _ActionTile(
                icon: Icons.people_alt_rounded,
                label: 'Queue Avoidance',
                subtitle: 'Live wait times in Qatar',
                color: const Color(0xFF00B4D8),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/queue-avoidance');
                },
              ),
              _ActionTile(
                icon: Icons.receipt_long_rounded,
                label: 'Bill Tracker',
                subtitle: 'Track Qatar utility bills',
                color: const Color(0xFF2DC653),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/bill-tracker');
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.30), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
