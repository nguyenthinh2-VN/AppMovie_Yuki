import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Reusable network image with high-performance memory cache & zero-flicker reload
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true, // Không bao giờ xóa trắng hình ảnh khi widget rebuild
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          // Nếu ảnh đã có trong cache bộ nhớ (wasSynchronouslyLoaded) hoặc frame đã sẵn sàng:
          // Hiển thị ngay lập tức 0ms, không hiển thị lại spinner/placeholder
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return placeholder ?? _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorPlaceholder();
        },
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
        child: Icon(
          Icons.movie_outlined,
          color: AppColors.textMuted,
          size: 32,
        ),
      ),
    );
  }
}
