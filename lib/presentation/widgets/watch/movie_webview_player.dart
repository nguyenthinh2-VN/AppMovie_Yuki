import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';

/// Fallback Embed Video Player using Webview
class MovieWebviewPlayer extends StatefulWidget {
  final String embedUrl;

  const MovieWebviewPlayer({
    super.key,
    required this.embedUrl,
  });

  @override
  State<MovieWebviewPlayer> createState() => _MovieWebviewPlayerState();
}

class _MovieWebviewPlayerState extends State<MovieWebviewPlayer> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() => _isLoading = false),
        ),
      );

    if (widget.embedUrl.isNotEmpty) {
      _controller.loadRequest(Uri.parse(widget.embedUrl));
    }
  }

  @override
  void didUpdateWidget(covariant MovieWebviewPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.embedUrl != widget.embedUrl && widget.embedUrl.isNotEmpty) {
      _controller.loadRequest(Uri.parse(widget.embedUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          if (widget.embedUrl.isNotEmpty)
            WebViewWidget(controller: _controller)
          else
            Container(
              color: AppColors.surface,
              child: const Center(
                child: Text(
                  'Không có link nhúng (embed) cho tập phim này',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            ),
          if (_isLoading)
            Container(
              color: AppColors.surface,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
              ),
            ),
        ],
      ),
    );
  }
}
