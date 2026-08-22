import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Helper hiển thị thông báo SnackBar / Toast đẹp mắt với độ tương phản cao, icon và bo góc mượt mà
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? iconColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 6,
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 0.8),
        ),
        duration: duration,
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showBookmarkToast(
    BuildContext context, {
    required String movieTitle,
    required bool isSaved,
  }) {
    show(
      context,
      message: isSaved
          ? 'Đã thêm "$movieTitle" vào danh sách yêu thích'
          : 'Đã xóa "$movieTitle" khỏi danh sách yêu thích',
      icon: isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_remove_rounded,
      iconColor: isSaved ? AppColors.primary : AppColors.textSecondary,
    );
  }
}
