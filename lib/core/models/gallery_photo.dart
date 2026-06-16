class GalleryPhoto {
  const GalleryPhoto({
    required this.id,
    required this.title,
    required this.image,
    required this.tags,
  });

  final String id;
  final String title;
  final String image;
  final List<String> tags;
}
