import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Floating rounded bottom navigation bar
/// - 4 tabs: Home, Search, Favorites, Profile
/// - Active tab: primary (red) icon + dot indicator
/// - Floating with margin + borderRadius
class MainNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.search_rounded, label: 'Tìm kiếm'),
    _NavItem(icon: Icons.favorite_rounded, label: 'Yêu thích'),
    _NavItem(icon: Icons.person_rounded, label: 'Hồ sơ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isActive = index == currentIndex;
          return _buildNavItem(item, isActive, index);
        }),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool isActive, int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            // Active dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
