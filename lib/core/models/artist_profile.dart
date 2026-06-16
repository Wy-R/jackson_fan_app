class ArtistProfile {
  const ArtistProfile({
    required this.name,
    required this.chineseName,
    required this.bio,
    required this.avatar,
    required this.heroImages,
  });

  final String name;
  final String chineseName;
  final String bio;
  final String avatar;
  final List<String> heroImages;
}
