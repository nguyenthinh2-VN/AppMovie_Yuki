import 'episode.dart';

/// Full movie detail entity with all sub-resources
class MovieDetail {
  final String id;
  final String title;
  final String slug;
  final String originName;
  final String content; // HTML content (synopsis)
  final String type; // "single" or "series"
  final String status;
  final String posterUrl;
  final String backdropUrl;
  final String trailerUrl;
  final String time;
  final String episodeCurrent;
  final String episodeTotal;
  final String quality;
  final String lang;
  final int year;
  final int view;
  final double tmdbRating;
  final int tmdbVoteCount;
  final double imdbRating;
  final List<String> actors;
  final List<String> directors;
  final List<Map<String, String>> categories; // [{name, slug}]
  final List<Map<String, String>> countries;  // [{name, slug}]
  final List<EpisodeServer> servers;

  const MovieDetail({
    required this.id,
    required this.title,
    required this.slug,
    this.originName = '',
    this.content = '',
    this.type = 'single',
    this.status = '',
    this.posterUrl = '',
    this.backdropUrl = '',
    this.trailerUrl = '',
    this.time = '',
    this.episodeCurrent = '',
    this.episodeTotal = '',
    this.quality = 'HD',
    this.lang = 'Vietsub',
    this.year = 0,
    this.view = 0,
    this.tmdbRating = 0.0,
    this.tmdbVoteCount = 0,
    this.imdbRating = 0.0,
    this.actors = const [],
    this.directors = const [],
    this.categories = const [],
    this.countries = const [],
    this.servers = const [],
  });

  bool get isSeries => type == 'series' || type == 'hoathinh';
  String get categoriesText => categories.map((c) => c['name'] ?? '').join(', ');
  String get countriesText => countries.map((c) => c['name'] ?? '').join(', ');
}
