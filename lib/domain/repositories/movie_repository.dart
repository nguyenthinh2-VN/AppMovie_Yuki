import '../entities/cast_member.dart';
import '../entities/movie.dart';
import '../entities/movie_detail.dart';

abstract class MovieRepository {
  Future<List<Movie>> getFeaturedMovies();
  Future<List<Movie>> getSeriesMovies();
  Future<List<Movie>> getNewReleases();
  Future<List<Movie>> getTop10Movies();
  Future<List<Movie>> getAnimeMovies();
  Future<List<Movie>> getKoreanMovies();
  Future<List<String>> getCategories();
  Future<List<Movie>> getMoviesByFilter(String typeOrPath, {int page = 1, int limit = 24});

  // Detail screen
  Future<MovieDetail> getMovieDetail(String slug);
  Future<List<CastMember>> getMoviePeoples(String slug);
  Future<List<String>> getMovieKeywords(String slug);
}
