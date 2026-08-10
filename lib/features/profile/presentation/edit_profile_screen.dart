import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _phoneController = TextEditingController();

  bool _isSaving = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await _user?.updateDisplayName(_nameController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to update profile')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName ?? _user?.email ?? 'User';
    final email = _user?.email ?? '';
    final parts = displayName.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

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
          'Edit Profile',
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar ─────────────────────────────────────────────────
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBgMid,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo upload coming soon')),
                    ),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Change photo',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              // ── Fields ────────────────────────────────────────────────
              _SectionLabel(label: 'PERSONAL INFO'),
              const SizedBox(height: 10),
              _FormCard(
                children: [
                  // Display name
                  _FormField(
                    label: 'Full Name',
                    required: true,
                    child: TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.ink,
                      ),
                      decoration: _inputDecoration(hint: 'e.g. Jane Doe'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                  ),
                  const _FieldDivider(),

                  // Email — read-only
                  _FormField(
                    label: 'Email',
                    child: TextFormField(
                      initialValue: email,
                      readOnly: true,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.mute,
                      ),
                      decoration: _inputDecoration(
                        hint: '',
                        suffixIcon: const Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: AppColors.mute,
                        ),
                      ),
                    ),
                  ),
                  const _FieldDivider(),

                  // Phone — read-only (no update endpoint available)
                  _FormField(
                    label: 'Phone',
                    child: TextFormField(
                      controller: _phoneController,
                      readOnly: true,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.mute,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Contact support to update',
                        suffixIcon: const Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: AppColors.mute,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Save button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: _save,
                  loading: _isSaving,
                  icon: Icons.check_rounded,
                  label: 'Save Changes',
                  loadingLabel: 'Saving...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTypography.bodySm.copyWith(color: const Color(0xFFADB5BD)),
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    suffixIcon: suffixIcon,
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: AppColors.mute,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

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

class _FormField extends StatelessWidget {
  final String label;
  final bool required;
  final Widget child;
  const _FormField({
    required this.label,
    this.required = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.mute,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _FieldDivider extends StatelessWidget {
  const _FieldDivider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 1,
    color: Color(0xFFF1F5F9),
    indent: 14,
    endIndent: 14,
  );
}
