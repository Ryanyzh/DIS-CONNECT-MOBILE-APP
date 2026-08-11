import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrent = false;
  bool _isLoading = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // password requirement checks
  String get _newPw => _newPasswordController.text;
  bool get _reqLength => _newPw.length >= 8;
  bool get _reqUpper => _newPw.contains(RegExp(r'[A-Z]'));
  bool get _reqLower => _newPw.contains(RegExp(r'[a-z]'));
  bool get _reqDigit => _newPw.contains(RegExp(r'[0-9]'));
  bool get _reqMatch =>
      _newPw.isNotEmpty && _newPw == _confirmPasswordController.text;

  bool get _allRequirementsMet =>
      _reqLength && _reqUpper && _reqLower && _reqDigit;

  // Submits the password change request to Firebase, handling re-authentication and error messages

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) throw Exception('Not signed in');
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final msg = switch (e.code) {
          'wrong-password' => 'Current password is incorrect.',
          'weak-password' => 'New password is too weak.',
          'requires-recent-login' =>
            'Please sign out and sign in again before changing your password.',
          _ => e.message ?? 'Failed to update password.',
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: IconButton(
          icon: const GradientIcon(icon: Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Change Password',
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // info banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
                  border: Border.all(color: const Color(0xFFDDD0FF)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 15,
                      color: Color(0xFF9A32F8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will be asked to enter your current password to verify your identity before making changes.',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFF6A2FF3),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // current password
              _SectionLabel(label: 'CURRENT PASSWORD'),
              const SizedBox(height: 10),
              _PasswordCard(
                children: [
                  _PasswordField(
                    controller: _currentPasswordController,
                    hint: 'Enter current password',
                    visible: _showCurrent,
                    onToggle: () =>
                        setState(() => _showCurrent = !_showCurrent),
                    onChanged: (_) => setState(() {}),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // new password
              _SectionLabel(label: 'NEW PASSWORD'),
              const SizedBox(height: 10),
              _PasswordCard(
                children: [
                  _PasswordField(
                    controller: _newPasswordController,
                    hint: 'Enter new password',
                    visible: _showNew,
                    onToggle: () => setState(() => _showNew = !_showNew),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!_allRequirementsMet) {
                        return 'Password does not meet all requirements';
                      }
                      return null;
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                    indent: 14,
                    endIndent: 14,
                  ),
                  _PasswordField(
                    controller: _confirmPasswordController,
                    hint: 'Confirm new password',
                    visible: _showConfirm,
                    onToggle: () =>
                        setState(() => _showConfirm = !_showConfirm),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // requirements checklist
              _RequirementsCard(
                requirements: [
                  _Requirement(label: 'At least 8 characters', met: _reqLength),
                  _Requirement(
                    label: 'One uppercase letter (A–Z)',
                    met: _reqUpper,
                  ),
                  _Requirement(
                    label: 'One lowercase letter (a–z)',
                    met: _reqLower,
                  ),
                  _Requirement(label: 'One number (0–9)', met: _reqDigit),
                  _Requirement(label: 'Passwords match', met: _reqMatch),
                ],
              ),
              const SizedBox(height: 32),

              // submit button
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: _submit,
                  loading: _isLoading,
                  icon: Icons.lock_reset_rounded,
                  label: 'Update Password',
                  loadingLabel: 'Updating...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widgets

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.caption.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 11,
        color: AppColors.mute,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
  final List<Widget> children;
  const _PasswordCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool visible;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.visible,
    required this.onToggle,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      onChanged: onChanged,
      validator: validator,
      style: AppTypography.bodySm.copyWith(color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodySm.copyWith(
          color: const Color(0xFFADB5BD),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: AppColors.mute,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

class _Requirement {
  final String label;
  final bool met;
  const _Requirement({required this.label, required this.met});
}

class _RequirementsCard extends StatelessWidget {
  final List<_Requirement> requirements;
  const _RequirementsCard({required this.requirements});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.body,
            ),
          ),
          const SizedBox(height: 10),
          ...requirements.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: r.met
                          ? const Color(0xFF059669)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      r.met ? Icons.check_rounded : Icons.remove,
                      size: 11,
                      color: r.met ? Colors.white : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    r.label,
                    style: AppTypography.caption.copyWith(
                      color: r.met ? AppColors.body : AppColors.mute,
                      fontWeight: r.met ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
