import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/bookmark_provider.dart';
import '../../widgets/cards/movie_card.dart';
import '../../widgets/common/app_network_image.dart';
import '../detail/movie_detail_screen.dart';

enum BookmarkViewMode { grid, list }

/// Màn hình Danh sách Phim Yêu thích (Bookmark Screen)
/// Thiết kế chuẩn Linear-style / Dark modern:
/// - Header với số lượng phim đã lưu + Nút chuyển chế độ xem (Lưới / Danh sách)
/// - Empty state chỉn chu với CTA khám phá
/// - Hỗ trợ thao tác xóa nhanh hoặc vuốt để xóa
class BookmarkScreen extends StatefulWidget {
  final VoidCallback? onExploreNow;

  const BookmarkScreen({super.key, this.onExploreNow});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  BookmarkViewMode _viewMode = BookmarkViewMode.grid;

  void _navigateToDetail(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(slug: movie.slug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final bookmarks = bookmarkProvider.bookmarks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Danh Sách Yêu Thích',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (bookmarks.isNotEmpty) ...[
            // Toggle view mode button
            IconButton(
              tooltip: _viewMode == BookmarkViewMode.grid
                  ? 'Chuyển sang dạng danh sách'
                  : 'Chuyển sang dạng lưới',
              icon: Icon(
                _viewMode == BookmarkViewMode.grid
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _viewMode = _viewMode == BookmarkViewMode.grid
                      ? BookmarkViewMode.list
                      : BookmarkViewMode.grid;
                });
              },
            ),
            // Clear all button with confirmation dialog
            IconButton(
              tooltip: 'Xóa tất cả',
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: AppColors.textMuted,
                size: 22,
              ),
              onPressed: () => _confirmClearAll(context, bookmarkProvider),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: bookmarks.isEmpty
          ? _buildEmptyState(context)
          : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ── Counter bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bookmark_rounded,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${bookmarks.length} bộ phim đã lưu',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Movies Content ──
                if (_viewMode == BookmarkViewMode.grid)
                  _buildGridContent(bookmarks)
                else
                  _buildListContent(bookmarks, bookmarkProvider),

                // Bottom padding to avoid navigation bar overlap
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Atmospheric glowing icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                color: AppColors.textMuted,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có phim yêu thích nào',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Hãy thêm các bộ phim đặc sắc vào danh sách để dễ dàng xem lại bất cứ khi nào.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            // CTA explore button
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onExploreNow != null) {
                  widget.onExploreNow!();
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text(
                'Khám phá phim ngay',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridContent(List<Movie> bookmarks) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 14,
          mainAxisSpacing: 18,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final movie = bookmarks[index];
            return MovieCard(
              movie: movie,
              width: null, // Grid mode
              onTap: () => _navigateToDetail(context, movie),
            );
          },
          childCount: bookmarks.length,
        ),
      ),
    );
  }

  Widget _buildListContent(
    List<Movie> bookmarks,
    BookmarkProvider provider,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final movie = bookmarks[index];
            return Dismissible(
              key: Key(movie.slug),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              onDismissed: (_) {
                provider.removeBookmark(movie.slug);
                AppSnackBar.show(
                  context,
                  message: 'Đã xóa "${movie.title}" khỏi danh sách yêu thích',
                  icon: Icons.bookmark_remove_rounded,
                  iconColor: AppColors.textSecondary,
                );
              },
              child: _BookmarkListItem(
                movie: movie,
                onTap: () => _navigateToDetail(context, movie),
                onDelete: () => provider.removeBookmark(movie.slug),
              ),
            );
          },
          childCount: bookmarks.length,
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, BookmarkProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        title: const Text(
          'Xóa toàn bộ danh sách?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Tất cả các bộ phim yêu thích đã lưu sẽ bị xóa khỏi thiết bị của bạn.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.clearAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }
}

/// Landscape row item for Bookmark list view
class _BookmarkListItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BookmarkListItem({
    required this.movie,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = movie.posterUrl.isNotEmpty
        ? movie.posterUrl
        : movie.backdropUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // ── Poster Thumbnail ──
                AppNetworkImage(
                  imageUrl: imageUrl,
                  width: 70,
                  height: 95,
                  borderRadius: BorderRadius.circular(8),
                  fit: BoxFit.cover,
                  memCacheWidth: 140,
                  memCacheHeight: 190,
                  errorWidget: Container(
                    width: 70,
                    height: 95,
                    color: AppColors.surfaceLight,
                    child: const Center(
                      child: Icon(
                        Icons.movie_outlined,
                        color: AppColors.textMuted,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // ── Info column ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.accentGold,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  ${movie.year}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          if (movie.quality.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                movie.quality,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.genre.isNotEmpty ? movie.genre : 'Chưa phân loại',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Delete action button ──
                IconButton(
                  icon: const Icon(
                    Icons.bookmark_remove_rounded,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                  tooltip: 'Bỏ lưu',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
