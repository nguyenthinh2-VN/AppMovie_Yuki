import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/bookmark_local_datasource.dart';
import 'data/datasources/movie_remote_datasource.dart';
import 'data/repositories/bookmark_repository_impl.dart';
import 'data/repositories/movie_repository_impl.dart';
import 'presentation/providers/bookmark_provider.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/providers/movie_list_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/watch_history_provider.dart';
import 'presentation/screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  PaintingBinding.instance.imageCache.maximumSize = 2000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 300 << 20;

  final apiClient = ApiClient();
  final remoteDataSource = MovieRemoteDataSourceImpl(apiClient: apiClient);
  final movieRepository = MovieRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );

  final bookmarkLocalDataSource = BookmarkLocalDataSourceImpl();
  final bookmarkRepository = BookmarkRepositoryImpl(
    localDataSource: bookmarkLocalDataSource,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              HomeProvider(repository: movieRepository)..loadHomeData(),
        ),
        ChangeNotifierProvider(
          create: (_) => MovieListProvider(repository: movieRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BookmarkProvider(repository: bookmarkRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(repository: movieRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchHistoryProvider()..loadHistory(),
        ),
      ],
      child: const YukiMovieApp(),
    ),
  );
}

class YukiMovieApp extends StatelessWidget {
  const YukiMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yuki Cinema App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
