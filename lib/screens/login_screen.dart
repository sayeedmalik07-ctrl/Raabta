import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/admin/admin_access.dart';
import 'package:raabta/features/onboarding/services/onboarding_service.dart';
import 'package:raabta/services/auth/auth_session_service.dart';
import 'package:raabta/services/auth/phone_auth_platform.dart';
import 'package:raabta/services/referral/referral_service.dart';
import 'package:raabta/features/prospective_migrant/presentation/l10n/prospective_migrant_strings.dart';
import 'package:raabta/features/prospective_migrant/services/prospective_arrival_migration_service.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/screens/l10n/auth_strings.dart';
import 'package:raabta/screens/language_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _LoginPhase { phone, otp, success }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  static const int _otpLength = 6;
  static const int _resendSeconds = 60;

  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  final List<TextEditingController> _otpControllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  static const List<_CountryCode> _countryCodes = [
    _CountryCode(code: '+974', label: '🇶🇦 Qatar'),
    _CountryCode(code: '+92', label: '🇵🇰 Pakistan'),
    _CountryCode(code: '+91', label: '🇮🇳 India'),
    _CountryCode(code: '+880', label: '🇧🇩 Bangladesh'),
    _CountryCode(code: '+63', label: '🇵🇭 Philippines'),
    _CountryCode(code: '+966', label: '🇸🇦 Saudi Arabia'),
    _CountryCode(code: '+971', label: '🇦🇪 UAE'),
  ];

  late final AnimationController _entranceController;
  late final AnimationController _focusController;
  late final AnimationController _successController;

  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _formFade;
  late final Animation<double> _successScale;

  _LoginPhase _phase = _LoginPhase.phone;
  String _selectedCountryCode = '+974';
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _isResending = false;
  bool _showPhoneError = false;
  String? _inlineError;

  String _verificationId = '';
  String _fullPhoneNumber = '';
  int? _resendToken;

  Timer? _resendTimer;
  int _secondsRemaining = _resendSeconds;

  bool get _isBusy => _isLoading || _isVerifying || _isResending;

  String get _otpCode =>
      _otpControllers.map((c) => c.text.trim()).join();

  String get _maskedPhone {
    final digits = _fullPhoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return _fullPhoneNumber;
    final visible = digits.substring(digits.length - 4);
    final masked = 'X' * (digits.length - 4);
    final countryMatch = RegExp(r'^\+\d{1,4}').firstMatch(_fullPhoneNumber);
    final country = countryMatch?.group(0) ?? '';
    return '$country $masked$visible';
  }

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    )..forward();

    _focusController = AnimationController(
      vsync: this,
      duration: AppSpacing.contentAnimation,
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _headerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.42, curve: Curves.easeOutCubic),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.42, curve: Curves.easeOutCubic),
      ),
    );

    _formFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.18, 0.62, curve: Curves.easeOutCubic),
    );

    _successScale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(
        parent: _successController,
        curve: Curves.easeOutBack,
      ),
    );

    _phoneFocus.addListener(_onPhoneFocusChanged);
  }

  void _onPhoneFocusChanged() {
    if (_phoneFocus.hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _focusController.dispose();
    _successController.dispose();
    _resendTimer?.cancel();
    _phoneController.dispose();
    _phoneFocus.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _otpFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _clearOtpFields() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes.first.requestFocus();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsRemaining = _resendSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsRemaining = 0);
      } else if (mounted) {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      _otpControllers[index].text = value[value.length - 1];
      _otpControllers[index].selection =
          const TextSelection.collapsed(offset: 1);
    }
    if (value.isNotEmpty && index < _otpLength - 1) {
      HapticFeedback.selectionClick();
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
    if (_inlineError != null) {
      setState(() => _inlineError = null);
    }
  }

  Future<void> _saveUserProfileToFirestore(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedLanguage =
        prefs.getString(LanguageScreen.languageKey) ?? 'English';

    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final existing = await docRef.get();

    final profileData = <String, dynamic>{
      'uid': user.uid,
      'phone': user.phoneNumber,
      'language': selectedLanguage,
      'lastLogin': FieldValue.serverTimestamp(),
    };

    if (!existing.exists) {
      profileData.addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'points': 0,
        'level': 'Newcomer',
        'hasCompletedOnboarding': false,
      });
    }

    await docRef.set(profileData, SetOptions(merge: true));
    await ReferralService.instance.applyPendingReferralOnSignup(user.uid);
    await docRef.set({
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> _isUserSuspended(User user) async {
    if (AdminAccess.isAdminUser(user)) return false;
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!snap.exists) return false;
    final data = snap.data() ?? {};
    return data['isSuspended'] == true || data['suspended'] == true;
  }

  Future<void> _handleSuccessfulSignIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Sign-in succeeded but no user session was found.',
      );
    }

    await _saveUserProfileToFirestore(user);

    if (await _isUserSuspended(user)) {
      AuthSessionService.instance.markSuppressSessionEndedNotice();
      await AuthSessionService.instance.signOutExplicit();
      if (!mounted) return;
      context.go('/suspended');
      return;
    }

    if (!mounted) return;
    setState(() {
      _phase = _LoginPhase.success;
      _inlineError = null;
    });
    HapticFeedback.mediumImpact();
    await _successController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (!mounted) return;
    await ref
        .read(prospectiveArrivalMigrationServiceProvider)
        .migrateIfPending(ref);
    if (!mounted) return;
    final nextRoute = await OnboardingService.instance.resolvePostLoginRoute();
    if (!mounted) return;
    context.go(nextRoute);
  }

  String get _locale => ref.read(appLocaleProvider);

  Future<void> _onSendOtp() async {
    final locale = _locale;
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _showPhoneError = true;
        _inlineError = AuthStrings.t('error_phone_required', locale);
      });
      return;
    }

    if (!isPhoneAuthSupported) {
      setState(
        () => _inlineError = AuthStrings.t('error_phone_auth_unsupported', locale),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showPhoneError = false;
      _inlineError = null;
    });

    _fullPhoneNumber = '$_selectedCountryCode$phone';

    try {
      await preparePhoneAuthIfNeeded();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _fullPhoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (!mounted) return;
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            await _handleSuccessfulSignIn();
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;
            setState(() {
              _inlineError = e.message ??
                  AuthStrings.t('error_sign_in_retry', locale);
            });
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _inlineError = e.message ??
                AuthStrings.t('error_verification_failed', locale);
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _verificationId = verificationId;
            _resendToken = resendToken;
            _phase = _LoginPhase.otp;
            _inlineError = null;
          });
          _startResendTimer();
          Future<void>.delayed(const Duration(milliseconds: 280), () {
            if (mounted) _otpFocusNodes.first.requestFocus();
          });
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } on UnimplementedError {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _inlineError = AuthStrings.t('error_phone_auth_unsupported', locale);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _inlineError = AuthStrings.t('error_send_code_failed', locale);
      });
    }
  }

  Future<void> _onVerifyOtp() async {
    final locale = _locale;
    final code = _otpCode;
    if (code.length != _otpLength) {
      setState(
        () => _inlineError = AuthStrings.t('error_otp_incomplete', locale),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _inlineError = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _handleSuccessfulSignIn();
    } on FirebaseAuthException {
      if (!mounted) return;
      setState(() => _inlineError = AuthStrings.t('error_otp_wrong', locale));
    } catch (_) {
      if (!mounted) return;
      setState(() => _inlineError = AuthStrings.t('error_otp_wrong', locale));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _onResend() async {
    if (_isResending || _secondsRemaining > 0) return;

    final locale = _locale;
    if (!isPhoneAuthSupported) {
      setState(
        () => _inlineError = AuthStrings.t('error_phone_auth_unsupported', locale),
      );
      return;
    }

    setState(() {
      _isResending = true;
      _inlineError = null;
    });

    try {
      await preparePhoneAuthIfNeeded();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _fullPhoneNumber,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (!mounted) return;
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            await _handleSuccessfulSignIn();
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;
            setState(() {
              _inlineError = e.message ??
                  AuthStrings.t('error_sign_in_retry', locale);
            });
          } catch (e) {
            if (!mounted) return;
            setState(
              () => _inlineError = AuthStrings.t('error_generic_retry', locale),
            );
          } finally {
            if (mounted) setState(() => _isResending = false);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _isResending = false;
            _inlineError = e.message ??
                AuthStrings.t('error_resend_retry', locale);
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isResending = false;
          });
          _clearOtpFields();
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } on UnimplementedError {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _inlineError = AuthStrings.t('error_phone_auth_unsupported', locale);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _inlineError = AuthStrings.t('error_resend_retry', locale);
      });
    }
  }

  Future<void> _continueWithoutAccount() async {
    final nextRoute = await OnboardingService.instance.resolvePostLoginRoute();
    if (!mounted) return;
    context.go(nextRoute);
  }

  void _backToPhone() {
    if (_isBusy) return;
    setState(() {
      _phase = _LoginPhase.phone;
      _inlineError = null;
    });
    _resendTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    return GlassScreenScaffold(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    if (_phase == _LoginPhase.otp)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GlassIconButton(
                          icon: Icons.arrow_back,
                          tooltip: CommonActionStrings.t('action_back', locale),
                          onPressed: _isBusy ? null : _backToPhone,
                        ),
                      ),
                    if (_phase == _LoginPhase.success) ...[
                      const Spacer(),
                      _SuccessMoment(scale: _successScale, locale: locale),
                      const Spacer(),
                    ] else ...[
                      FadeTransition(
                        opacity: _headerFade,
                        child: SlideTransition(
                          position: _headerSlide,
                          child: _LoginHeader(phase: _phase, locale: locale),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      if (!isPhoneAuthSupported) ...[
                        _PlatformNoticeBanner(
                          message: AuthStrings.t(
                            'error_phone_auth_unsupported',
                            locale,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      FadeTransition(
                        opacity: _formFade,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.04),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _phase == _LoginPhase.phone
                              ? _PhoneInputSection(
                                  key: const ValueKey('phone'),
                                  countryCodes: _countryCodes,
                                  selectedCountryCode: _selectedCountryCode,
                                  phoneController: _phoneController,
                                  phoneFocus: _phoneFocus,
                                  focusAnimation: _focusController,
                                  isLoading: _isLoading,
                                  showPhoneError: _showPhoneError,
                                  locale: locale,
                                  onCountryChanged: _isLoading
                                      ? null
                                      : (value) => setState(
                                            () => _selectedCountryCode = value,
                                          ),
                                )
                              : _OtpInputSection(
                                  key: const ValueKey('otp'),
                                  maskedPhone: _maskedPhone,
                                  controllers: _otpControllers,
                                  focusNodes: _otpFocusNodes,
                                  isBusy: _isBusy,
                                  onChanged: _onOtpChanged,
                                ),
                        ),
                      ),
                      if (_inlineError != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _InlineErrorMessage(message: _inlineError!),
                      ],
                      const Spacer(),
                      FadeTransition(
                        opacity: _formFade,
                        child: _phase == _LoginPhase.phone
                            ? _GoldPrimaryButton(
                                label: AuthStrings.t('action_send_code', locale),
                                isLoading: _isLoading,
                                onPressed: _isLoading ? null : _onSendOtp,
                              )
                            : Column(
                                children: [
                                  _GoldPrimaryButton(
                                    label: AuthStrings.t('action_verify', locale),
                                    isLoading: _isVerifying,
                                    onPressed:
                                        _isBusy ? null : _onVerifyOtp,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  _ResendRow(
                                    secondsRemaining: _secondsRemaining,
                                    isResending: _isResending,
                                    locale: locale,
                                    onResend: _onResend,
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AuthStrings.t('terms_agreement', locale),
                        style: AppTypography.caption,
                        textAlign: TextAlign.center,
                      ),
                      if (!isPhoneAuthSupported) ...[
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: _isBusy ? null : _continueWithoutAccount,
                          child: Text(
                            AuthStrings.t(
                              'action_continue_without_signin',
                              locale,
                            ),
                            style: AppTypography.link,
                          ),
                        ),
                      ],
                      if (_phase == _LoginPhase.phone) ...[
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: _isBusy
                              ? null
                              : () => context.go('/prospective'),
                          child: Text(
                            ProspectiveMigrantStrings.t(
                              'pm_entry_link',
                              ref.watch(appLocaleProvider),
                            ),
                            style: AppTypography.link.copyWith(
                              color: AppColors.purpleGlow,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlatformNoticeBanner extends StatelessWidget {
  const _PlatformNoticeBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: AppSpacing.radiusSm,
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.warning,
      glowIntensity: 0.12,
      backgroundColor: AppColors.warning.withValues(alpha: 0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.smartphone_outlined,
            size: AppSpacing.iconMd,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.phase, required this.locale});

  final _LoginPhase phase;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (phase == _LoginPhase.otp) {
      return Column(
        children: [
          Text(
            AuthStrings.t('title_enter_code', locale),
            style: AppTypography.headline2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AuthStrings.t('label_sent_to', locale),
            style: AppTypography.subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      children: [
        GlassContainer(
          borderRadius: AppSpacing.radiusMd,
          padding: const EdgeInsets.all(AppSpacing.md),
          glowColor: AppColors.sharePurple,
          glowIntensity: 0.14,
          child: const Text('🌙', style: TextStyle(fontSize: AppSpacing.xxxl)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AuthStrings.t('title_welcome', locale),
          style: AppTypography.headline2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AuthStrings.t('subtitle_enter_number', locale),
          style: AppTypography.subtitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PhoneInputSection extends StatelessWidget {
  const _PhoneInputSection({
    super.key,
    required this.countryCodes,
    required this.selectedCountryCode,
    required this.phoneController,
    required this.phoneFocus,
    required this.focusAnimation,
    required this.isLoading,
    required this.showPhoneError,
    required this.locale,
    required this.onCountryChanged,
  });

  final List<_CountryCode> countryCodes;
  final String selectedCountryCode;
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final Animation<double> focusAnimation;
  final bool isLoading;
  final bool showPhoneError;
  final String locale;
  final ValueChanged<String>? onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusAnimation,
      builder: (context, child) {
        final focused = focusAnimation.value > 0.5;
        final errored = showPhoneError;
        final borderGlow = errored
            ? AppColors.error.withValues(alpha: 0.35)
            : AppColors.cyanGlow.withValues(
                alpha: focused ? 0.45 : 0.12,
              );

        return GlassContainer(
          borderRadius: AppSpacing.radiusMd,
          padding: const EdgeInsets.all(AppSpacing.sm),
          glowColor: errored ? AppColors.error : AppColors.cyanGlow,
          glowIntensity: errored ? 0.22 : (focused ? 0.28 : 0.08),
          child: Row(
            children: [
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                borderRadius: AppSpacing.radiusSm,
                glowColor: AppColors.cyanGlow,
                glowIntensity: 0.1,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCountryCode,
                    dropdownColor: AppColors.surface,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textPrimary,
                      size: AppSpacing.iconMd,
                    ),
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    items: countryCodes
                        .map(
                          (country) => DropdownMenuItem(
                            value: country.code,
                            child: Text(country.code),
                          ),
                        )
                        .toList(),
                    onChanged: onCountryChanged == null
                        ? null
                        : (value) {
                            if (value != null) onCountryChanged!(value);
                          },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: borderGlow, width: 1),
                  ),
                  child: TextField(
                    controller: phoneController,
                    focusNode: phoneFocus,
                    enabled: !isLoading,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: AppTypography.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: AuthStrings.t('label_phone_number', locale),
                      hintStyle: AppTypography.body.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OtpInputSection extends StatelessWidget {
  const _OtpInputSection({
    super.key,
    required this.maskedPhone,
    required this.controllers,
    required this.focusNodes,
    required this.isBusy,
    required this.onChanged,
  });

  final String maskedPhone;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isBusy;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          maskedPhone,
          style: AppTypography.subtitle.copyWith(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(controllers.length, (index) {
            return _OtpDigitBox(
              controller: controllers[index],
              focusNode: focusNodes[index],
              enabled: !isBusy,
              onChanged: (value) => onChanged(index, value),
            );
          }),
        ),
      ],
    );
  }
}

class _OtpDigitBox extends StatefulWidget {
  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  State<_OtpDigitBox> createState() => _OtpDigitBoxState();
}

class _OtpDigitBoxState extends State<_OtpDigitBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final active = widget.focusNode.hasFocus;
    return AnimatedScale(
      scale: active ? 1.04 : 1,
      duration: AppSpacing.contentAnimation,
      curve: Curves.easeOutCubic,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: AppSpacing.radiusSm,
        glowColor: active ? AppColors.accentGold : AppColors.glassBorderBright,
        glowIntensity: active ? 0.32 : 0.06,
        backgroundColor: active
            ? AppColors.accentGold.withValues(alpha: 0.06)
            : null,
        child: SizedBox(
          width: AppSpacing.xxxl + AppSpacing.sm,
          height: AppSpacing.xxxl + AppSpacing.md,
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: AppTypography.headline2.copyWith(
              fontSize: AppSpacing.iconLg,
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}

class _GoldPrimaryButton extends StatelessWidget {
  const _GoldPrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: AppSpacing.contentAnimation,
      opacity: onPressed == null && !isLoading ? 0.5 : 1,
      child: GlassContainer(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppSpacing.radiusSm,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        glowColor: AppColors.accentGold,
        glowIntensity: onPressed != null ? 0.35 : 0.1,
        backgroundColor: AppColors.accentGold.withValues(
          alpha: onPressed != null ? 0.22 : 0.08,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: AppSpacing.iconMd + AppSpacing.xxs,
                  height: AppSpacing.iconMd + AppSpacing.xxs,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textPrimary,
                  ),
                )
              : Text(
                  label,
                  style: AppTypography.button.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.secondsRemaining,
    required this.isResending,
    required this.locale,
    required this.onResend,
  });

  final int secondsRemaining;
  final bool isResending;
  final String locale;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    if (secondsRemaining > 0) {
      return Text(
        AuthStrings.format(
          'resend_timer',
          locale,
          params: {'seconds': '$secondsRemaining'},
        ),
        style: AppTypography.bodySmall,
        textAlign: TextAlign.center,
      );
    }

    return Center(
      child: TextButton(
        onPressed: isResending ? null : onResend,
        child: isResending
            ? const SizedBox(
                width: AppSpacing.iconSm + AppSpacing.xxs,
                height: AppSpacing.iconSm + AppSpacing.xxs,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.cyanGlow,
                ),
              )
            : Text(
                AuthStrings.t('action_resend_code', locale),
                style: AppTypography.link,
              ),
      ),
    );
  }
}

class _InlineErrorMessage extends StatelessWidget {
  const _InlineErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: AppSpacing.radiusSm,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      glowColor: AppColors.error,
      glowIntensity: 0.14,
      backgroundColor: AppColors.error.withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: AppSpacing.iconSm,
            color: AppColors.error.withValues(alpha: 0.9),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessMoment extends StatelessWidget {
  const _SuccessMoment({required this.scale, required this.locale});

  final Animation<double> scale;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassContainer(
            borderRadius: AppSpacing.radiusFull,
            padding: const EdgeInsets.all(AppSpacing.lg),
            glowColor: AppColors.accentGold,
            glowIntensity: 0.42,
            backgroundColor: AppColors.accentGold.withValues(alpha: 0.16),
            child: Icon(
              Icons.check_rounded,
              size: AppSpacing.xxxl,
              color: AppColors.accentGold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AuthStrings.t('title_welcome', locale),
            style: AppTypography.headline2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AuthStrings.t('success_setting_up', locale),
            style: AppTypography.subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CountryCode {
  const _CountryCode({
    required this.code,
    required this.label,
  });

  final String code;
  final String label;
}
