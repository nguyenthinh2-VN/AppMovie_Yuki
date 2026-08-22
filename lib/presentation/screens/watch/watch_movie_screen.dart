import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/episode.dart';
import '../../../domain/entities/movie_detail.dart';
import '../../providers/watch_history_provider.dart';
import '../../widgets/detail/detail_synopsis.dart';
import '../../widgets/watch/movie_video_player.dart';
import '../../widgets/watch/movie_webview_player.dart';
import '../../widgets/watch/watch_episode_selector.dart';

/// Player Screen (`WatchMovieScreen`)
/// Displays video player (HLS .m3u8 / Embed Webview fallback), server selector & episode grid
class WatchMovieScreen extends StatefulWidget {
  final MovieDetail movie;
  final Episode? initialEpisode;
  final int initialServerIndex;

  const WatchMovieScreen({
    super.key,
    required this.movie,
    this.initialEpisode,
    this.initialServerIndex = 0,
  });

  @override
  State<WatchMovieScreen> createState() => _WatchMovieScreenState();
}

class _WatchMovieScreenState extends State<WatchMovieScreen> {
  late int _selectedServerIndex;
  late Episode _currentEpisode;
  int _initialPositionSeconds = 0;
  bool _useEmbedPlayer = false;

  @override
  void initState() {
    super.initState();
    _selectedServerIndex = widget.initialServerIndex.clamp(
      0,
      widget.movie.servers.isNotEmpty ? widget.movie.servers.length - 1 : 0,
    );

    if (widget.initialEpisode != null) {
      _currentEpisode = widget.initialEpisode!;
    } else if (widget.movie.servers.isNotEmpty &&
        widget.movie.servers[_selectedServerIndex].episodes.isNotEmpty) {
      _currentEpisode = widget.movie.servers[_selectedServerIndex].episodes.first;
    } else {
      _currentEpisode = const Episode(name: 'Tập 1', slug: 'tap-1');
    }

    // Mark current episode as watched and get resume position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final historyProvider = context.read<WatchHistoryProvider>();
      final existing = historyProvider.getHistory(widget.movie.slug);

      if (existing != null &&
          (existing.episodeSlug == _currentEpisode.slug ||
              existing.episodeName == _currentEpisode.name)) {
        setState(() {
          _initialPositionSeconds = existing.positionSeconds;
        });
      }

      historyProvider.markEpisodeWatched(
        movieSlug: widget.movie.slug,
        movieTitle: widget.movie.title,
        episodeSlug: _currentEpisode.slug,
        episodeName: _currentEpisode.name,
        posterUrl: widget.movie.posterUrl,
        backdropUrl: widget.movie.backdropUrl,
        serverIndex: _selectedServerIndex,
      );
    });
  }

  void _onServerChanged(int newIndex) {
    setState(() {
      _selectedServerIndex = newIndex;
      final server = widget.movie.servers[newIndex];
      if (server.episodes.isNotEmpty) {
        final matching = server.episodes.firstWhere(
          (ep) => ep.slug == _currentEpisode.slug || ep.name == _currentEpisode.name,
          orElse: () => server.episodes.first,
        );
        _currentEpisode = matching;
        _initialPositionSeconds = 0;
      }
    });

    context.read<WatchHistoryProvider>().markEpisodeWatched(
      movieSlug: widget.movie.slug,
      movieTitle: widget.movie.title,
      episodeSlug: _currentEpisode.slug,
      episodeName: _currentEpisode.name,
      posterUrl: widget.movie.posterUrl,
      backdropUrl: widget.movie.backdropUrl,
      serverIndex: _selectedServerIndex,
    );
  }

  void _onEpisodeTap(Episode episode) {
    setState(() {
      _currentEpisode = episode;
      _initialPositionSeconds = 0;
    });

    // Mark episode as clicked/watched in history
    context.read<WatchHistoryProvider>().markEpisodeWatched(
      movieSlug: widget.movie.slug,
      movieTitle: widget.movie.title,
      episodeSlug: episode.slug,
      episodeName: episode.name,
      posterUrl: widget.movie.posterUrl,
      backdropUrl: widget.movie.backdropUrl,
      serverIndex: _selectedServerIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<WatchHistoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Đang xem: ${_currentEpisode.name}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Video Player Area (16:9) ──
            if (!_useEmbedPlayer)
              MovieVideoPlayer(
                key: ValueKey('${_currentEpisode.slug}_${_currentEpisode.linkM3u8}'),
                videoUrl: _currentEpisode.linkM3u8,
                title: widget.movie.title,
                episodeName: _currentEpisode.name,
                initialPositionSeconds: _initialPositionSeconds,
                onProgressUpdate: (positionSeconds, durationSeconds) {
                  historyProvider.updateProgress(
                    movieSlug: widget.movie.slug,
                    movieTitle: widget.movie.title,
                    episodeSlug: _currentEpisode.slug,
                    episodeName: _currentEpisode.name,
                    positionSeconds: positionSeconds,
                    durationSeconds: durationSeconds,
                    posterUrl: widget.movie.posterUrl,
                    backdropUrl: widget.movie.backdropUrl,
                    serverIndex: _selectedServerIndex,
                  );
                },
                onErrorFallback: () {
                  setState(() => _useEmbedPlayer = true);
                },
              )
            else
              MovieWebviewPlayer(
                embedUrl: _currentEpisode.linkEmbed,
              ),

            // ── 2. Player Mode Toggle Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _useEmbedPlayer ? Icons.open_in_browser_rounded : Icons.play_circle_outline_rounded,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _useEmbedPlayer ? 'Chế độ: Webview Embed' : 'Chế độ: Direct HLS (.m3u8)',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _useEmbedPlayer = !_useEmbedPlayer);
                    },
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: Text(
                      _useEmbedPlayer ? 'Dùng HLS Player' : 'Dùng Embed Player',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),

            // ── 3. Movie Title & Info ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.movie.title} - ${_currentEpisode.name}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                      ),
                      if (widget.movie.quality.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            widget.movie.quality,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (widget.movie.originName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.movie.originName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 4. Episode & Server Selector with Watched Indicators ──
            if (widget.movie.servers.isNotEmpty)
              WatchEpisodeSelector(
                movieSlug: widget.movie.slug,
                servers: widget.movie.servers,
                selectedServerIndex: _selectedServerIndex,
                currentEpisode: _currentEpisode,
                onServerChanged: _onServerChanged,
                onEpisodeTap: _onEpisodeTap,
              ),

            const SizedBox(height: 24),

            // ── 5. Synopsis ──
            if (widget.movie.content.isNotEmpty)
              DetailSynopsis(htmlContent: widget.movie.content),

            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
          ],
        ),
      ),
    );
  }
}
