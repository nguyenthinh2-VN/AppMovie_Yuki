import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../cards/theater_movie_card.dart';

/// Section "Mãn Nhãn Với Phim Chiếu Rạp" với thiết kế UI Card 16:9 và Nút Xem thêm hình tròn chevron
class TheaterSection extends StatelessWidget {
  final List<Movie> movies;
  final VoidCallback? onSeeAll;
  final ValueChanged<Movie>? onMovieTap;

  const TheaterSection({
    super.key,
    required this.movies,
    this.onSeeAll,
    this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title gradient / bold text
              const Text(
                'Mãn Nhãn Với Phim Chiếu Rạp',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Nút Chevron hình tròn dạng icon xám tối như thiết kế
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Horizontal 16:9 Movie List ──
        SizedBox(
          height: 165,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return TheaterMovieCard(
                movie: movie,
                onTap: onMovieTap != null ? () => onMovieTap!(movie) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
