import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../common/app_network_image.dart';

/// 16:9 Landscape Card for Theater Movies with persistent disk/memory caching
class TheaterMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const TheaterMovieCard({
    super.key,
    required this.movie,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Ưu tiên backdropUrl (16:9), nếu rỗng mới dùng posterUrl
    final imageUrl = movie.backdropUrl.isNotEmpty
        ? movie.backdropUrl
        : movie.posterUrl;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 230,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 16:9 Image Container ──
            AspectRatio(
              aspectRatio: 16 / 9,
              child: AppNetworkImage(
                imageUrl: imageUrl,
                borderRadius: BorderRadius.circular(14),
                fit: BoxFit.cover,
                memCacheWidth: 460, // 230px * 2 for sharp retina display
                memCacheHeight: 258,
                errorWidget: Container(
                  color: AppColors.surfaceLight,
                  child: const Center(
                    child: Icon(
                      Icons.local_movies_rounded,
                      color: AppColors.textMuted,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // ── Movie Title ──
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
