class Movie {
  final String id;
  final String title;
  final String slug;
  final String originName;
  final String posterUrl;
  final String backdropUrl;
  final double rating;
  final int year;
  final String genre;
  final String overview;
  final String quality;
  final String lang;
  final String episodeCurrent;

  const Movie({
    required this.id,
    required this.title,
    required this.slug,
    this.originName = '',
    required this.posterUrl,
    required this.backdropUrl,
    required this.rating,
    required this.year,
    required this.genre,
    required this.overview,
    this.quality = 'HD',
    this.lang = 'Vietsub',
    this.episodeCurrent = '',
  });
}
