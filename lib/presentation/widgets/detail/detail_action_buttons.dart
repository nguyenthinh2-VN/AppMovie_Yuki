import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Action buttons: Watch Now / Continue Watching (primary), Add to List (outline), Trailer (if available)
class DetailActionButtons extends StatelessWidget {
  final bool hasTrailer;
  final String? watchLabel;
  final double? progressRatio;
  final VoidCallback onWatch;
  final VoidCallback? onTrailer;

  const DetailActionButtons({
    super.key,
    this.hasTrailer = false,
    this.watchLabel,
    this.progressRatio,
    required this.onWatch,
    this.onTrailer,
  });

  @override
  Widget build(BuildContext context) {
    final label = watchLabel ?? 'Xem Phim';
    final isResume = progressRatio != null && progressRatio! > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // ── Watch Now / Continue Watching (Primary CTA) ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Stack(
              children: [
                ElevatedButton.icon(
                  onPressed: onWatch,
                  icon: Icon(
                    isResume ? Icons.play_circle_fill_rounded : Icons.play_arrow_rounded,
                    size: 24,
                  ),
                  label: Text(
                    label,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                if (isResume)
                  Positioned(
                    bottom: 0,
                    left: 12,
                    right: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 3,
                      ),
                    ),
                  ),
              ],
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

              // Add to list
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Danh sách', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border, width: 1.5),
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
