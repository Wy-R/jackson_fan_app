/// 收藏记录模型：保存一张每日一言卡片的截图及其元数据。
///
/// 截图以 PNG 形式存储在 App 本地目录，[imagePath] 为文件路径。
/// [id] 由日期 + 随机后缀组成，保证唯一。
class Favorite {
  const Favorite({
    required this.id,
    required this.date,
    required this.imagePath,
    required this.source,
    required this.lines,
  });

  /// 唯一标识，格式: "2026-06-20_a1b2c3"
  final String id;

  /// 收藏日期，格式: "2026-06-20"
  final String date;

  /// 截图文件的本地路径
  final String imagePath;

  /// 出处，如 "MAGIC MAN · 2022"
  final String source;

  /// 歌词/文案内容
  final List<String> lines;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'imagePath': imagePath,
        'source': source,
        'lines': lines,
      };

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json['id'] as String,
        date: json['date'] as String,
        imagePath: json['imagePath'] as String,
        source: json['source'] as String,
        lines: List<String>.from(json['lines'] as List),
      );
}
