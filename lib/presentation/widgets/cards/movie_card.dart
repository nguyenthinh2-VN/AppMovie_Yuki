import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../common/app_network_image.dart';

/// Poster card (Netflix/TMDB style) with persistent disk and memory caching
class MovieCard extends StatelessWidget {
  final Movie movie;
  final double? width;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = 120,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasEpisodeOrQuality =
        movie.episodeCurrent.isNotEmpty || movie.quality.isNotEmpty;

    final imageUrl = movie.posterUrl.isNotEmpty
        ? movie.posterUrl
        : movie.backdropUrl;

    final bool isGridMode = width == null;

    final posterWidget = AppNetworkImage(
      imageUrl: imageUrl,
      width: isGridMode ? double.infinity : width!,
      height: isGridMode ? double.infinity : 170,
      borderRadius: BorderRadius.circular(12),
      fit: BoxFit.cover,
      memCacheWidth: 260, // Retina resolution cache
      memCacheHeight: 370,
    );

    final posterWithBadges = Stack(
      fit: StackFit.expand,
      children: [
        posterWidget,
        // Rating badge (top right)
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.accentGold,
                  size: 13,
                ),
                const SizedBox(width: 2),
                Text(
                  movie.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Episode / Quality badge (bottom left)
        if (hasEpisodeOrQuality)
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                movie.episodeCurrent.isNotEmpty
                    ? movie.episodeCurrent
                    : movie.quality,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isGridMode)
              Expanded(child: posterWithBadges)
            else
              SizedBox(width: width, height: 170, child: posterWithBadges),

            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${movie.year} \u2022 ${movie.genre}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
