import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/auth/data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = AuthRepository();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepo.signInAndGetToken(email: email, password: password);
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _friendlyError(e.code));
    } catch (_) {
      setState(() => _errorMessage = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Converts FirebaseAuth error codes to user-friendly messages.
  String _friendlyError(String code) => switch (code) {
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Incorrect email or password.',
    'user-disabled' => 'This account has been disabled.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    'network-request-failed' => 'Check your internet connection.',
    _ => 'Login failed. Please try again.',
  };

  InputDecoration _field({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.mute, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFEEEAFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD8CCFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD8CCFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.6),
      ),
      labelStyle: AppTypography.bodySm.copyWith(
        color: AppColors.mute,
        fontSize: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 56),

                    // brand mark
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: AppGradients.brandDiagonal,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF4C39F2,
                            ).withValues(alpha: 0.32),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SvgPicture.asset(
                          'assets/images/disconnect_logo_white.svg',
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // app name
                    const Text(
                      'dis-connect',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0E0F0C),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Scholarship Management Portal',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.mute,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // form card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 32,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign in to your account',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enter your credentials to continue.',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.mute,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Email
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            enabled: !_isLoading,
                            decoration: _field(
                              label: 'Email address',
                              icon: Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Password
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            enabled: !_isLoading,
                            onSubmitted: (_) => _login(),
                            decoration: _field(
                              label: 'Password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.mute,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),

                          // Error banner
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            _ErrorBanner(message: _errorMessage!),
                          ],
                          const SizedBox(height: 22),

                          // Sign-in button
                          GradientButton(
                            onPressed: _login,
                            loading: _isLoading,
                            label: 'Sign In',
                            loadingLabel: 'Signing in...',
                            height: 52,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // security footer
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 12,
                    color: Color(0xFFB0B8C4),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Authorised personnel only · Secured by Firebase',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFFB0B8C4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFDC2626),
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFFDC2626),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
