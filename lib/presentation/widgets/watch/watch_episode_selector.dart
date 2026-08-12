import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/episode.dart';

/// Server Selector Pills + Episode Grid with active indicator
class WatchEpisodeSelector extends StatelessWidget {
  final List<EpisodeServer> servers;
  final int selectedServerIndex;
  final Episode currentEpisode;
  final ValueChanged<int> onServerChanged;
  final ValueChanged<Episode> onEpisodeTap;

  const WatchEpisodeSelector({
    super.key,
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

        // ── 3. Episode Grid ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: episodes.map((ep) {
              final isPlaying = ep.slug == currentEpisode.slug ||
                  (ep.slug.isEmpty && ep.name == currentEpisode.name);

              return InkWell(
                onTap: () => onEpisodeTap(ep),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  constraints: const BoxConstraints(minWidth: 54),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPlaying ? AppColors.primary : AppColors.border,
                      width: isPlaying ? 1.5 : 1.0,
                    ),
                    boxShadow: isPlaying
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
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
                      ],
                      Text(
                        ep.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isPlaying ? AppColors.primary : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w500,
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
