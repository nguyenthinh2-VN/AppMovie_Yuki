import 'movie.dart';

class MovieSearchResult {
  final List<Movie> movies;
  final int totalItems;
  final int currentPage;
  final int totalPages;

  const MovieSearchResult({
    required this.movies,
    this.totalItems = 0,
    this.currentPage = 1,
    this.totalPages = 1,
  });
}
