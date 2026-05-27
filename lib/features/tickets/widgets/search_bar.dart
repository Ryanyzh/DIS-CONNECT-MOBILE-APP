import 'package:flutter/material.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

/// Reusable search bar used on the Home screen and Ticket list.
class AppSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search tickets, requests...',
    this.onChanged,
    this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.wisePill),
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
                const SizedBox(width: 14),
                const Icon(Icons.search, color: Color(0xFFADB5BD), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: AppTypography.bodySm.copyWith(
                        color: const Color(0xFFADB5BD),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: AppTypography.bodySm.copyWith(color: AppColors.ink),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        if (onFilter != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onFilter,
            child: Container(
              width: 48,
              height: 48,
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
              child: const Icon(
                Icons.tune_rounded,
                color: Color(0xFF4F46E5),
                size: 20,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
