import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/search_provider.dart';
import '../../widgets/cards/movie_card.dart';
import '../../widgets/common/movie_card_skeleton.dart';
import '../detail/movie_detail_screen.dart';

import '../../../core/network/api_client.dart';
import '../../../data/datasources/movie_remote_datasource.dart';
import '../../../data/repositories/movie_repository_impl.dart';

/// Màn hình Tìm Kiếm Phim (Search Screen)
/// Thiết kế theo chuẩn Linear-clean / Cinematic Dark:
/// - Kích hoạt tìm kiếm khi gõ xong và bấm Submit / Nút Tìm kiếm
/// - Trạng thái khám phá ban đầu (Lịch sử tìm kiếm + Từ khóa thịnh hành + Thể loại nhanh)
/// - Shimmer loading skeleton khi đang tải
/// - Grid 2 cột responsive với cuộn phân trang vô tận
/// - Empty state tinh tế khi không có kết quả
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final apiClient = ApiClient();
        final datasource = MovieRemoteDataSourceImpl(apiClient: apiClient);
        final repository = MovieRepositoryImpl(remoteDataSource: datasource);
        return SearchProvider(repository: repository);
      },
      child: const _SearchScreenContent(),
    );
  }
}

class _SearchScreenContent extends StatefulWidget {
  const _SearchScreenContent();

  @override
  State<_SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<_SearchScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _trendingKeywords = [
    'One Piece',
    'Shin Cậu Bé Bút Chì',
    'Conan',
    'Doraemon',
    'Avengers',
    'Minions',
    'Avatar',
    'Batman',
    'Người Nhện',
    'Hành Động',
  ];

  static const List<Map<String, String>> _quickGenres = [
    {'name': 'Hành Động', 'query': 'Hành Động'},
    {'name': 'Hoạt Hình', 'query': 'Hoạt Hình'},
    {'name': 'Kinh Dị', 'query': 'Kinh Dị'},
    {'name': 'Tình Cảm', 'query': 'Tình Cảm'},
    {'name': 'Khoa Học Viễn Tưởng', 'query': 'Viễn Tưởng'},
    {'name': 'Chiếu Rạp', 'query': 'Chiếu Rạp'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 300) {
      context.read<SearchProvider>().loadMore();
    }
  }

  void _executeSearch(String query) {
    _focusNode.unfocus();
    if (query.trim().isNotEmpty) {
      _searchController.text = query.trim();
      context.read<SearchProvider>().search(query);
    }
  }

  void _navigateToDetail(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(slug: movie.slug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: _buildSearchBar(context, searchProvider),
      ),
      body: GestureDetector(
        onTap: () => _focusNode.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: _buildBody(context, searchProvider),
      ),
    );
  }

  // ── Search Input Field ──
  Widget _buildSearchBar(BuildContext context, SearchProvider provider) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focusNode.hasFocus ? AppColors.primary : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: 'Tìm tên phim, diễn viên, anime...',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: _executeSearch,
              onChanged: (val) => setState(() {}),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.textMuted,
                size: 18,
              ),
              onPressed: () {
                _searchController.clear();
                provider.clearSearch();
                setState(() {});
              },
            ),
          // Nút Tìm Kiếm rõ ràng
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TextButton(
              onPressed: () => _executeSearch(_searchController.text),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.primary,
              ),
              child: const Text(
                'Tìm',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Main Body Switcher ──
  Widget _buildBody(BuildContext context, SearchProvider provider) {
    if (provider.isLoading) {
      return _buildSkeletonGrid();
    }

    if (!provider.hasSearched) {
      return _buildDiscoveryView(context, provider);
    }

    if (provider.movies.isEmpty) {
      return _buildEmptyState(provider.keyword);
    }

    return _buildResultsGrid(context, provider);
  }

  // ── 1. Discovery Initial View ──
  Widget _buildDiscoveryView(BuildContext context, SearchProvider provider) {
    final recent = provider.recentSearches;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // ── Recent Searches ──
        if (recent.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tìm kiếm gần đây',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => provider.clearRecentSearches(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Xóa tất cả',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent.map((term) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _executeSearch(term),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            term,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => provider.removeRecentSearch(term),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // ── Trending Keywords ──
        const Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.primary,
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              'Từ khóa thịnh hành',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trendingKeywords.map((tag) {
            return ActionChip(
              label: Text(tag),
              labelStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.border, width: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              onPressed: () => _executeSearch(tag),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // ── Quick Explore Genres ──
        const Row(
          children: [
            Icon(
              Icons.category_outlined,
              color: AppColors.accentGold,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'Khám phá theo thể loại',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _quickGenres.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final genre = _quickGenres[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _executeSearch(genre['query']!),
                  child: Center(
                    child: Text(
                      genre['name']!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── 2. Loading Shimmer Grid ──
  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (context, index) => const MovieCardSkeleton(width: null),
    );
  }

  // ── 3. Results Grid View ──
  Widget _buildResultsGrid(BuildContext context, SearchProvider provider) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // Result summary banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Kết quả cho "${provider.keyword}"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (provider.totalItems > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${provider.totalItems} phim',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Movie grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 14,
              childAspectRatio: 0.58,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final movie = provider.movies[index];
                return MovieCard(
                  movie: movie,
                  width: null,
                  onTap: () => _navigateToDetail(context, movie),
                );
              },
              childCount: provider.movies.length,
            ),
          ),
        ),

        // Infinite pagination indicator
        if (provider.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

        // Bottom space to avoid navigation bar overlap
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // ── 4. Empty State View ──
  Widget _buildEmptyState(String keyword) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.textMuted,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Không tìm thấy phim "$keyword"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thử kiểm tra lại chính tả hoặc tìm kiếm bằng từ khóa ngắn gọn hơn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
