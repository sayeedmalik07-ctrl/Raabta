import 'package:flutter/material.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';

/// Active 44px search field — hub pill recipe (Home global search parity).
class GlobalSearchField extends StatelessWidget {
  const GlobalSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.locale,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String locale;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final hint = AppShellStrings.t('global_search_hint', locale);
    final label = AppShellStrings.t('global_search_field_label', locale);

    final decoration = hubSearchInputDecoration(hintText: hint).copyWith(
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: onClear,
            )
          : null,
    );

    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      child: SizedBox(
        height: HubLayoutTokens.searchMinHeight,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          textInputAction: TextInputAction.search,
          style: AppTypography.body,
          decoration: decoration,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
