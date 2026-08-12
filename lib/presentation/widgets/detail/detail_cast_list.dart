import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/cast_member.dart';

/// Horizontal scrollable cast/crew list with circular avatars
class DetailCastList extends StatelessWidget {
  final List<CastMember> castMembers;

  const DetailCastList({super.key, required this.castMembers});

  @override
  Widget build(BuildContext context) {
    if (castMembers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Diễn viên',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: castMembers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final cast = castMembers[index];
              return _CastCard(cast: cast);
            },
          ),
        ),
      ],
    );
  }
}

class _CastCard extends StatelessWidget {
  final CastMember cast;
  const _CastCard({required this.cast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceLight,
              border: Border.all(color: AppColors.border, width: 2),
              image: cast.profileUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(cast.profileUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: cast.profileUrl.isEmpty
                ? const Icon(Icons.person_rounded, color: AppColors.textMuted, size: 28)
                : null,
          ),
          const SizedBox(height: 6),
          // Name
          Text(
            cast.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Character
          if (cast.character.isNotEmpty)
            Text(
              cast.character,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}
