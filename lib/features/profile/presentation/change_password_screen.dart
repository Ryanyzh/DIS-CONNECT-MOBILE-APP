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

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Change Password',
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w800,
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
              // ── Info banner ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 15,
                      color: Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will be asked to enter your current password to verify your identity before making changes.',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFF5B21B6),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Current password ─────────────────────────────────────────
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

              // ── New password ─────────────────────────────────────────────
              _SectionLabel(label: 'NEW PASSWORD'),
              const SizedBox(height: 10),
              _PasswordCard(
                children: [
                  _PasswordField(
                    controller: _newPasswordController,
                    hint: 'Enter new password',
                    onChanged: (_) => setState(() {}),
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
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

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
