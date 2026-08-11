import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _firstName(User? user) {
    final full = user?.displayName ?? user?.email ?? 'there';
    return full.split(' ').first;
  }

  String _initials(User? user) {
    final full = user?.displayName ?? user?.email ?? '';
    final parts = full.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return full.isNotEmpty ? full[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: AppTypography.bodySm.copyWith(color: AppColors.mute),
              ),
              const SizedBox(height: 2),
              Text(
                '${_firstName(user)} 👋',
                style: AppTypography.displayXs.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        _AvatarCircle(initials: _initials(user)),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String initials;
  const _AvatarCircle({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFE0E7FF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4338CA),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
