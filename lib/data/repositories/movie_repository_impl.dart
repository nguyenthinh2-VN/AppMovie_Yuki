import '../../domain/entities/cast_member.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/movie_search_result.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_datasource.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Movie>> getFeaturedMovies() async {
    final models = await remoteDataSource.fetchFeaturedMovies();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Movie>> getSeriesMovies() async {
    final models = await remoteDataSource.fetchSeriesMovies();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Movie>> getNewReleases() async {
    final models = await remoteDataSource.fetchNewReleases();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Movie>> getTop10Movies() async {
    final models = await remoteDataSource.fetchTop10Movies();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Movie>> getTheaterMovies({int limit = 15}) async {
    final models = await remoteDataSource.fetchTheaterMovies(limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Movie>> getAnimeMovies() async {
    final models = await remoteDataSource.fetchAnimeMovies();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Movie>> getKoreanMovies() async {
    final models = await remoteDataSource.fetchKoreanMovies();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    return await remoteDataSource.fetchCategories();
  }

  @override
  Future<List<Movie>> getMoviesByFilter(String typeOrPath, {int page = 1, int limit = 24}) async {
    final models = await remoteDataSource.fetchMoviesByPath(typeOrPath, page: page, limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<MovieSearchResult> searchMovies(
    String keyword, {
    int page = 1,
    int limit = 24,
    String? category,
    String? country,
    int? year,
  }) async {
    return await remoteDataSource.searchMovies(
      keyword,
      page: page,
      limit: limit,
      category: category,
      country: country,
      year: year,
    );
  }

  // ── Detail Screen ──

  @override
  Future<MovieDetail> getMovieDetail(String slug) async {
    return await remoteDataSource.fetchMovieDetail(slug);
  }

  @override
  Future<List<CastMember>> getMoviePeoples(String slug) async {
    return await remoteDataSource.fetchPeoples(slug);
  }

  @override
  Future<List<String>> getMovieKeywords(String slug) async {
    return await remoteDataSource.fetchKeywords(slug);
  }
}
