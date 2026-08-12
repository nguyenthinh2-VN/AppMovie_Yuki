import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/movie_list_provider.dart';
import '../../widgets/cards/movie_card.dart';
import '../../widgets/common/movie_card_skeleton.dart';
import '../detail/movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  final String title;
  final String typeOrPath;

  const MovieListScreen({
    super.key,
    required this.title,
    required this.typeOrPath,
  });

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieListProvider>().init(widget.typeOrPath);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 300) {
      context.read<MovieListProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieListProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 5 : (screenWidth > 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? _buildSkeletonGrid(crossAxisCount)
          : provider.errorMessage != null
              ? _buildErrorView(context, provider)
              : RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () => provider.refresh(),
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.55,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final movie = provider.movies[index];
                              return MovieCard(
                                movie: movie,
                                width: null, // Dynamic width fitting the grid cell
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailScreen(slug: movie.slug),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: provider.movies.length,
                          ),
                        ),
                      ),
                      if (provider.isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSkeletonGrid(int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemBuilder: (context, index) => const MovieCardSkeleton(width: null),
    );
  }

  Widget _buildErrorView(BuildContext context, MovieListProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Có lỗi xảy ra',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => provider.refresh(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
