/// 每日一言单条数据。
///
/// date(显示日期)不在数据里存,由展示层用当前系统日期实时生成
/// （见 core/utils/date_formatter.dart 的 formatMonthDay）。
class DailyQuote {
  const DailyQuote({
    required this.background,
    required this.lines,
    required this.source,
  });

  /// 背景图资源路径。
  final String background;

  /// 引文(可多行)。
  final List<String> lines;

  /// 出处,如 'MAGIC MAN · 2022'。
  final String source;

  /// 从 JSON 解析(将来接 Firebase / 接口时用)。
  factory DailyQuote.fromJson(Map<String, dynamic> json) {
    return DailyQuote(
      background: json['background'] as String,
      lines: (json['lines'] as List).cast<String>(),
      source: json['source'] as String,
    );
  }

  /// 序列化为 JSON(收藏时保存元数据用)。
  Map<String, dynamic> toJson() => {
        'background': background,
        'lines': lines,
        'source': source,
      };
}
