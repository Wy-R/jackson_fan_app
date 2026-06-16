class WorkItem {
  const WorkItem({
    required this.id,
    required this.type,
    required this.title,
    required this.year,
    required this.cover,
    required this.description,
  });

  final String id;
  final String type;
  final String title;
  final int year;
  final String cover;
  final String description;
}
