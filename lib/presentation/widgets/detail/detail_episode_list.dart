import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/episode.dart';

/// Episode grid with server dropdown selector
class DetailEpisodeList extends StatelessWidget {
  final List<EpisodeServer> servers;
  final int selectedServerIndex;
  final ValueChanged<int> onServerChanged;
  final ValueChanged<Episode> onEpisodeTap;

  const DetailEpisodeList({
    super.key,
    required this.servers,
    required this.selectedServerIndex,
    required this.onServerChanged,
    required this.onEpisodeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (servers.isEmpty) return const SizedBox.shrink();

    final currentServer = servers[selectedServerIndex];
    final episodes = currentServer.episodes;

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

          // ── Episode grid ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: episodes.map((ep) {
              return InkWell(
                onTap: () => onEpisodeTap(ep),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 52),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    ep.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
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
