import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/bookmark_repository.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkRepository repository;

  BookmarkProvider({required this.repository}) {
    loadBookmarks();
  }

  List<Movie> _bookmarks = [];
  final Set<String> _bookmarkedSlugs = {};
  bool _isLoading = true;

  List<Movie> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  int get count => _bookmarks.length;

  bool isBookmarked(String slug) => _bookmarkedSlugs.contains(slug);

  Future<void> loadBookmarks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookmarks = await repository.getBookmarks();
      _bookmarkedSlugs
        ..clear()
        ..addAll(_bookmarks.map((m) => m.slug));
    } catch (_) {
      _bookmarks = [];
      _bookmarkedSlugs.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleBookmark(Movie movie) async {
    final slug = movie.slug;
    if (_bookmarkedSlugs.contains(slug)) {
      _bookmarkedSlugs.remove(slug);
      _bookmarks.removeWhere((m) => m.slug == slug);
      notifyListeners();
      await repository.removeBookmark(slug);
      return false;
    } else {
      _bookmarkedSlugs.add(slug);
      _bookmarks.insert(0, movie);
      notifyListeners();
      await repository.saveBookmark(movie);
      return true;
    }
  }

  Future<void> removeBookmark(String slug) async {
    if (_bookmarkedSlugs.contains(slug)) {
      _bookmarkedSlugs.remove(slug);
      _bookmarks.removeWhere((m) => m.slug == slug);
      notifyListeners();
      await repository.removeBookmark(slug);
    }
  }

  Future<void> clearAll() async {
    _bookmarks.clear();
    _bookmarkedSlugs.clear();
    notifyListeners();
    await repository.clearAllBookmarks();
  }
}
