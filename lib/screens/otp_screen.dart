import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/admin/admin_access.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/l10n/auth_strings.dart';
import 'package:raabta/services/auth/auth_session_service.dart';
import 'package:raabta/services/referral/referral_service.dart';
import 'package:raabta/screens/language_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });

  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const int _otpLength = 6;
  static const int _resendSeconds = 60;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = _resendSeconds;
  late String _verificationId;
  int? _resendToken;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _maskedPhone {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) {
      return '${widget.phoneNumber} ${'X' * digits.length}';
    }
    final visible = digits.substring(digits.length - 4);
    final masked = 'X' * (digits.length - 4);
    final countryMatch = RegExp(r'^\+\d{1,4}').firstMatch(widget.phoneNumber);
    final country = countryMatch?.group(0) ?? '';
    return '$country $masked$visible';
  }

  String get _otpCode =>
      _controllers.map((controller) => controller.text.trim()).join();

  void _clearOtpFields() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
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
    context.go('/home');
  }

  Future<void> _onVerify() async {
    // Snapshot at verify tap — OTP error strings match locale when user submitted code.
    final locale = ref.read(userLanguageProvider);
    final code = _otpCode;
    if (code.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthStrings.t('error_otp_incomplete', locale)),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _handleSuccessfulSignIn();
    } on FirebaseAuthException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthStrings.t('error_otp_wrong', locale))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthStrings.t('error_otp_wrong', locale))),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _onResend() async {
    if (_isResending || _secondsRemaining > 0) return;
    // Snapshot at resend tap — Firebase callback errors match locale when resend started.
    final locale = ref.read(userLanguageProvider);

    setState(() => _isResending = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      forceResendingToken: _resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (!mounted) return;
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          await _handleSuccessfulSignIn();
        } on FirebaseAuthException catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AuthStrings.format(
                  'error_with_message',
                  locale,
                  params: {
                    'message': e.message ??
                        AuthStrings.t('error_sign_in_failed', locale),
                  },
                ),
              ),
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AuthStrings.format(
                  'error_with_message',
                  locale,
                  params: {'message': e.toString()},
                ),
              ),
            ),
          );
        } finally {
          if (mounted) setState(() => _isResending = false);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;
        setState(() => _isResending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AuthStrings.format(
                'error_with_message',
                locale,
                params: {
                  'message':
                      e.message ?? AuthStrings.t('error_resend_failed', locale),
                },
              ),
            ),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isResending = false;
        });
        _clearOtpFields();
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AuthStrings.t('success_code_sent', locale)),
          ),
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final isBusy = _isVerifying || _isResending;

    return GlassScreenScaffold(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassIconButton(
            icon: Icons.arrow_back,
            tooltip: CommonActionStrings.t('action_back', locale),
            onPressed: isBusy ? null : () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AuthStrings.t('title_enter_code', locale),
            style: AppTypography.headline2,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AuthStrings.format(
              'subtitle_sent_to',
              locale,
              params: {'phone': _maskedPhone},
            ),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_otpLength, (index) {
              return SizedBox(
                width: 48,
                height: 56,
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: AppSpacing.radiusSm,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: !isBusy,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: AppTypography.headline2.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => _onOtpChanged(index, value),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          Opacity(
            opacity: isBusy ? 0.6 : 1,
            child: GlassCard(
              onTap: isBusy ? null : _onVerify,
              glowColor: AppColors.cyanGlow,
              glowIntensity: 0.25,
              backgroundColor: AppColors.cyanGlow,
              borderRadius: AppSpacing.radiusSm,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: _isVerifying
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.background,
                      ),
                    )
                  : Text(
                      AuthStrings.t('action_verify', locale),
                      style: AppTypography.button.copyWith(
                        color: AppColors.background,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: _secondsRemaining > 0
                ? Text(
                    AuthStrings.format(
                      'resend_timer',
                      locale,
                      params: {'seconds': '$_secondsRemaining'},
                    ),
                    style: AppTypography.bodySmall,
                  )
                : TextButton(
                    onPressed: _isResending ? null : _onResend,
                    child: _isResending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
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
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
