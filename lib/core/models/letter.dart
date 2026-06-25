/// 树洞信件模型：用户写下的、仅本人可见的私密文字。
///
/// 数据存储在本地 shared_preferences（JSON 数组）。
/// [id] 由时间戳生成，保证唯一；[mood] 为可选的心情表情。
class Letter {
  const Letter({
    required this.id,
    required this.content,
    required this.createdAt,
    this.mood,
  });

  /// 唯一标识（毫秒时间戳字符串）。
  final String id;

  /// 信件正文。
  final String content;

  /// 创建时间。
  final DateTime createdAt;

  /// 心情表情，如 "😊"。可空（没选心情时为 null）。
  final String? mood;

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'mood': mood,
      };

  factory Letter.fromJson(Map<String, dynamic> json) => Letter(
        id: json['id'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        mood: json['mood'] as String?,
      );
}
