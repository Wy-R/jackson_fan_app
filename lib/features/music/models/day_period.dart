import 'package:flutter/painting.dart';

/// 一天中的时段：音乐 Tab 按当前时间自动落到其中一段，
/// 用于决定问候语和推荐歌单。
///
/// 时段划分（按小时，24 小时制）：
/// - 早晨 morning  : 06:00 – 12:00
/// - 午后 afternoon: 12:00 – 18:00
/// - 夜间 night    : 18:00 – 次日 06:00
///
/// 这里每段自带的 [emoji] / [label] / [description] 是**本地默认值**，
/// 同时也充当模块 2 接远端时的兜底数据（断网/拉取失败时回退到这套）。
/// [gradient] 是该时段卡片的背景渐变色，纯本地配置（不来自远端）。
enum MusicPeriod {
  morning(
    emoji: '🌅',
    label: '早晨',
    description: '新的一天，先来点节奏',
    gradient: [Color(0xFFF8B26A), Color(0xFFE07A3F)],
  ),
  afternoon(
    emoji: '🌤',
    label: '午后',
    description: '事情再多，耳机一戴都是我的节奏',
    gradient: [Color(0xFF4FC3DC), Color(0xFF2E6F95)],
  ),
  night(
    emoji: '🌙',
    label: '夜间',
    description: '安静下来，让音乐代替语言',
    gradient: [Color(0xFF6A4FB3), Color(0xFF232347)],
  );

  const MusicPeriod({
    required this.emoji,
    required this.label,
    required this.description,
    required this.gradient,
  });

  /// 时段图标，如 🌅。
  final String emoji;

  /// 时段名称，如 “早晨”。
  final String label;

  /// 问候描述文案。
  final String description;

  /// 卡片背景渐变色（从上到下）。
  final List<Color> gradient;

  /// 根据小时（0–23）判断属于哪个时段。
  ///
  /// 抽成纯函数（只依赖入参，不读系统时间），方便单元测试。
  static MusicPeriod fromHour(int hour) {
    if (hour >= 6 && hour < 12) return MusicPeriod.morning;
    if (hour >= 12 && hour < 18) return MusicPeriod.afternoon;
    return MusicPeriod.night; // 18:00–23:59 和 00:00–05:59 都算夜间
  }

  /// 取当前系统时间对应的时段。
  static MusicPeriod current() => fromHour(DateTime.now().hour);
}
