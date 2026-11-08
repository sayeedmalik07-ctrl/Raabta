import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/presentation/providers/post_schema_providers.dart';

/// Admin section for Firestore post category schemas (Config area).
class AdminPostSchemasSection extends ConsumerWidget {
  const AdminPostSchemasSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Post Category Schemas', style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Firestore-driven fields for all listing verticals. '
            'Seed: node tool/seed_post_schemas.mjs --apply',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final vertical in PostVertical.values)
            _VerticalSchemaTile(vertical: vertical),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => context.push(
              '/dev/post-schema-preview?vertical=marketplace&category=electronics.mobiles',
            ),
            icon: const Icon(Icons.science_outlined),
            label: const Text('Preview: Marketplace → Mobiles'),
          ),
        ],
      ),
    );
  }
}

class _VerticalSchemaTile extends ConsumerWidget {
  const _VerticalSchemaTile({required this.vertical});

  final PostVertical vertical;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemaAsync = ref.watch(postVerticalSchemaProvider(vertical));
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(vertical.id),
      subtitle: schemaAsync.when(
        loading: () => const Text('Loading…'),
        error: (e, _) => Text('Error: $e'),
        data: (schema) => Text(
          'v${schema.version} · '
          '${schema.categoryOverrides.length} categories · '
          '${schema.fromCache ? 'cache' : 'remote'}',
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () => ref.invalidate(postVerticalSchemaProvider(vertical)),
      ),
    );
  }
}
