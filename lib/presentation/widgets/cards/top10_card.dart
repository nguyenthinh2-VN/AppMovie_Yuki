import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../common/app_network_image.dart';

/// Netflix-style Top 10 card with large rank number overlapping poster
class Top10Card extends StatelessWidget {
  final Movie movie;
  final int rank;
  final VoidCallback? onTap;

  const Top10Card({
    super.key,
    required this.movie,
    required this.rank,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Poster + Rank Number ──
            SizedBox(
              height: 170,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Poster (dịch sang phải nhường chỗ cho số)
                  Positioned(
                    left: 30,
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: AppNetworkImage(
                      imageUrl: movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl,
                      width: 120,
                      height: 170,
                      borderRadius: BorderRadius.circular(12),
                      memCacheWidth: 240,
                      memCacheHeight: 360,
                    ),
                  ),
                  // Rank number (stroke outline style)
                  Positioned(
                    left: -4,
                    bottom: -8,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2.5
                          ..color = AppColors.textPrimary,
                      ),
                    ),
                  ),
                  // Rank number fill (dark for readability)
                  Positioned(
                    left: -4,
                    bottom: -8,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        color: AppColors.background.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Title ──
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
