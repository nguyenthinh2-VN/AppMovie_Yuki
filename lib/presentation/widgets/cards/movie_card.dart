import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie.dart';

/// Poster card (Netflix/TMDB style)
/// Dùng DecorationImage + BoxFit.cover để ảnh luôn full-fill & crop, không bao giờ bóp méo
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

    Widget posterWidget = _PosterImage(
      imageUrl: imageUrl,
      width: isGridMode ? double.infinity : width!,
      height: isGridMode ? double.infinity : 170,
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

/// Dùng DecorationImage trực tiếp — cách duy nhất đảm bảo 100% không bóp méo
class _PosterImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;

  const _PosterImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  State<_PosterImage> createState() => _PosterImageState();
}

class _PosterImageState extends State<_PosterImage> {
  bool _loaded = false;
  bool _error = false;
  late final ImageProvider _imageProvider;

  @override
  void initState() {
    super.initState();
    _imageProvider = NetworkImage(widget.imageUrl);
    final stream = _imageProvider.resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener(
        (info, sync) {
          if (mounted) setState(() => _loaded = true);
        },
        onError: (error, stackTrace) {
          if (mounted) setState(() => _error = true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.movie_outlined,
            color: AppColors.textMuted,
            size: 32,
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        image: _loaded
            ? DecorationImage(image: _imageProvider, fit: BoxFit.cover)
            : null,
      ),
      child: _loaded
          ? null
          : const Center(
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
}
