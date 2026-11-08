import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Rebuilds [builder] when the app language changes.
///
/// Use inside [showModalBottomSheet], [showDialog], and other overlays that
/// sit outside the parent [ConsumerState.build] subtree.
class CommunityReactiveLocale extends ConsumerWidget {
  const CommunityReactiveLocale({super.key, required this.builder});

  final Widget Function(BuildContext context, String locale) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return builder(context, ref.watch(userLanguageProvider));
  }
}

/// Catalog key or server-provided message for Community action feedback.
typedef CommunityUiError = ({String? catalogKey, String? rawMessage});

String? resolveCommunityUiError(CommunityUiError? error, String locale) {
  if (error == null) return null;
  if (error.rawMessage != null && error.rawMessage!.isNotEmpty) {
    return error.rawMessage;
  }
  if (error.catalogKey != null) {
    return CommunityStrings.t(error.catalogKey!, locale);
  }
  return null;
}
