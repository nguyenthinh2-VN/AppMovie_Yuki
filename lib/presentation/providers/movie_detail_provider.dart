import 'package:flutter/material.dart';
import '../../domain/entities/cast_member.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/repositories/movie_repository.dart';

class MovieDetailProvider extends ChangeNotifier {
  final MovieRepository repository;

  MovieDetailProvider({required this.repository});

  bool _isLoading = true;
  String? _errorMessage;
  MovieDetail? _movieDetail;
  List<CastMember> _castMembers = [];
  List<String> _keywords = [];
  int _selectedServerIndex = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MovieDetail? get movieDetail => _movieDetail;
  List<CastMember> get castMembers => _castMembers;
  List<String> get keywords => _keywords;
  int get selectedServerIndex => _selectedServerIndex;

  void selectServer(int index) {
    _selectedServerIndex = index;
    notifyListeners();
  }

  Future<void> loadMovieDetail(String slug) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedServerIndex = 0;
    notifyListeners();

    try {
      // Fetch detail first (critical), then sub-resources in parallel
      _movieDetail = await repository.getMovieDetail(slug);
      _isLoading = false;
      notifyListeners();

      // Fetch sub-resources in parallel (non-blocking)
      final results = await Future.wait([
        repository.getMoviePeoples(slug).catchError((_) => <CastMember>[]),
        repository.getMovieKeywords(slug).catchError((_) => <String>[]),
      ]);

      _castMembers = results[0] as List<CastMember>;
      _keywords = results[1] as List<String>;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải thông tin phim. Vui lòng thử lại.';
      _isLoading = false;
      notifyListeners();
    }
  }
}
