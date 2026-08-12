/// Represents a cast member (actor or director) with TMDB profile image
class CastMember {
  final String name;
  final String character;
  final String profileUrl;

  const CastMember({
    required this.name,
    this.character = '',
    this.profileUrl = '',
  });
}
