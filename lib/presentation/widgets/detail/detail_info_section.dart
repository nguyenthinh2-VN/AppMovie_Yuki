import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie_detail.dart';

/// Movie info section: centered title + rating + year + quality + genre chips
class DetailInfoSection extends StatelessWidget {
  final MovieDetail movie;

  const DetailInfoSection({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final rating = movie.tmdbRating > 0 ? movie.tmdbRating : movie.imdbRating;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Title ──
          Text(
            movie.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          if (movie.originName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              movie.originName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Meta row: Rating, Year, Time, Quality, Lang, Episodes ──
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Rating
              if (rating > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

              // Year
              if (movie.year > 0) _MetaChip(text: movie.year.toString()),

              // Duration
              if (movie.time.isNotEmpty) _MetaChip(text: movie.time),

              // Quality badge
              if (movie.quality.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    movie.quality,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

              // Language badge
              if (movie.lang.isNotEmpty) _MetaChip(text: movie.lang),

              // Episode status
              if (movie.episodeCurrent.isNotEmpty)
                _MetaChip(text: movie.episodeCurrent),
            ],
          ),

          const SizedBox(height: 12),

          // ── Genre chips ──
          if (movie.categories.isNotEmpty)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: movie.categories.map((cat) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    cat['name'] ?? '',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),

          // ── Country + Director ──
          if (movie.countriesText.isNotEmpty || movie.directors.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  if (movie.countriesText.isNotEmpty)
                    _InfoRow(label: 'Quốc gia', value: movie.countriesText),
                  if (movie.countriesText.isNotEmpty && movie.directors.isNotEmpty)
                    const SizedBox(height: 6),
                  if (movie.directors.isNotEmpty)
                    _InfoRow(label: 'Đạo diễn', value: movie.directors.join(', ')),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;
  const _MetaChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
