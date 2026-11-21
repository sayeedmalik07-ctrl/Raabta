import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/domain/scam_advisory_models.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_content_builder.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_models.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moments.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_policy.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_providers.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/forewarning_card.dart';
import 'package:raabta/features/scam_shield/providers/scam_advisory_providers.dart';

/// Shows at most one forewarning per session when policy allows.
class ForewarningSlot extends ConsumerStatefulWidget {
  const ForewarningSlot({
    super.key,
    required this.momentId,
    required this.locale,
  });

  final ForewarningMomentId momentId;
  final String locale;

  @override
  ConsumerState<ForewarningSlot> createState() => _ForewarningSlotState();
}

class _ForewarningSlotState extends ConsumerState<ForewarningSlot> {
  ForewarningResolvedContent? _content;
  bool _evaluated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluate());
  }

  Future<void> _evaluate() async {
    if (!mounted) return;
    final catalog = await ref.read(forewarningMomentsCatalogProvider.future);
    ForewarningMomentDefinition? definition;
    for (final m in catalog) {
      if (m.id == widget.momentId) {
        definition = m;
        break;
      }
    }
    if (definition == null || definition.variants.isEmpty) {
      if (mounted) setState(() => _evaluated = true);
      return;
    }

    final repo = ref.read(forewarningRepositoryProvider);
    final tipsEnabled = await repo.tipsEnabled();
    final flags = ref.read(forewarningComplianceProvider);
    final complianceAllows =
        ForewarningMoments.passesComplianceGate(definition, flags);
    final state = await repo.loadState(widget.momentId);
    final now = DateTime.now();

    if (!ForewarningPolicy.shouldShow(
      momentId: widget.momentId,
      state: state,
      now: now,
      tipsEnabled: tipsEnabled,
      complianceAllows: complianceAllows,
    )) {
      if (mounted) setState(() => _evaluated = true);
      return;
    }

    final variantIndex = ForewarningPolicy.pickVariantIndex(
      variantCount: definition.variants.length,
      lastVariantIndex: state.lastVariantIndex,
    );

    List<ScamAdvisory> advisories = const [];
    try {
      advisories = ref.read(scamAdvisoryCatalogProvider);
    } catch (_) {}

    final content = ForewarningContentBuilder.build(
      moment: definition,
      variantIndex: variantIndex,
      locale: widget.locale,
      advisories: advisories,
    );

    final updated = ForewarningPolicy.recordShown(
      state: state,
      now: now,
      variantIndex: variantIndex,
    );
    await repo.saveState(widget.momentId, updated);

    if (mounted) {
      setState(() {
        _content = content;
        _evaluated = true;
      });
    }
  }

  Future<void> _dismiss() async {
    final repo = ref.read(forewarningRepositoryProvider);
    final state = await repo.loadState(widget.momentId);
    final updated = ForewarningPolicy.recordDismiss(
      state: state,
      now: DateTime.now(),
    );
    await repo.saveState(widget.momentId, updated);
    if (mounted) setState(() => _content = null);
  }

  @override
  Widget build(BuildContext context) {
    if (!_evaluated || _content == null) return const SizedBox.shrink();
    return ForewarningCard(
      content: _content!,
      locale: widget.locale,
      onDismiss: _dismiss,
    );
  }
}
