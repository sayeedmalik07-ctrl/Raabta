import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/domain/models/eosb_structured_explanation.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/services/eosb_explanation_template_service.dart';

class EosbAiExplanationRequest {
  const EosbAiExplanationRequest({
    this.question,
    this.forceRegenerate = false,
  });

  final String? question;
  final bool forceRegenerate;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EosbAiExplanationRequest &&
            question == other.question &&
            forceRegenerate == other.forceRegenerate;
  }

  @override
  int get hashCode => Object.hash(question, forceRegenerate);
}

final eosbExplanationTemplateProvider =
    Provider((_) => const EosbExplanationTemplateService());

final eosbAiExplanationProvider =
    Provider.family<String, EosbAiExplanationRequest>((ref, request) {
  final localeAsync = ref.watch(eosbLocaleProvider);
  final state = ref.watch(eosbProvider);
  final result = state.result;
  final locale = localeAsync.valueOrNull ?? 'English';

  if (result == null) {
    return 'Complete a calculation first.';
  }

  return ref.watch(eosbExplanationTemplateProvider).generate(
        input: state.input,
        result: result,
        locale: locale,
        userQuestion: request.question,
      );
});

final eosbStructuredExplanationProvider = Provider<EosbStructuredExplanation?>((ref) {
  final localeAsync = ref.watch(eosbLocaleProvider);
  final state = ref.watch(eosbProvider);
  final result = state.result;
  final locale = localeAsync.valueOrNull ?? 'English';

  if (result == null) return null;

  return ref.watch(eosbExplanationTemplateProvider).buildStructured(
        input: state.input,
        result: result,
        locale: locale,
      );
});
