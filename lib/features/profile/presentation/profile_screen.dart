import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/features/auth/data/auth_repository.dart';
import 'package:disconnect_mobile/features/profile/data/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authRepo = AuthRepository();
  UserProfile? _profile;
  bool _loading = true;
  bool _profileError = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final profile = await UserRepository(ApiClient()).getUserById(uid);
      if (mounted) setState(() { _profile = profile; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _profileError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final displayName = _profile?.fullName ?? firebaseUser?.displayName ?? firebaseUser?.email ?? 'User';
    final email = _profile?.email ?? firebaseUser?.email ?? '';

    String initials = '?';
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (displayName.isNotEmpty) {
      initials = displayName[0].toUpperCase();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Error banner (non-blocking) ─────────────────────────
                    if (_profileError) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(AppBorderRadius.wiseSm),
                          border: Border.all(color: const Color(0xFFFED7AA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Color(0xFFEA580C)),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Some profile details could not be loaded.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF9A3412)),
                              ),
                            ),
                            GestureDetector(
                              onTap: _loadProfile,
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── Avatar + name card ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBgMid,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: AppTypography.bodyMd.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.mute,
                                  ),
                                ),
                                if (_profile?.role != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _profile!.role == 'hr'
                                          ? const Color(0xFFEDE9FE)
                                          : const Color(0xFFDBEAFE),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      _profile!.role == 'hr' ? 'HR Officer' : 'Scholar',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _profile!.role == 'hr'
                                            ? const Color(0xFF6D28D9)
                                            : const Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Scholar profile info ────────────────────────────────
                    if (_profile?.role == 'scholar') ...[
                      const SizedBox(height: 16),
                      _InfoCard(items: [
                        if (_profile!.studentId != null)
                          _InfoRow(label: 'Student ID', value: _profile!.studentId!),
                        if (_profile!.faculty != null)
                          _InfoRow(label: 'Faculty', value: _profile!.faculty!),
                        if (_profile!.program != null)
                          _InfoRow(label: 'Programme', value: _profile!.program!),
                        if (_profile!.yearOfStudy != null)
                          _InfoRow(label: 'Year of Study', value: 'Year ${_profile!.yearOfStudy}'),
                        if (_profile!.scholarshipType != null)
                          _InfoRow(label: 'Scholarship', value: _profile!.scholarshipType!),
                        if (_profile!.phone != null)
                          _InfoRow(label: 'Phone', value: _profile!.phone!),
                      ]),
                    ],

                    // ── HR profile info ─────────────────────────────────────
                    if (_profile?.role == 'hr') ...[
                      const SizedBox(height: 16),
                      _InfoCard(items: [
                        if (_profile!.employeeId != null)
                          _InfoRow(label: 'Employee ID', value: _profile!.employeeId!),
                        if (_profile!.designation != null)
                          _InfoRow(label: 'Designation', value: _profile!.designation!),
                        if (_profile!.phone != null)
                          _InfoRow(label: 'Phone', value: _profile!.phone!),
                      ]),
                    ],

                    const SizedBox(height: 16),

                    // ── Settings rows ───────────────────────────────────────
                    _SettingsCard(
                      items: [
                        _SettingsItem(
                          icon: Icons.person_outline,
                          label: 'Edit Profile',
                          onTap: () => context.push('/profile/edit'),
                        ),
                        _SettingsItem(
                          icon: Icons.lock_outline,
                          label: 'Change Password',
                          onTap: () => context.push('/profile/change-password'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SettingsCard(
                      items: [
                        _SettingsItem(
                          icon: Icons.help_outline,
                          label: 'Help & Support',
                          onTap: () => context.push('/profile/help'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Sign out ────────────────────────────────────────────
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _authRepo.signOut();
                          if (context.mounted) context.go('/login');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          foregroundColor: AppColors.negative,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppBorderRadius.wiseLg),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: AppTypography.bodySm.copyWith(color: AppColors.mute),
                    ),
                    Text(
                      item.value,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: i == 0
                      ? const Radius.circular(AppBorderRadius.wiseMd)
                      : Radius.zero,
                  bottom: isLast
                      ? const Radius.circular(AppBorderRadius.wiseMd)
                      : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 20, color: AppColors.body),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xFFCBD5E1),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                  indent: 50,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
