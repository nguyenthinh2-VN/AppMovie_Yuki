import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/episode.dart';
import '../../providers/watch_history_provider.dart';

/// Episode grid with server dropdown selector and watched status indicator
class DetailEpisodeList extends StatelessWidget {
  final String movieSlug;
  final List<EpisodeServer> servers;
  final int selectedServerIndex;
  final ValueChanged<int> onServerChanged;
  final ValueChanged<Episode> onEpisodeTap;

  const DetailEpisodeList({
    super.key,
    this.movieSlug = '',
    required this.servers,
    required this.selectedServerIndex,
    required this.onServerChanged,
    required this.onEpisodeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (servers.isEmpty) return const SizedBox.shrink();

    final currentServer = servers[selectedServerIndex.clamp(0, servers.length - 1)];
    final episodes = currentServer.episodes;
    final historyProvider = context.watch<WatchHistoryProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Title + Server selector ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách tập',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (servers.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<int>(
                    value: selectedServerIndex,
                    onChanged: (val) {
                      if (val != null) onServerChanged(val);
                    },
                    underline: const SizedBox.shrink(),
                    isDense: true,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                    icon: const Icon(Icons.expand_more_rounded, color: AppColors.textMuted, size: 18),
                    items: servers.asMap().entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value.serverName),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Episode grid with watched state color indicator ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: episodes.map((ep) {
              final isWatched = movieSlug.isNotEmpty &&
                  historyProvider.isEpisodeWatched(movieSlug, ep.slug);

              return InkWell(
                onTap: () => onEpisodeTap(ep),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  constraints: const BoxConstraints(minWidth: 54),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isWatched
                        ? AppColors.surface
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isWatched
                          ? Colors.white.withValues(alpha: 0.12)
                          : AppColors.border,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isWatched) ...[
                        Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: AppColors.textMuted.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        ep.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isWatched
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: isWatched ? FontWeight.w400 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
