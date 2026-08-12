import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Reusable network image widget with:
/// - Shimmer loading placeholder
/// - Error fallback icon
/// - Memory-optimized resize via cacheWidth/cacheHeight
/// - Fade-in animation on load
/// - BoxFit.cover for crop-to-fill without distortion
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          imageUrl,
          fit: fit,
          cacheWidth: memCacheWidth,
          cacheHeight: memCacheHeight,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: frame != null ? child : _buildPlaceholder(),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceLight,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(Icons.movie_outlined, color: AppColors.textMuted, size: 32),
      ),
    );
  }
}
