import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/l10n/progressive_profile_strings.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';
import 'package:raabta/screens/profile/profile_field_persistence.dart';
import 'package:raabta/screens/profile/progressive_profile_flow.dart';
import 'package:raabta/screens/profile/widgets/progressive_profile_step_indicator.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Focused three-step profile capture — reuses existing [UserAIProfile] persistence.
class ProgressiveProfileCaptureScreen extends ConsumerStatefulWidget {
  const ProgressiveProfileCaptureScreen({super.key});

  @override
  ConsumerState<ProgressiveProfileCaptureScreen> createState() =>
      _ProgressiveProfileCaptureScreenState();
}

class _ProgressiveProfileCaptureScreenState
    extends ConsumerState<ProgressiveProfileCaptureScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  ProgressiveProfileField? _currentField;
  ProgressiveProfileField? _sessionStartField;
  bool _ready = false;
  bool _saving = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_bootstrap()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) setState(() => _ready = true);
      return;
    }

    final notifier = ref.read(userAIProfileProvider.notifier);
    final existing = ref.read(userAIProfileProvider);
    if (UserProfileOwnership.needsInit(existing, user.uid)) {
      await notifier.initProfile(user.uid);
    }

    if (!mounted) return;
    final profile = ref.read(userAIProfileProvider);
    if (profile == null || profile.uid != user.uid) {
      setState(() => _ready = true);
      return;
    }

    if (ProgressiveProfileFlow.isFlowComplete(profile)) {
      _exitFlow();
      return;
    }

    final first = ProgressiveProfileFlow.firstIncompleteField(profile)!;
    _syncControllerForField(profile, first);
    setState(() {
      _currentField = first;
      _sessionStartField = first;
      _ready = true;
    });
  }

  void _syncControllerForField(
    UserAIProfile profile,
    ProgressiveProfileField field,
  ) {
    _controller.text = ProgressiveProfileFlow.fieldValue(profile, field);
    _inlineError = null;
  }

  UserAIProfile? _ownedProfile() {
    final user = ref.read(currentUserProvider);
    final profile = ref.read(userAIProfileProvider);
    if (user == null || profile == null) return null;
    if (profile.uid != user.uid) return null;
    return profile;
  }

  void _exitFlow() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _advanceAfterStep(UserAIProfile profile) async {
    if (ProgressiveProfileFlow.isFlowComplete(profile)) {
      _exitFlow();
      return;
    }

    final next = ProgressiveProfileFlow.firstIncompleteField(profile);
    if (next == null) {
      _exitFlow();
      return;
    }

    _syncControllerForField(profile, next);
    setState(() => _currentField = next);
  }

  Future<void> _onContinue() async {
    final profile = _ownedProfile();
    final field = _currentField;
    if (profile == null || field == null) return;

    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() {
        _inlineError = ProgressiveProfileStrings.t(
          'error_empty_value',
          AppLocale.normalize(ref.read(userLanguageProvider)),
        );
      });
      return;
    }

    setState(() {
      _saving = true;
      _inlineError = null;
    });

    try {
      final uid = profile.uid;
      final saved = switch (field) {
        ProgressiveProfileField.profession =>
          await ProfileFieldPersistence.saveProfession(
            ref,
            uid: uid,
            value: value,
          ),
        ProgressiveProfileField.nationality =>
          await ProfileFieldPersistence.saveNationality(
            ref,
            uid: uid,
            value: value,
          ),
        ProgressiveProfileField.preferredArea =>
          await ProfileFieldPersistence.savePreferredArea(
            ref,
            uid: uid,
            value: value,
          ),
      };

      if (!saved || !mounted) return;

      final updated = ref.read(userAIProfileProvider);
      if (updated == null || updated.uid != uid) return;

      await _advanceAfterStep(updated);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onSkip() async {
    final profile = _ownedProfile();
    final field = _currentField;
    if (profile == null || field == null) return;

    final next = ProgressiveProfileFlow.nextIncompleteAfter(field, profile);
    if (next == null) {
      _exitFlow();
      return;
    }

    _syncControllerForField(profile, next);
    setState(() => _currentField = next);
  }

  void _onBack() {
    final field = _currentField;
    if (field == null) {
      context.pop();
      return;
    }

    if (field == _sessionStartField) {
      context.pop();
      return;
    }

    final previous = ProgressiveProfileFlow.previousField(field);
    if (previous == null) {
      context.pop();
      return;
    }

    final profile = _ownedProfile();
    if (profile == null) {
      context.pop();
      return;
    }

    _syncControllerForField(profile, previous);
    setState(() => _currentField = previous);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final user = ref.watch(currentUserProvider);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    if (!_ready) {
      return GlassScreenScaffold(
        title: ProfileStrings.t('field_profession', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios_rounded,
          tooltip: CommonActionStrings.t('action_back', locale),
          onPressed: () => context.pop(),
        ),
        body: const Center(child: GlassLoadingCard(height: 120, width: 240)),
      );
    }

    if (user == null) {
      return GlassScreenScaffold(
        title: ProfileStrings.t('field_profession', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios_rounded,
          tooltip: CommonActionStrings.t('action_back', locale),
          onPressed: () => context.pop(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              ProgressiveProfileStrings.t('error_sign_in_required', locale),
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
          ),
        ),
      );
    }

    final field = _currentField;
    if (field == null) {
      return GlassScreenScaffold(
        title: ProfileStrings.t('field_profession', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios_rounded,
          tooltip: CommonActionStrings.t('action_back', locale),
          onPressed: () => context.pop(),
        ),
        body: const Center(child: GlassLoadingCard(height: 120, width: 240)),
      );
    }

    final profileForLabels =
        _ownedProfile() ?? UserAIProfile.defaultProfile(user.uid);
    final isLastStep =
        ProgressiveProfileFlow.nextIncompleteAfter(field, profileForLabels) ==
            null;
    final continueLabel = isLastStep
        ? ProgressiveProfileStrings.t('action_done', locale)
        : ProgressiveProfileStrings.t('action_continue', locale);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProgressiveProfileStepIndicator(field: field, locale: locale),
        const SizedBox(height: AppSpacing.lg),
        Text(
          ProgressiveProfileStrings.t(
            ProgressiveProfileStrings.questionKey(field),
            locale,
          ),
          style: AppTypography.headline2.copyWith(fontSize: 22),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ProgressiveProfileStrings.t(
            ProgressiveProfileStrings.hintKey(field),
            locale,
          ),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Semantics(
            textField: true,
            label: ProfileStrings.t(
              switch (field) {
                ProgressiveProfileField.profession => 'field_profession',
                ProgressiveProfileField.nationality => 'field_nationality',
                ProgressiveProfileField.preferredArea => 'field_preferred_area',
              },
              locale,
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: AppTypography.subtitle,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saving ? null : unawaited(_onContinue()),
              decoration: InputDecoration(
                labelText: ProfileStrings.t(
                  switch (field) {
                    ProgressiveProfileField.profession => 'field_profession',
                    ProgressiveProfileField.nationality => 'field_nationality',
                    ProgressiveProfileField.preferredArea =>
                      'field_preferred_area',
                  },
                  locale,
                ),
                labelStyle: AppTypography.bodySmall,
                filled: true,
                fillColor: AppColors.surface.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                errorText: _inlineError,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          button: true,
          label: continueLabel,
          child: GlassPrimaryButton(
            label: _saving
                ? ProfileStrings.t('action_saving', locale)
                : continueLabel,
            expand: true,
            onPressed: _saving ? null : () => unawaited(_onContinue()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          button: true,
          label: ProgressiveProfileStrings.t('action_skip', locale),
          child: TextButton(
            onPressed: _saving ? null : () => unawaited(_onSkip()),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 48),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            child: Text(
              ProgressiveProfileStrings.t('action_skip', locale),
              style: AppTypography.link.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );

    return GlassScreenScaffold(
      title: ProfileStrings.t(
        switch (field) {
          ProgressiveProfileField.profession => 'field_profession',
          ProgressiveProfileField.nationality => 'field_nationality',
          ProgressiveProfileField.preferredArea => 'field_preferred_area',
        },
        locale,
      ),
      leading: GlassIconButton(
        icon: Icons.arrow_back_ios_rounded,
        tooltip: CommonActionStrings.t('action_back', locale),
        onPressed: _onBack,
      ),
      body: AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey(field),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: content,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
