import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/bookmark_provider.dart';
import '../common/app_network_image.dart';

/// Netflix/Disney+ style immersive fullscreen hero carousel.
/// Backdrop covers 100% of the slide area with cinematic gradient overlays.
class HeroCarousel extends StatefulWidget {
  final List<Movie> movies;
  final void Function(Movie movie)? onWatchNow;
  final void Function(Movie movie)? onAddToList;

  const HeroCarousel({
    super.key,
    required this.movies,
    this.onWatchNow,
    this.onAddToList,
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.movies.isEmpty) return;
      final nextPage = (_currentPage + 1) % widget.movies.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = (screenHeight * 0.52).clamp(400.0, 560.0);

    return SizedBox(
      height: carouselHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // ── PageView ──
          PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _ImmersiveSlide(
              movie: widget.movies[index],
              onWatchNow: widget.onWatchNow,
              onAddToList: widget.onAddToList,
            ),
          ),

          // ── Dot indicator (compact for 15 items) ──
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.movies.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: _currentPage == i ? 18 : 5,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single immersive slide — full-bleed backdrop with cinematic gradient overlay
class _ImmersiveSlide extends StatelessWidget {
  final Movie movie;
  final void Function(Movie movie)? onWatchNow;
  final void Function(Movie movie)? onAddToList;

  const _ImmersiveSlide({
    required this.movie,
    this.onWatchNow,
    this.onAddToList,
  });

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final isBookmarked = bookmarkProvider.isBookmarked(movie.slug);

    // Prefer backdrop (thumb_url = landscape 16:9) for immersive fill
    final imageUrl = movie.backdropUrl.isNotEmpty
        ? movie.backdropUrl
        : movie.posterUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1. Full-bleed backdrop image ──
        AppNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          memCacheWidth: 1000,
          errorWidget: Container(
            color: AppColors.surface,
            child: const Center(
              child: Icon(
                Icons.movie_outlined,
                color: AppColors.textMuted,
                size: 48,
              ),
            ),
          ),
        ),

        // ── 2. Top gradient (status bar readability) ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xBB0D0C11), Color(0x000D0C11)],
              ),
            ),
          ),
        ),

        // ── 3. Bottom cinematic gradient (fade to background) ──
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 260,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x000D0C11), // transparent
                  Color(0x800D0C11), // 50%
                  Color(0xDD0D0C11), // 87%
                  Color(0xFF0D0C11), // solid
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // ── 4. Content overlay ──
        Positioned(
          bottom: 32,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Genre chip
              if (movie.genre.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    movie.genre,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

              // Title
              Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle: origin name + quality + duration + episodes
              Text(
                movie.overview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  // Watch Now — primary CTA
                  _PrimaryCTA(
                    onPressed: onWatchNow != null
                        ? () => onWatchNow!(movie)
                        : null,
                  ),

                  const SizedBox(width: 10),

                  // Add to List — secondary (dynamic state)
                  _SecondaryCTA(
                    isBookmarked: isBookmarked,
                    onPressed: onAddToList != null
                        ? () => onAddToList!(movie)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Primary CTA with ripple touch feedback
class _PrimaryCTA extends StatelessWidget {
  final VoidCallback? onPressed;
  const _PrimaryCTA({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Text(
                'Xem Ngay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary outline CTA with dynamic bookmarked state
class _SecondaryCTA extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback? onPressed;
  const _SecondaryCTA({this.isBookmarked = false, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isBookmarked
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isBookmarked
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isBookmarked ? Icons.bookmark_rounded : Icons.add_rounded,
                color: isBookmarked ? AppColors.primary : Colors.white.withValues(alpha: 0.85),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                isBookmarked ? 'Đã lưu' : 'Danh sách',
                style: TextStyle(
                  color: isBookmarked ? AppColors.primary : Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
