import 'package:flutter/material.dart';
import '../../data/mock/mock_movies.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

class HomeProvider extends ChangeNotifier {
  final MovieRepository repository;

  HomeProvider({required this.repository});

  bool _isLoading = true;
  String? _errorMessage;

  List<Movie> _featuredMovies = [];
  List<Movie> _seriesMovies = [];
  List<Movie> _newReleases = [];
  List<Movie> _top10Movies = [];
  List<Movie> _theaterMovies = [];
  List<Movie> _animeMovies = [];
  List<Movie> _koreanMovies = [];
  List<String> _categories = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Movie> get featuredMovies => _featuredMovies.isNotEmpty ? _featuredMovies : MockMovies.featured;
  List<Movie> get seriesMovies => _seriesMovies.isNotEmpty ? _seriesMovies : MockMovies.trending;
  List<Movie> get newReleases => _newReleases.isNotEmpty ? _newReleases : MockMovies.newReleases;
  List<Movie> get top10Movies => _top10Movies.isNotEmpty ? _top10Movies : MockMovies.top10;
  List<Movie> get theaterMovies => _theaterMovies.isNotEmpty ? _theaterMovies : MockMovies.top10;
  List<Movie> get animeMovies => _animeMovies.isNotEmpty ? _animeMovies : MockMovies.anime;
  List<Movie> get koreanMovies => _koreanMovies.isNotEmpty ? _koreanMovies : MockMovies.korean;
  List<String> get categories => _categories.isNotEmpty ? _categories : [
    'Tất cả', 'Hành động', 'Phim Bộ', 'Kinh dị', 'Hoạt hình', 'Tình cảm', 'Khoa học viễn tưởng'
  ];

  Future<void> loadHomeData({bool isRefresh = false}) async {
    if (!isRefresh) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        repository.getFeaturedMovies().catchError((_) => <Movie>[]),
        repository.getSeriesMovies().catchError((_) => <Movie>[]),
        repository.getNewReleases().catchError((_) => <Movie>[]),
        repository.getTop10Movies().catchError((_) => <Movie>[]),
        repository.getTheaterMovies(limit: 15).catchError((_) => <Movie>[]),
        repository.getAnimeMovies().catchError((_) => <Movie>[]),
        repository.getKoreanMovies().catchError((_) => <Movie>[]),
        repository.getCategories().catchError((_) => <String>[]),
      ]);

      if (results[0].isNotEmpty) _featuredMovies = results[0] as List<Movie>;
      if (results[1].isNotEmpty) _seriesMovies = results[1] as List<Movie>;
      if (results[2].isNotEmpty) _newReleases = results[2] as List<Movie>;
      if (results[3].isNotEmpty) _top10Movies = results[3] as List<Movie>;
      if (results[4].isNotEmpty) _theaterMovies = results[4] as List<Movie>;
      if (results[5].isNotEmpty) _animeMovies = results[5] as List<Movie>;
      if (results[6].isNotEmpty) _koreanMovies = results[6] as List<Movie>;
      if ((results[7] as List<String>).isNotEmpty) _categories = results[7] as List<String>;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu mới từ máy chủ. Đang hiển thị danh sách sẵn có.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
