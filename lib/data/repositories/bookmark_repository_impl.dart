import '../../domain/entities/movie.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_local_datasource.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkLocalDataSource localDataSource;

  BookmarkRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Movie>> getBookmarks() async {
    return await localDataSource.getBookmarks();
  }

  @override
  Future<bool> saveBookmark(Movie movie) async {
    return await localDataSource.saveBookmark(movie);
  }

  @override
  Future<bool> removeBookmark(String slug) async {
    return await localDataSource.removeBookmark(slug);
  }

  @override
  Future<bool> isBookmarked(String slug) async {
    return await localDataSource.isBookmarked(slug);
  }

  @override
  Future<bool> clearAllBookmarks() async {
    return await localDataSource.clearAllBookmarks();
  }
}
