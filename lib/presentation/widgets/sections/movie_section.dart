import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../cards/movie_card.dart';

/// Reusable horizontal movie section:
/// - Section header: title + "Tất cả >" button
/// - Horizontal scrollable list of MovieCards
/// - Accepts any `List<Movie>` -> dùng lại cho Phim Hot, Mới Cập Nhật, Anime, Phim Hàn, v.v.
class MovieSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final VoidCallback? onSeeAll;
  final ValueChanged<Movie>? onMovieTap;

  const MovieSection({
    super.key,
    required this.title,
    required this.movies,
    this.onSeeAll,
    this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Section Header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Row(
                    children: [
                      Text(
                        'Tất cả',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Horizontal Movie List ──
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
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
