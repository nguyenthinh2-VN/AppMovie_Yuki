import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/episode.dart';

/// Parses the v1 API response: GET /v1/api/phim/{slug}
class MovieDetailModel {
  static MovieDetail fromApiResponse(Map<String, dynamic> response) {
    String cdnDomain = 'https://phimimg.com';
    Map<String, dynamic> item = {};

    // v1 API: data.item
    if (response['data'] != null && response['data'] is Map) {
      final data = response['data'] as Map<String, dynamic>;
      if (data['APP_DOMAIN_CDN_IMAGE'] != null) {
        cdnDomain = data['APP_DOMAIN_CDN_IMAGE'].toString();
      }
      if (data['item'] != null && data['item'] is Map) {
        item = data['item'] as Map<String, dynamic>;
      }
    }
    // Old API: root movie
    else if (response['movie'] != null && response['movie'] is Map) {
      item = response['movie'] as Map<String, dynamic>;
    }

    if (item.isEmpty) {
      throw Exception('Movie detail not found in response');
    }

    String formatImg(String? path) {
      if (path == null || path.isEmpty) return '';
      if (path.startsWith('http://') || path.startsWith('https://')) return path;
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;
      final cleanCdn = cdnDomain.endsWith('/')
          ? cdnDomain.substring(0, cdnDomain.length - 1)
          : cdnDomain;
      return '$cleanCdn/$cleanPath';
    }

    // Parse categories
    final categories = (item['category'] as List? ?? [])
        .map((c) => <String, String>{
              'name': c['name']?.toString() ?? '',
              'slug': c['slug']?.toString() ?? '',
            })
        .where((c) => c['name']!.isNotEmpty)
        .toList();

    // Parse countries
    final countries = (item['country'] as List? ?? [])
        .map((c) => <String, String>{
              'name': c['name']?.toString() ?? '',
              'slug': c['slug']?.toString() ?? '',
            })
        .where((c) => c['name']!.isNotEmpty)
        .toList();

    // Parse TMDB rating
    double tmdbRating = 0.0;
    int tmdbVoteCount = 0;
    if (item['tmdb'] != null && item['tmdb'] is Map) {
      tmdbRating = (item['tmdb']['vote_average'] as num?)?.toDouble() ?? 0.0;
      tmdbVoteCount = (item['tmdb']['vote_count'] as num?)?.toInt() ?? 0;
    }

    // Parse IMDB rating
    double imdbRating = 0.0;
    if (item['imdb'] != null && item['imdb'] is Map) {
      imdbRating = (item['imdb']['vote_average'] as num?)?.toDouble() ?? 0.0;
    }

    // Parse episodes
    final servers = _parseEpisodes(item['episodes'] ?? response['episodes']);

    return MovieDetail(
      id: item['_id']?.toString() ?? '',
      title: item['name']?.toString() ?? '',
      slug: item['slug']?.toString() ?? '',
      originName: item['origin_name']?.toString() ?? '',
      content: item['content']?.toString() ?? '',
      type: item['type']?.toString() ?? 'single',
      status: item['status']?.toString() ?? '',
      posterUrl: formatImg(item['poster_url']),
      backdropUrl: formatImg(item['thumb_url']),
      trailerUrl: item['trailer_url']?.toString() ?? '',
      time: item['time']?.toString() ?? '',
      episodeCurrent: item['episode_current']?.toString() ?? '',
      episodeTotal: item['episode_total']?.toString() ?? '',
      quality: item['quality']?.toString() ?? 'HD',
      lang: item['lang']?.toString() ?? 'Vietsub',
      year: (item['year'] as num?)?.toInt() ?? 0,
      view: (item['view'] as num?)?.toInt() ?? 0,
      tmdbRating: tmdbRating,
      tmdbVoteCount: tmdbVoteCount,
      imdbRating: imdbRating,
      actors: (item['actor'] as List? ?? []).map((a) => a.toString()).toList(),
      directors: (item['director'] as List? ?? []).map((d) => d.toString()).toList(),
      categories: categories,
      countries: countries,
      servers: servers,
    );
  }

  static List<EpisodeServer> _parseEpisodes(dynamic episodesJson) {
    if (episodesJson == null || episodesJson is! List) return [];

    return episodesJson.map((server) {
      final serverData = server['server_data'] as List? ?? [];
      final episodes = serverData.map((ep) {
        return Episode(
          name: ep['name']?.toString() ?? '',
          slug: ep['slug']?.toString() ?? '',
          filename: ep['filename']?.toString() ?? '',
          linkEmbed: ep['link_embed']?.toString() ?? '',
          linkM3u8: ep['link_m3u8']?.toString() ?? '',
        );
      }).toList();

      return EpisodeServer(
        serverName: server['server_name']?.toString() ?? 'Server',
        episodes: episodes,
      );
    }).toList();
  }
}
