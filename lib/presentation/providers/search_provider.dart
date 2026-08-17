import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

class SearchProvider extends ChangeNotifier {
  final MovieRepository repository;
  static const String _recentSearchesKey = 'yuki_recent_searches_v1';

  SearchProvider({required this.repository}) {
    loadRecentSearches();
  }

  String _keyword = '';
  List<Movie> _movies = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _hasSearched = false;
  List<String> _recentSearches = [];

  String get keyword => _keyword;
  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasSearched => _hasSearched;
  List<String> get recentSearches => _recentSearches;

  Future<void> loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
      notifyListeners();
    } catch (_) {
      _recentSearches = [];
    }
  }

  Future<void> _saveRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches.remove(clean);
      _recentSearches.insert(0, clean);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
      await prefs.setStringList(_recentSearchesKey, _recentSearches);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> removeRecentSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches.remove(query);
      await prefs.setStringList(_recentSearchesKey, _recentSearches);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches.clear();
      await prefs.remove(_recentSearchesKey);
      notifyListeners();
    } catch (_) {}
  }

  /// Kích hoạt tìm kiếm khi người dùng nhấn nút Tìm kiếm hoặc Submit bàn phím
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _keyword = trimmed;
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasSearched = true;
    _movies = [];
    notifyListeners();

    _saveRecentSearch(trimmed);

    try {
      final result = await repository.searchMovies(trimmed, page: 1, limit: 24);
      _movies = result.movies;
      _totalItems = result.totalItems;
      _currentPage = result.currentPage;
      _totalPages = result.totalPages;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng.';
      _movies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải thêm kết quả khi cuộn xuống đáy
  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || _currentPage >= _totalPages || _keyword.isEmpty) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await repository.searchMovies(_keyword, page: nextPage, limit: 24);
      _movies.addAll(result.movies);
      _currentPage = result.currentPage;
      _totalPages = result.totalPages;
    } catch (_) {
      // Keep existing movies on page load error
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _keyword = '';
    _movies = [];
    _isLoading = false;
    _isLoadingMore = false;
    _errorMessage = null;
    _hasSearched = false;
    notifyListeners();
  }
}
