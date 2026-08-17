import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Action buttons: Watch Now (primary), Add to List (outline), Trailer (if available)
class DetailActionButtons extends StatelessWidget {
  final bool hasTrailer;
  final bool isBookmarked;
  final VoidCallback onWatch;
  final VoidCallback? onTrailer;
  final VoidCallback? onBookmark;

  const DetailActionButtons({
    super.key,
    this.hasTrailer = false,
    this.isBookmarked = false,
    required this.onWatch,
    this.onTrailer,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // ── Watch Now (Primary CTA) ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onWatch,
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: const Text(
                'Xem Phim',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Secondary row: Trailer + Add to List ──
          Row(
            children: [
              // Trailer button (if available)
              if (hasTrailer) ...[
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: onTrailer,
                      icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                      label: const Text('Trailer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Bookmark / Add to list
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onBookmark,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                      size: 20,
                      color: isBookmarked ? AppColors.primary : AppColors.textPrimary,
                    ),
                    label: Text(
                      isBookmarked ? 'Đã lưu' : 'Lưu phim',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isBookmarked ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isBookmarked
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      foregroundColor: isBookmarked ? AppColors.primary : AppColors.textPrimary,
                      side: BorderSide(
                        color: isBookmarked ? AppColors.primary : AppColors.border,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
