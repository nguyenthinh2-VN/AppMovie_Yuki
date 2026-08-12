import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Expandable synopsis section that shows HTML content as plain text
class DetailSynopsis extends StatefulWidget {
  final String htmlContent;

  const DetailSynopsis({super.key, required this.htmlContent});

  @override
  State<DetailSynopsis> createState() => _DetailSynopsisState();
}

class _DetailSynopsisState extends State<DetailSynopsis> {
  bool _expanded = false;

  /// Strip HTML tags and decode basic entities
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final plainText = _stripHtml(widget.htmlContent);

    if (plainText.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nội dung phim',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedCrossFade(
            firstChild: Text(
              plainText,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            secondChild: Text(
              plainText,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Thu gọn' : 'Xem thêm',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
