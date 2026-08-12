import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Horizontal scrollable category chip bar
/// - Selected chip = filled primary (red)
/// - Unselected chip = surfaceLight with border
class CategoryChipBar extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryChipBar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const List<String> defaultCategories = [
    'Tất cả',
    'Hành động',
    'Kinh dị',
    'Hài hước',
    'Tình cảm',
    'Hoạt hình',
    'Khoa học viễn tưởng',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
