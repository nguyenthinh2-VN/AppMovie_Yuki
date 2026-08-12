/// Represents a single episode with streaming links
class Episode {
  final String name;
  final String slug;
  final String filename;
  final String linkEmbed;
  final String linkM3u8;

  const Episode({
    required this.name,
    required this.slug,
    this.filename = '',
    this.linkEmbed = '',
    this.linkM3u8 = '',
  });
}

/// Represents a server (e.g., Vietsub, Thuyết Minh) containing episodes
class EpisodeServer {
  final String serverName;
  final List<Episode> episodes;

  const EpisodeServer({
    required this.serverName,
    required this.episodes,
  });
}
