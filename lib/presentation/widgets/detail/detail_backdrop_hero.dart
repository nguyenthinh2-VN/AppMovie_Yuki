import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_network_image.dart';

/// Full-width backdrop hero with gradient fade overlay & centered floating poster
class DetailBackdropHero extends StatelessWidget {
  final String backdropUrl;
  final String posterUrl;
  final VoidCallback onBack;

  const DetailBackdropHero({
    super.key,
    required this.backdropUrl,
    required this.posterUrl,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final heroHeight = (screenWidth * 0.72).clamp(270.0, 350.0);
    final displayBackdrop = backdropUrl.isNotEmpty ? backdropUrl : posterUrl;

    return SizedBox(
      width: double.infinity,
      height:
          heroHeight +
          70, // Gives room for poster to hang down lower over the backdrop
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ── 1. Backdrop image ──
          SizedBox(
            width: double.infinity,
            height: heroHeight,
            child: AppNetworkImage(
              imageUrl: displayBackdrop,
              fit: BoxFit.cover,
              memCacheWidth: 800,
              errorWidget: Container(color: AppColors.surface),
            ),
          ),

          // ── 2. Dark gradient overlay (fade from transparent to background) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight + 2,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x600D0C11), // Top dark for status bar
                    Color(
                      0x100D0C11,
                    ), // Middle clear so backdrop image is bright
                    Color(0xAA0D0C11), // Smooth fade
                    Color(0xFF0D0C11), // Solid background at bottom edge
                  ],
                  stops: [0.0, 0.4, 0.85, 1.0],
                ),
              ),
            ),
          ),

          // ── 3. Centered floating Poster (positioned lower) ──
          Positioned(
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 22,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppNetworkImage(
                  imageUrl: posterUrl.isNotEmpty ? posterUrl : backdropUrl,
                  width: 140,
                  height: 200,
                  borderRadius: BorderRadius.circular(12),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // ── 4. Back button ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Material(
              color: Colors.black.withValues(alpha: 0.5),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onBack,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
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
