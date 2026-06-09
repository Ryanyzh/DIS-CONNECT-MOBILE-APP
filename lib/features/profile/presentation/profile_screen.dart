import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/features/auth/data/auth_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authRepo = AuthRepository();

    final displayName = user?.displayName ?? user?.email ?? 'User';
    final email = user?.email ?? '';

    String initials = '?';
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (displayName.isNotEmpty) {
      initials = displayName[0].toUpperCase();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'Profile',
                style: AppTypography.displayXs.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 28),

              // ── Avatar + name card ────────────────────────────────────────
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
                        color: Color(0xFFE0E7FF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4338CA),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Settings rows ────────────────────────────────────────────
              _SettingsCard(
                items: [
                  _SettingsItem(
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {},
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

              // ── Sign out ─────────────────────────────────────────────────
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authRepo.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    foregroundColor: AppColors.negative,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.wiseLg,
                      ),
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
