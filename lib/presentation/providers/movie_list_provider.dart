import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

class MovieListProvider extends ChangeNotifier {
  final MovieRepository repository;

  MovieListProvider({required this.repository});

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _currentTypeOrPath = '';
  String? _errorMessage;

  List<Movie> _movies = [];

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  List<Movie> get movies => _movies;

  Future<void> init(String typeOrPath) async {
    _currentTypeOrPath = typeOrPath;
    _currentPage = 1;
    _hasMore = true;
    _isLoading = true;
    _errorMessage = null;
    _movies = [];
    notifyListeners();

    try {
      final newMovies = await repository.getMoviesByFilter(_currentTypeOrPath, page: _currentPage);
      _movies = newMovies;
      if (newMovies.length < 20) {
        _hasMore = false;
      }
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách phim. Vui lòng kiểm tra lại kết nối.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newMovies = await repository.getMoviesByFilter(_currentTypeOrPath, page: nextPage);

      if (newMovies.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        _movies.addAll(newMovies);
        if (newMovies.length < 20) {
          _hasMore = false;
        }
      }
    } catch (_) {
      // Quietly handle pagination load error
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await init(_currentTypeOrPath);
  }
}
