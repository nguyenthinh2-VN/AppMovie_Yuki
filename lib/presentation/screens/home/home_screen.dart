import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/watch_history_provider.dart';
import '../../widgets/carousel/hero_carousel.dart';
import '../../widgets/chips/category_chip_bar.dart';
import '../../widgets/navigation/main_navigation_bar.dart';
import '../../widgets/sections/continue_watching_section.dart';
import '../../widgets/sections/movie_section.dart';
import '../../widgets/sections/theater_section.dart';
import '../../widgets/sections/top10_section.dart';

import '../bookmark/bookmark_screen.dart';
import '../detail/movie_detail_screen.dart';
import '../list/movie_list_screen.dart';
import '../search/search_screen.dart';

/// Main Home Screen — assembles all section components with live KKPhim API data and Continue Watching history
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 0;

  void _navigateToSectionList(
    BuildContext context,
    String title,
    String typeOrPath,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieListScreen(title: title, typeOrPath: typeOrPath),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovieDetailScreen(slug: movie.slug)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final historyProvider = context.watch<WatchHistoryProvider>();

    Widget bodyContent;
    if (_currentNavIndex == 1) {
      bodyContent = const SearchScreen();
    } else if (_currentNavIndex == 2) {
      bodyContent = BookmarkScreen(
        onExploreNow: () => setState(() => _currentNavIndex = 0),
      );
    } else {
      bodyContent = RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await Future.wait([
            homeProvider.loadHomeData(isRefresh: true),
            historyProvider.loadHistory(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // 1. Hero Carousel
            SliverToBoxAdapter(
              child: HeroCarousel(
                movies: homeProvider.featuredMovies,
                onWatchNow: (movie) => _navigateToDetail(context, movie),
                onAddToList: (movie) async {
                  final isSaved = await context.read<BookmarkProvider>().toggleBookmark(movie);
                  if (context.mounted) {
                    AppSnackBar.showBookmarkToast(
                      context,
                      movieTitle: movie.title,
                      isSaved: isSaved,
                    );
                  }
                },
              ),
            ),

            // 2. Continue Watching (Xem Tiếp) section if history exists
            if (historyProvider.hasHistory) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: ContinueWatchingSection(
                  onItemTap: (item) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(slug: item.movieSlug),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Spacing
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 3. Category Chips
            SliverToBoxAdapter(
              child: CategoryChipBar(
                categories: homeProvider.categories,
                selectedIndex: _selectedCategoryIndex,
                onSelected: (index) {
                  setState(() => _selectedCategoryIndex = index);
                  final selectedCategory = homeProvider.categories[index];
                  if (selectedCategory != 'Tất cả') {
                    _navigateToSectionList(
                      context,
                      'Thể loại $selectedCategory',
                      'the-loai/$selectedCategory',
                    );
                  }
                },
              ),
            ),

            // Spacing
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 4. Phim Chiếu Rạp (UI 16:9)
            SliverToBoxAdapter(
              child: TheaterSection(
                movies: homeProvider.theaterMovies,
                onSeeAll: () => _navigateToSectionList(
                  context,
                  'Mãn Nhãn Với Phim Chiếu Rạp',
                  'phim-chieu-rap',
                ),
                onMovieTap: (movie) => _navigateToDetail(context, movie),
              ),
            ),

            // Spacing
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 5. Phim Bộ (API Phim Bộ)
            SliverToBoxAdapter(
              child: MovieSection(
                title: 'Phim Bộ',
                movies: homeProvider.seriesMovies,
                onSeeAll: () =>
                    _navigateToSectionList(context, 'Phim Bộ', 'phim-bo'),
                onMovieTap: (movie) => _navigateToDetail(context, movie),
              ),
            ),

            // Spacing
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 6. Mới Cập Nhật
            SliverToBoxAdapter(
              child: MovieSection(
                title: 'Mới Cập Nhật',
                movies: homeProvider.newReleases,
                onSeeAll: () =>
                    _navigateToSectionList(context, 'Mới Cập Nhật', 'phim-moi'),
                onMovieTap: (movie) => _navigateToDetail(context, movie),
              ),
            ),

            // Spacing
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 7. Top 10 Phim Lẻ
            SliverToBoxAdapter(
              child: Top10Section(
                movies: homeProvider.top10Movies,
                onSeeAll: () => _navigateToSectionList(
                  context,
                  'Top 10 Phim Lẻ',
                  'phim-le',
                ),
                onMovieTap: (movie) => _navigateToDetail(context, movie),
              ),
            ),

            // Spacing
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 8. Anime
            SliverToBoxAdapter(
              child: MovieSection(
                title: 'Anime',
                movies: homeProvider.animeMovies,
                onSeeAll: () => _navigateToSectionList(
                  context,
                  'Hoạt Hình & Anime',
                  'hoat-hinh',
                ),
                onMovieTap: (movie) => _navigateToDetail(context, movie),
              ),
            ),

            // Spacing
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 9. Phim Hàn
            SliverToBoxAdapter(
              child: MovieSection(
                title: 'Phim Hàn Quốc',
                movies: homeProvider.koreanMovies,
                onSeeAll: () => _navigateToSectionList(
                  context,
                  'Phim Hàn Quốc',
                  'quoc-gia/han-quoc',
                ),
                onMovieTap: (movie) => _navigateToDetail(context, movie),
              ),
            ),

            // Bottom padding (tránh bị nav bar che)
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: bodyContent,
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
    );
  }
}
