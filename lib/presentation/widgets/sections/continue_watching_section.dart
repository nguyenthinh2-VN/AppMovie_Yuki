import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/watch_history_item.dart';
import '../../providers/watch_history_provider.dart';
import '../common/app_network_image.dart';

/// "Xem Tiếp" (Continue Watching) horizontal carousel section on HomeScreen
class ContinueWatchingSection extends StatelessWidget {
  final ValueChanged<WatchHistoryItem> onItemTap;

  const ContinueWatchingSection({
    super.key,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<WatchHistoryProvider>();
    final items = historyProvider.historyList;

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: Title + Clear All button ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Xem Tiếp',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              if (items.length > 3)
                TextButton(
                  onPressed: () => historyProvider.clearAll(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Xóa tất cả',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Horizontal Cards List ──
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ContinueWatchingCard(
                item: item,
                onTap: () => onItemTap(item),
                onDelete: () => historyProvider.deleteHistory(item.movieSlug),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContinueWatchingCard extends StatelessWidget {
  final WatchHistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ContinueWatchingCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const cardWidth = 210.0;

    final displayImage = item.backdropUrl.isNotEmpty
        ? item.backdropUrl
        : item.posterUrl;

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Thumbnail with Progress Bar & Play Icon ──
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 118,
                width: cardWidth,
                color: AppColors.surface,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Backdrop image
                    if (displayImage.isNotEmpty)
                      AppNetworkImage(
                        imageUrl: displayImage,
                        fit: BoxFit.cover,
                        width: cardWidth,
                        height: 118,
                        memCacheWidth: 420,
                      )
                    else
                      Container(color: AppColors.surfaceLight),

                    // Dark gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x20000000),
                            Color(0x90000000),
                          ],
                        ),
                      ),
                    ),

                    // Center Play Button Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    // Top-right delete button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),

                    // Bottom Red Progress Bar
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: item.progressRatio > 0 ? item.progressRatio : 0.05,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 3.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── 2. Movie Title ──
            Text(
              item.movieTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
            ),

            const SizedBox(height: 2),

            // ── 3. Episode & Timestamp info ──
            Text(
              '${item.episodeName} • ${item.formattedPosition}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
