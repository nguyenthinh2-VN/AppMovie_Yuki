import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/movie_remote_datasource.dart';
import 'data/repositories/movie_repository_impl.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/providers/movie_list_provider.dart';
import 'presentation/screens/home/home_screen.dart';

void main() {
  final apiClient = ApiClient();
  final remoteDataSource = MovieRemoteDataSourceImpl(apiClient: apiClient);
  final movieRepository = MovieRepositoryImpl(
    remoteDataSource: remoteDataSource,
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
