import 'dart:async';

import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/services/auth_service.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  bool _isChecking = false;
  bool _canResend = true;
  int _resendCountdown = 0;
  Timer? _verificationCheckTimer;

  @override
  void initState() {
    super.initState();
    // Start automatic verification checking every 5 seconds
    _startAutoVerificationCheck();
  }

  @override
  void dispose() {
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  /// Start automatic periodic check for email verification
  void _startAutoVerificationCheck() {
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkEmailVerifiedSilently();
    });
  }

  /// Check if email has been verified (with UI feedback)
  Future<void> _checkEmailVerified() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    ShowToastDialog.showLoader("Checking verification status...".tr);

    try {
      final isVerified = await _authService.reloadUser();

      ShowToastDialog.closeLoader();

      if (isVerified) {
        _verificationCheckTimer?.cancel(); // Stop auto-checking
        ShowToastDialog.showToast("Email verified successfully! Please login.".tr);
        // Sign out and redirect to login
        await _authService.signOut();
        Get.offAll(() => const LoginScreen());
      } else {
        ShowToastDialog.showToast("Email not verified yet. Please check your inbox.".tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error checking verification: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  /// Check if email has been verified silently (no UI feedback, runs in background)
  Future<void> _checkEmailVerifiedSilently() async {
    if (!mounted) return;

    try {
      final isVerified = await _authService.reloadUser();

      if (isVerified && mounted) {
        _verificationCheckTimer?.cancel(); // Stop auto-checking
        
        // Show success message
        ShowToastDialog.showToast("Email verified successfully! Please login.".tr);
        
        // Sign out and redirect to login
        await _authService.signOut();
        Get.offAll(() => const LoginScreen());
      }
    } catch (e) {
      // Silently fail - don't show error messages for automatic checks
      debugPrint('Auto-check failed: $e');
    }
  }

  /// Resend verification email
  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    ShowToastDialog.showLoader("Sending verification email...".tr);

    try {
      final success = await _authService.sendEmailVerification();

      ShowToastDialog.closeLoader();

      if (success) {
        ShowToastDialog.showToast("Verification email sent! Please check your inbox.".tr);
        
        // Start countdown timer (60 seconds)
        setState(() {
          _canResend = false;
          _resendCountdown = 60;
        });

        _startResendCountdown();
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      ShowToastDialog.showToast(errorMessage);
    }
  }

  /// Start countdown timer for resend button
  void _startResendCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendCountdown();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  /// Sign out and go back to login
  Future<void> _signOutAndGoToLogin() async {
    ShowToastDialog.showLoader("Please wait".tr);
    await _authService.signOut();
    ShowToastDialog.closeLoader();
    Get.offAll(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Email Icon
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppThemeData.primary300.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: 60,
                    color: AppThemeData.primary300,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  "Verify Your Email".tr,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                    fontFamily: AppThemeData.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  "We've sent a verification link to".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                    fontFamily: AppThemeData.regular,
                  ),
                ),
                const SizedBox(height: 8),

                // Email address
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppThemeData.primary300,
                    fontFamily: AppThemeData.semiBold,
                  ),
                ),
                const SizedBox(height: 16),

                // Auto-check indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppThemeData.success300.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppThemeData.success300.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppThemeData.success300),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Auto-checking every 5 seconds...".tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppThemeData.success300,
                          fontFamily: AppThemeData.medium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeChange.getThem()
                        ? AppThemeData.grey900
                        : AppThemeData.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppThemeData.primary300,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Next Steps".tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep("1", "Check your email inbox"),
                      const SizedBox(height: 8),
                      _buildInstructionStep("2", "Click the verification link"),
                      const SizedBox(height: 8),
                      _buildInstructionStep("3", "Return here and tap 'I've Verified'"),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Check verification button
                RoundedButtonFill(
                  title: "I've Verified My Email".tr,
                  color: AppThemeData.primary300,
                  textColor: AppThemeData.grey50,
                  isEnabled: !_isChecking,
                  onPress: _checkEmailVerified,
                ),
                const SizedBox(height: 16),

                // Resend button
                RoundedButtonFill(
                  title: _canResend
                      ? "Resend Verification Email".tr
                      : "Resend in $_resendCountdown seconds",
                  color: _canResend
                      ? AppThemeData.secondary300
                      : AppThemeData.grey400,
                  textColor: AppThemeData.grey50,
                  isEnabled: _canResend,
                  onPress: _resendVerificationEmail,
                ),
                const SizedBox(height: 24),

                MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                const SizedBox(height: 24),

                // Help text
                Text(
                  "Didn't receive the email?".tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                    fontFamily: AppThemeData.regular,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Check your spam folder or try resending".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey500,
                    fontFamily: AppThemeData.regular,
                  ),
                ),
                const SizedBox(height: 32),

                // Back to login button
                TextButton(
                  onPressed: _signOutAndGoToLogin,
                  child: Text(
                    "Back to Login".tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppThemeData.primary300,
                      fontFamily: AppThemeData.semiBold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppThemeData.primary300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text.tr,
            style: TextStyle(
              fontSize: 14,
              color: themeChange.getThem()
                  ? AppThemeData.grey300
                  : AppThemeData.grey700,
              fontFamily: AppThemeData.regular,
            ),
          ),
        ),
      ],
    );
  }
}

