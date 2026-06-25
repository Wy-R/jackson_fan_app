import 'day_period.dart';
import 'song.dart';

/// 某个时段的完整内容：展示文案（label/emoji/description）+ 歌单。
///
/// 设计要点：
/// - [MusicPeriod] 枚举负责「有哪几段」以及每段的**默认**文案（兜底）。
/// - [PeriodContent] 负责「这一段当前实际显示什么」，数据来自远端/本地 JSON。
/// - 解析时，JSON 缺字段就回退到枚举里的默认值，保证 UI 永远有内容可显示。
class PeriodContent {
  const PeriodContent({
    required this.period,
    required this.label,
    required this.emoji,
    required this.description,
    required this.songs,
  });

  /// 所属时段（身份）。
  final MusicPeriod period;

  /// 展示名称，如 “早晨”。
  final String label;

  /// 展示 emoji，如 🌅。
  final String emoji;

  /// 问候描述文案。
  final String description;

  /// 该时段歌单（池子，通常 ≥5 首）。
  final List<Song> songs;

  /// 从单个时段的 JSON 解析。
  ///
  /// [period] 由调用方根据 JSON 的 key（morning/afternoon/night）传入，
  /// 用于在字段缺失时回退到枚举默认值。
  factory PeriodContent.fromJson(MusicPeriod period, Map<String, dynamic> json) {
    final songsJson = json['songs'] as List? ?? [];
    return PeriodContent(
      period: period,
      label: json['label'] as String? ?? period.label,
      emoji: json['emoji'] as String? ?? period.emoji,
      description: json['description'] as String? ?? period.description,
      songs: songsJson
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 纯兜底：完全没有远端数据时，用枚举默认值构造一个空歌单的内容。
  factory PeriodContent.fallback(MusicPeriod period) => PeriodContent(
        period: period,
        label: period.label,
        emoji: period.emoji,
        description: period.description,
        songs: const [],
      );
}
