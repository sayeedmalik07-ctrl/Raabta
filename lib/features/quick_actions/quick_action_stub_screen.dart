import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/design/app_colors.dart';

/// Temporary route target until feature screens are implemented.
class QuickActionStubScreen extends StatelessWidget {
  const QuickActionStubScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: Center(
        child: Text(
          '$title — coming soon',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
