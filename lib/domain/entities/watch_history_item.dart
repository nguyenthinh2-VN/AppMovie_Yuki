import 'dart:convert';

/// Represents a movie watch history record with progress & watched episodes
class WatchHistoryItem {
  final String movieSlug;
  final String movieTitle;
  final String posterUrl;
  final String backdropUrl;
  final String episodeName;
  final String episodeSlug;
  final int serverIndex;
  final int positionSeconds;
  final int durationSeconds;
  final List<String> watchedEpisodeSlugs;
  final DateTime updatedAt;

  const WatchHistoryItem({
    required this.movieSlug,
    required this.movieTitle,
    this.posterUrl = '',
    this.backdropUrl = '',
    required this.episodeName,
    required this.episodeSlug,
    this.serverIndex = 0,
    this.positionSeconds = 0,
    this.durationSeconds = 0,
    this.watchedEpisodeSlugs = const [],
    required this.updatedAt,
  });

  /// Progress ratio from 0.0 to 1.0
  double get progressRatio {
    if (durationSeconds <= 0) return 0.0;
    final ratio = positionSeconds / durationSeconds;
    return ratio.clamp(0.0, 1.0);
  }

  /// Formatted position string (e.g. "12:30")
  String get formattedPosition {
    final minutes = positionSeconds ~/ 60;
    final seconds = positionSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  WatchHistoryItem copyWith({
    String? movieSlug,
    String? movieTitle,
    String? posterUrl,
    String? backdropUrl,
    String? episodeName,
    String? episodeSlug,
    int? serverIndex,
    int? positionSeconds,
    int? durationSeconds,
    List<String>? watchedEpisodeSlugs,
    DateTime? updatedAt,
  }) {
    return WatchHistoryItem(
      movieSlug: movieSlug ?? this.movieSlug,
      movieTitle: movieTitle ?? this.movieTitle,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      episodeName: episodeName ?? this.episodeName,
      episodeSlug: episodeSlug ?? this.episodeSlug,
      serverIndex: serverIndex ?? this.serverIndex,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      watchedEpisodeSlugs: watchedEpisodeSlugs ?? this.watchedEpisodeSlugs,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'movieSlug': movieSlug,
      'movieTitle': movieTitle,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'episodeName': episodeName,
      'episodeSlug': episodeSlug,
      'serverIndex': serverIndex,
      'positionSeconds': positionSeconds,
      'durationSeconds': durationSeconds,
      'watchedEpisodeSlugs': watchedEpisodeSlugs,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WatchHistoryItem.fromMap(Map<String, dynamic> map) {
    return WatchHistoryItem(
      movieSlug: map['movieSlug']?.toString() ?? '',
      movieTitle: map['movieTitle']?.toString() ?? '',
      posterUrl: map['posterUrl']?.toString() ?? '',
      backdropUrl: map['backdropUrl']?.toString() ?? '',
      episodeName: map['episodeName']?.toString() ?? '',
      episodeSlug: map['episodeSlug']?.toString() ?? '',
      serverIndex: (map['serverIndex'] as num?)?.toInt() ?? 0,
      positionSeconds: (map['positionSeconds'] as num?)?.toInt() ?? 0,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      watchedEpisodeSlugs: (map['watchedEpisodeSlugs'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory WatchHistoryItem.fromJson(String source) =>
      WatchHistoryItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
