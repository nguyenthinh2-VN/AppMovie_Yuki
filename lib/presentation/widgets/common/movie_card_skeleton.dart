import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MovieCardSkeleton extends StatelessWidget {
  final double? width;

  const MovieCardSkeleton({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 90,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
