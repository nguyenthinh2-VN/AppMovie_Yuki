import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';

/// HLS (.m3u8) Video Player component with Chewie custom controls
class MovieVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String episodeName;
  final VoidCallback? onErrorFallback;

  const MovieVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.episodeName,
    this.onErrorFallback,
  });

  @override
  State<MovieVideoPlayer> createState() => _MovieVideoPlayerState();
}

class _MovieVideoPlayerState extends State<MovieVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant MovieVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposePlayer();
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isError = false;
      _errorMessage = '';
    });

    if (widget.videoUrl.isEmpty) {
      setState(() {
        _isError = true;
        _errorMessage = 'Không tìm thấy đường dẫn luồng phát (.m3u8)';
      });
      return;
    }

    try {
      final uri = Uri.parse(widget.videoUrl);
      _videoPlayerController = VideoPlayerController.networkUrl(uri);

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          bufferedColor: Colors.white.withValues(alpha: 0.3),
          backgroundColor: Colors.white.withValues(alpha: 0.1),
        ),
        placeholder: Container(
          color: AppColors.surface,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return _buildErrorOverlay(errorMessage);
        },
      );

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        final errStr = e.toString();
        if (e is UnimplementedError ||
            errStr.contains('UnimplementedError') ||
            errStr.contains('init() has not been implemented')) {
          if (widget.onErrorFallback != null) {
            widget.onErrorFallback!();
            return;
          }
        }
        setState(() {
          _isError = true;
          _errorMessage = 'Không thể khởi tạo luồng HLS: ${e.toString()}';
        });
      }
    }
  }

  void _disposePlayer() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  Widget _buildErrorOverlay(String message) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.primary,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            'Lỗi phát luồng video HLS',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _initializePlayer,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              if (widget.onErrorFallback != null) ...[
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: widget.onErrorFallback,
                  icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                  label: const Text('Chuyển sang Embed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: _isError
            ? _buildErrorOverlay(_errorMessage)
            : _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              ),
      ),
    );
  }
}
