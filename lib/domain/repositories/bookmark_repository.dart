import '../entities/movie.dart';

abstract class BookmarkRepository {
  Future<List<Movie>> getBookmarks();
  Future<bool> saveBookmark(Movie movie);
  Future<bool> removeBookmark(String slug);
  Future<bool> isBookmarked(String slug);
  Future<bool> clearAllBookmarks();
}
