import '../../core/network/api_client.dart';
import '../../domain/entities/cast_member.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/movie_search_result.dart';
import '../models/kkphim_movie_model.dart';
import '../models/movie_detail_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<KKPhimMovieModel>> fetchFeaturedMovies();
  Future<List<KKPhimMovieModel>> fetchSeriesMovies();
  Future<List<KKPhimMovieModel>> fetchNewReleases();
  Future<List<KKPhimMovieModel>> fetchTop10Movies();
  Future<List<KKPhimMovieModel>> fetchTheaterMovies({int limit = 15});
  Future<List<KKPhimMovieModel>> fetchAnimeMovies();
  Future<List<KKPhimMovieModel>> fetchKoreanMovies();
  Future<List<String>> fetchCategories();
  Future<List<KKPhimMovieModel>> fetchMoviesByPath(String typeOrPath, {int page = 1, int limit = 24});
  Future<MovieSearchResult> searchMovies(
    String keyword, {
    int page = 1,
    int limit = 24,
    String? category,
    String? country,
    int? year,
  });

  // Detail screen APIs
  Future<MovieDetail> fetchMovieDetail(String slug);
  Future<List<CastMember>> fetchPeoples(String slug);
  Future<List<String>> fetchKeywords(String slug);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final ApiClient apiClient;

  MovieRemoteDataSourceImpl({required this.apiClient});

  List<KKPhimMovieModel> _parseItems(Map<String, dynamic> response) {
    String cdnDomain = 'https://phimimg.com';
    List itemsJson = [];

    if (response['data'] != null && response['data'] is Map) {
      final data = response['data'] as Map<String, dynamic>;
      if (data['APP_DOMAIN_CDN_IMAGE'] != null) {
        cdnDomain = data['APP_DOMAIN_CDN_IMAGE'].toString();
      }
      if (data['items'] != null && data['items'] is List) {
        itemsJson = data['items'] as List;
      }
    } else if (response['items'] != null && response['items'] is List) {
      itemsJson = response['items'] as List;
    }

    return itemsJson
        .map((item) => KKPhimMovieModel.fromJson(item as Map<String, dynamic>, cdnDomain))
        .toList();
  }

  @override
  Future<List<KKPhimMovieModel>> fetchFeaturedMovies() async {
    final response = await apiClient.get('/v1/api/danh-sach/phim-le', queryParameters: {'limit': '15'});
    return _parseItems(response);
  }

  @override
  Future<List<KKPhimMovieModel>> fetchSeriesMovies() async {
    final response = await apiClient.get('/v1/api/danh-sach/phim-bo', queryParameters: {'limit': '10'});
    return _parseItems(response);
  }

  @override
  Future<List<KKPhimMovieModel>> fetchNewReleases() async {
    final response = await apiClient.get('/v1/api/danh-sach', queryParameters: {'page': '1', 'limit': '10'});
    return _parseItems(response);
  }

  @override
  Future<List<KKPhimMovieModel>> fetchTop10Movies() async {
    final response = await apiClient.get('/v1/api/danh-sach/phim-le', queryParameters: {'limit': '10'});
    return _parseItems(response);
  }

  @override
  Future<List<KKPhimMovieModel>> fetchTheaterMovies({int limit = 15}) async {
    final response = await apiClient.get('/v1/api/danh-sach/phim-chieu-rap', queryParameters: {
      'page': '1',
      'limit': limit.toString(),
    });
    return _parseItems(response);
  }

  @override
  Future<List<KKPhimMovieModel>> fetchAnimeMovies() async {
    final response = await apiClient.get('/v1/api/danh-sach/hoat-hinh', queryParameters: {'limit': '10'});
    return _parseItems(response);
  }

  @override
  Future<List<KKPhimMovieModel>> fetchKoreanMovies() async {
    final response = await apiClient.get('/v1/api/quoc-gia/han-quoc', queryParameters: {'limit': '10'});
    return _parseItems(response);
  }

  @override
  Future<List<String>> fetchCategories() async {
    try {
      final response = await apiClient.get('/the-loai');
      List items = [];
      if (response['data'] != null && response['data']['items'] != null) {
        items = response['data']['items'] as List;
      } else if (response['items'] != null) {
        items = response['items'] as List;
      }
      final result = ['Tất cả'];
      for (var item in items) {
        if (item['name'] != null) {
          result.add(item['name'].toString());
        }
      }
      return result.isNotEmpty ? result : ['Tất cả', 'Hành động', 'Phim Bộ', 'Kinh dị', 'Hoạt hình'];
    } catch (_) {
      return ['Tất cả', 'Hành động', 'Phim Bộ', 'Kinh dị', 'Hoạt hình', 'Tình cảm', 'Khoa học viễn tưởng'];
    }
  }

  @override
  Future<List<KKPhimMovieModel>> fetchMoviesByPath(String typeOrPath, {int page = 1, int limit = 24}) async {
    String apiPath = typeOrPath;
    if (typeOrPath == 'phim-moi') {
      apiPath = '/v1/api/danh-sach';
    } else if (typeOrPath.startsWith('/')) {
      // Already a full path
      apiPath = typeOrPath;
    } else if (typeOrPath.startsWith('quoc-gia/') || typeOrPath.startsWith('the-loai/')) {
      // Country/Genre endpoints: /v1/api/quoc-gia/{slug} or /v1/api/the-loai/{slug}
      apiPath = '/v1/api/$typeOrPath';
    } else {
      // Default list endpoints: /v1/api/danh-sach/{type}
      apiPath = '/v1/api/danh-sach/$typeOrPath';
    }
    final response = await apiClient.get(apiPath, queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
    return _parseItems(response);
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
    final queryParams = <String, String>{
      'keyword': keyword,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (country != null && country.isNotEmpty) queryParams['country'] = country;
    if (year != null && year > 0) queryParams['year'] = year.toString();

    final response = await apiClient.get('/v1/api/tim-kiem', queryParameters: queryParams);

    String cdnDomain = 'https://phimimg.com';
    List itemsJson = [];
    int totalItems = 0;
    int currentPage = page;
    int totalPages = 1;

    if (response['data'] != null && response['data'] is Map) {
      final data = response['data'] as Map<String, dynamic>;
      if (data['APP_DOMAIN_CDN_IMAGE'] != null) {
        cdnDomain = data['APP_DOMAIN_CDN_IMAGE'].toString();
      }
      if (data['items'] != null && data['items'] is List) {
        itemsJson = data['items'] as List;
      }
      if (data['params'] != null && data['params'] is Map) {
        final params = data['params'] as Map<String, dynamic>;
        if (params['pagination'] != null && params['pagination'] is Map) {
          final pagination = params['pagination'] as Map<String, dynamic>;
          totalItems = (pagination['totalItems'] as num?)?.toInt() ?? 0;
          currentPage = (pagination['currentPage'] as num?)?.toInt() ?? page;
          totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;
        }
      }
    }

    final models = itemsJson
        .map((item) => KKPhimMovieModel.fromJson(item as Map<String, dynamic>, cdnDomain))
        .toList();

    return MovieSearchResult(
      movies: models.map((m) => m.toEntity()).toList(),
      totalItems: totalItems,
      currentPage: currentPage,
      totalPages: totalPages,
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Detail Screen APIs
  // ────────────────────────────────────────────────────────────────────

  @override
  Future<MovieDetail> fetchMovieDetail(String slug) async {
    final response = await apiClient.get('/v1/api/phim/$slug');
    return MovieDetailModel.fromApiResponse(response);
  }

  @override
  Future<List<CastMember>> fetchPeoples(String slug) async {
    try {
      final response = await apiClient.get('/v1/api/phim/$slug/peoples');
      if (response['data'] == null) return [];

      final data = response['data'] as Map<String, dynamic>;
      final profileSizes = data['profile_sizes'] as Map<String, dynamic>? ?? {};
      final baseUrl = profileSizes['w185']?.toString() ?? 'https://image.tmdb.org/t/p/w185';

      final peoples = data['peoples'] as List? ?? [];
      return peoples.map((p) {
        final profilePath = p['profile_path']?.toString() ?? '';
        return CastMember(
          name: p['name']?.toString() ?? '',
          character: p['character']?.toString() ?? '',
          profileUrl: profilePath.isNotEmpty ? '$baseUrl$profilePath' : '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<String>> fetchKeywords(String slug) async {
    try {
      final response = await apiClient.get('/v1/api/phim/$slug/keywords');
      if (response['data'] == null) return [];

      final data = response['data'] as Map<String, dynamic>;
      final keywords = data['keywords'] as List? ?? [];
      return keywords
          .map((k) => k['name']?.toString() ?? '')
          .where((k) => k.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
