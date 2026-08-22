import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/episode.dart';
import '../../providers/watch_history_provider.dart';

/// Server Selector Pills + Episode Grid with active playing and watched status indicators
class WatchEpisodeSelector extends StatelessWidget {
  final String movieSlug;
  final List<EpisodeServer> servers;
  final int selectedServerIndex;
  final Episode currentEpisode;
  final ValueChanged<int> onServerChanged;
  final ValueChanged<Episode> onEpisodeTap;

  const WatchEpisodeSelector({
    super.key,
    this.movieSlug = '',
    required this.servers,
    required this.selectedServerIndex,
    required this.currentEpisode,
    required this.onServerChanged,
    required this.onEpisodeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (servers.isEmpty) return const SizedBox.shrink();

    final currentServer = servers[selectedServerIndex.clamp(0, servers.length - 1)];
    final episodes = currentServer.episodes;
    final historyProvider = context.watch<WatchHistoryProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Server Selector Pills (if multiple servers) ──
        if (servers.length > 1) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Nguồn phát (Server)',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: servers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == selectedServerIndex;
                final server = servers[index];
                return InkWell(
                  onTap: () => onServerChanged(index),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      server.serverName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── 2. Episode Grid Header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách tập',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${episodes.length} tập',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── 3. Episode Grid with 3 visual states (Playing / Watched / Unwatched) ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: episodes.map((ep) {
              final isPlaying = ep.slug == currentEpisode.slug ||
                  (ep.slug.isEmpty && ep.name == currentEpisode.name);

              final isWatched = movieSlug.isNotEmpty &&
                  historyProvider.isEpisodeWatched(movieSlug, ep.slug);

              final Color backgroundColor;
              final Border border;
              final Color textColor;
              final FontWeight fontWeight;
              final List<BoxShadow>? boxShadow;

              if (isPlaying) {
                // Tier 1: Currently Playing
                backgroundColor = AppColors.primary.withValues(alpha: 0.2);
                border = Border.all(color: AppColors.primary, width: 1.5);
                textColor = AppColors.primary;
                fontWeight = FontWeight.w700;
                boxShadow = [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ];
              } else if (isWatched) {
                // Tier 2: Previously Watched / Clicked
                backgroundColor = AppColors.surface;
                border = Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.0,
                );
                textColor = AppColors.textSecondary;
                fontWeight = FontWeight.w400;
                boxShadow = null;
              } else {
                // Tier 3: Unwatched
                backgroundColor = AppColors.surfaceLight;
                border = Border.all(color: AppColors.border, width: 1.0);
                textColor = AppColors.textPrimary;
                fontWeight = FontWeight.w500;
                boxShadow = null;
              }

              return InkWell(
                onTap: () => onEpisodeTap(ep),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  constraints: const BoxConstraints(minWidth: 54),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: border,
                    boxShadow: boxShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPlaying) ...[
                        const Icon(
                          Icons.graphic_eq_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                      ] else if (isWatched) ...[
                        Icon(
                          Icons.check_rounded,
                          color: AppColors.textMuted.withValues(alpha: 0.8),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        ep.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: fontWeight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
