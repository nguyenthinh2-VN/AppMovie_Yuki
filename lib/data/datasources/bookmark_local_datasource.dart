import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/movie.dart';

abstract class BookmarkLocalDataSource {
  Future<List<Movie>> getBookmarks();
  Future<bool> saveBookmark(Movie movie);
  Future<bool> removeBookmark(String slug);
  Future<bool> isBookmarked(String slug);
  Future<bool> clearAllBookmarks();
}

class BookmarkLocalDataSourceImpl implements BookmarkLocalDataSource {
  static const String _bookmarkKey = 'yuki_bookmarked_movies_v1';

  Map<String, dynamic> _movieToJson(Movie m) {
    return {
      'id': m.id,
      'title': m.title,
      'slug': m.slug,
      'originName': m.originName,
      'posterUrl': m.posterUrl,
      'backdropUrl': m.backdropUrl,
      'rating': m.rating,
      'year': m.year,
      'genre': m.genre,
      'overview': m.overview,
      'quality': m.quality,
      'lang': m.lang,
      'episodeCurrent': m.episodeCurrent,
    };
  }

  Movie _movieFromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      originName: json['originName']?.toString() ?? '',
      posterUrl: json['posterUrl']?.toString() ?? '',
      backdropUrl: json['backdropUrl']?.toString() ?? '',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      year: (json['year'] is num) ? (json['year'] as num).toInt() : 2024,
      genre: json['genre']?.toString() ?? '',
      overview: json['overview']?.toString() ?? '',
      quality: json['quality']?.toString() ?? 'HD',
      lang: json['lang']?.toString() ?? 'Vietsub',
      episodeCurrent: json['episodeCurrent']?.toString() ?? '',
    );
  }

  @override
  Future<List<Movie>> getBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_bookmarkKey) ?? [];
      return listJson.map((itemStr) {
        final Map<String, dynamic> map = jsonDecode(itemStr);
        return _movieFromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> saveBookmark(Movie movie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getBookmarks();
      // Avoid duplicate
      final exists = currentList.any((m) => m.slug == movie.slug);
      if (!exists) {
        currentList.insert(0, movie); // Newest on top
        final stringList = currentList.map((m) => jsonEncode(_movieToJson(m))).toList();
        return await prefs.setStringList(_bookmarkKey, stringList);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> removeBookmark(String slug) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getBookmarks();
      currentList.removeWhere((m) => m.slug == slug);
      final stringList = currentList.map((m) => jsonEncode(_movieToJson(m))).toList();
      return await prefs.setStringList(_bookmarkKey, stringList);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isBookmarked(String slug) async {
    try {
      final bookmarks = await getBookmarks();
      return bookmarks.any((m) => m.slug == slug);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> clearAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_bookmarkKey);
    } catch (_) {
      return false;
    }
  }
}
