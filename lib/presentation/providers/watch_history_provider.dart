import 'package:flutter/material.dart';
import '../../data/datasources/watch_history_local_datasource.dart';
import '../../domain/entities/watch_history_item.dart';

class WatchHistoryProvider extends ChangeNotifier {
  final WatchHistoryLocalDataSource _dataSource;

  WatchHistoryProvider({WatchHistoryLocalDataSource? dataSource})
      : _dataSource = dataSource ?? WatchHistoryLocalDataSource();

  List<WatchHistoryItem> _historyList = [];
  bool _isLoading = false;

  List<WatchHistoryItem> get historyList => _historyList;
  bool get isLoading => _isLoading;
  bool get hasHistory => _historyList.isNotEmpty;

  /// Load all history records from local storage
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _historyList = await _dataSource.getHistoryList();
    _isLoading = false;
    notifyListeners();
  }

  /// Check if a specific episode was clicked / watched
  bool isEpisodeWatched(String movieSlug, String episodeSlug) {
    if (movieSlug.isEmpty || episodeSlug.isEmpty) return false;
    final item = getHistory(movieSlug);
    if (item == null) return false;
    return item.watchedEpisodeSlugs.contains(episodeSlug);
  }

  /// Get watch history item for a movie
  WatchHistoryItem? getHistory(String movieSlug) {
    if (movieSlug.isEmpty) return null;
    try {
      return _historyList.firstWhere((e) => e.movieSlug == movieSlug);
    } catch (_) {
      return null;
    }
  }

  /// Mark an episode as watched / clicked
  Future<void> markEpisodeWatched({
    required String movieSlug,
    required String movieTitle,
    required String episodeSlug,
    required String episodeName,
    String posterUrl = '',
    String backdropUrl = '',
    int serverIndex = 0,
    int positionSeconds = 0,
    int durationSeconds = 0,
  }) async {
    if (movieSlug.isEmpty || episodeSlug.isEmpty) return;

    final existing = getHistory(movieSlug);
    final watchedList = List<String>.from(existing?.watchedEpisodeSlugs ?? []);
    if (!watchedList.contains(episodeSlug)) {
      watchedList.add(episodeSlug);
    }

    final newItem = WatchHistoryItem(
      movieSlug: movieSlug,
      movieTitle: movieTitle.isNotEmpty ? movieTitle : (existing?.movieTitle ?? ''),
      posterUrl: posterUrl.isNotEmpty ? posterUrl : (existing?.posterUrl ?? ''),
      backdropUrl: backdropUrl.isNotEmpty ? backdropUrl : (existing?.backdropUrl ?? ''),
      episodeName: episodeName,
      episodeSlug: episodeSlug,
      serverIndex: serverIndex,
      positionSeconds: positionSeconds > 0 ? positionSeconds : (existing?.positionSeconds ?? 0),
      durationSeconds: durationSeconds > 0 ? durationSeconds : (existing?.durationSeconds ?? 0),
      watchedEpisodeSlugs: watchedList,
      updatedAt: DateTime.now(),
    );

    // Update in-memory list immediately
    _historyList.removeWhere((e) => e.movieSlug == movieSlug);
    _historyList.insert(0, newItem);
    notifyListeners();

    // Persist to local storage
    await _dataSource.saveItem(newItem);
  }

  /// Update video playback timestamp / duration progress
  Future<void> updateProgress({
    required String movieSlug,
    required String movieTitle,
    required String episodeSlug,
    required String episodeName,
    required int positionSeconds,
    required int durationSeconds,
    String posterUrl = '',
    String backdropUrl = '',
    int serverIndex = 0,
  }) async {
    if (movieSlug.isEmpty) return;

    final existing = getHistory(movieSlug);
    final watchedList = List<String>.from(existing?.watchedEpisodeSlugs ?? []);
    if (episodeSlug.isNotEmpty && !watchedList.contains(episodeSlug)) {
      watchedList.add(episodeSlug);
    }

    final newItem = WatchHistoryItem(
      movieSlug: movieSlug,
      movieTitle: movieTitle.isNotEmpty ? movieTitle : (existing?.movieTitle ?? ''),
      posterUrl: posterUrl.isNotEmpty ? posterUrl : (existing?.posterUrl ?? ''),
      backdropUrl: backdropUrl.isNotEmpty ? backdropUrl : (existing?.backdropUrl ?? ''),
      episodeName: episodeName.isNotEmpty ? episodeName : (existing?.episodeName ?? 'Tập 1'),
      episodeSlug: episodeSlug.isNotEmpty ? episodeSlug : (existing?.episodeSlug ?? ''),
      serverIndex: serverIndex,
      positionSeconds: positionSeconds,
      durationSeconds: durationSeconds,
      watchedEpisodeSlugs: watchedList,
      updatedAt: DateTime.now(),
    );

    _historyList.removeWhere((e) => e.movieSlug == movieSlug);
    _historyList.insert(0, newItem);
    notifyListeners();

    await _dataSource.saveItem(newItem);
  }

  /// Delete a history item
  Future<void> deleteHistory(String movieSlug) async {
    _historyList.removeWhere((e) => e.movieSlug == movieSlug);
    notifyListeners();
    await _dataSource.deleteItem(movieSlug);
  }

  /// Clear all history
  Future<void> clearAll() async {
    _historyList.clear();
    notifyListeners();
    await _dataSource.clearAll();
  }
}
