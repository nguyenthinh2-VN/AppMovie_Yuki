import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/datasources/movie_remote_datasource.dart';
import '../../../data/repositories/movie_repository_impl.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/movie_detail_provider.dart';
import '../../widgets/detail/detail_backdrop_hero.dart';
import '../../widgets/detail/detail_info_section.dart';
import '../../widgets/detail/detail_action_buttons.dart';
import '../../widgets/detail/detail_synopsis.dart';
import '../../widgets/detail/detail_cast_list.dart';
import '../../widgets/detail/detail_episode_list.dart';
import '../watch/watch_movie_screen.dart';

/// Main movie detail screen
/// Navigate with: Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(slug: movie.slug)))
class MovieDetailScreen extends StatelessWidget {
  final String slug;

  const MovieDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final apiClient = ApiClient();
        final datasource = MovieRemoteDataSourceImpl(apiClient: apiClient);
        final repository = MovieRepositoryImpl(remoteDataSource: datasource);
        return MovieDetailProvider(repository: repository)..loadMovieDetail(slug);
      },
      child: const _MovieDetailView(),
    );
  }
}

class _MovieDetailView extends StatelessWidget {
  const _MovieDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<MovieDetailProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const _LoadingView();
          }

          if (provider.errorMessage != null) {
            return _ErrorView(
              message: provider.errorMessage!,
              onBack: () => Navigator.of(context).pop(),
            );
          }

          final movie = provider.movieDetail!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Backdrop Hero ──
                DetailBackdropHero(
                  backdropUrl: movie.backdropUrl,
                  posterUrl: movie.posterUrl,
                  onBack: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      // ── 2. Movie Info (Title, Rating, Chips) ──
                      DetailInfoSection(movie: movie),

                      const SizedBox(height: 20),

                      // ── 3. Action Buttons ──
                      Builder(
                        builder: (context) {
                          final bookmarkProvider = context.watch<BookmarkProvider>();
                          final isBookmarked = bookmarkProvider.isBookmarked(movie.slug);

                          return DetailActionButtons(
                            hasTrailer: movie.trailerUrl.isNotEmpty,
                            isBookmarked: isBookmarked,
                            onWatch: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => WatchMovieScreen(
                                    movie: movie,
                                    initialServerIndex: provider.selectedServerIndex,
                                  ),
                                ),
                              );
                            },
                            onTrailer: movie.trailerUrl.isNotEmpty ? () {
                              // TODO: Open trailer
                            } : null,
                            onBookmark: () async {
                              final isSaved = await context.read<BookmarkProvider>().toggleBookmark(movie.toMovie());
                              if (context.mounted) {
                                AppSnackBar.showBookmarkToast(
                                  context,
                                  movieTitle: movie.title,
                                  isSaved: isSaved,
                                );
                              }
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── 4. Synopsis ──
                      if (movie.content.isNotEmpty)
                        DetailSynopsis(htmlContent: movie.content),

                      const SizedBox(height: 24),

                      // ── 5. Cast List ──
                      DetailCastList(castMembers: provider.castMembers),

                      const SizedBox(height: 24),

                      // ── 6. Episode List (for series) ──
                      if (movie.servers.isNotEmpty)
                        DetailEpisodeList(
                          servers: movie.servers,
                          selectedServerIndex: provider.selectedServerIndex,
                          onServerChanged: (index) => provider.selectServer(index),
                          onEpisodeTap: (episode) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => WatchMovieScreen(
                                  movie: movie,
                                  initialEpisode: episode,
                                  initialServerIndex: provider.selectedServerIndex,
                                ),
                              ),
                            );
                          },
                        ),

                      // ── 7. Keywords ──
                      if (provider.keywords.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _KeywordsSection(keywords: provider.keywords),
                      ],

                      // ── 8. Views count ──
                      if (movie.view > 0) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.visibility_outlined, color: AppColors.textMuted, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatNumber(movie.view)} lượt xem',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

/// Keywords tags section
class _KeywordsSection extends StatelessWidget {
  final List<String> keywords;
  const _KeywordsSection({required this.keywords});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Từ khóa',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: keywords.map((keyword) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
                ),
                child: Text(
                  '#$keyword',
                  style: TextStyle(
                    color: AppColors.secondary.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Loading skeleton view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text(
            'Đang tải thông tin phim...',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Error view with retry
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  const _ErrorView({required this.message, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Quay lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceLight,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
