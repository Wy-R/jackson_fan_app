import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/day_period.dart';
import '../models/period_content.dart';

/// 音乐数据服务：加载各时段的歌单与文案。
///
/// 当前阶段：只从本地 assets（assets/data/music.json）读取，跑通整条
/// 「JSON → 模型 → UI」链路。后续会在此基础上叠加网络层（远端 CDN）+
/// 缓存 + 兜底，写法参照 [AssetDataService]，调用方签名保持不变。
class MusicService {
  const MusicService();

  /// 本地兜底 / mock 数据路径。
  static const _assetPath = 'assets/data/music.json';

  /// 加载全部时段内容，返回「时段 → 内容」的映射。
  ///
  /// 读取或解析失败时，回退到各时段的枚举默认值（空歌单），保证不抛异常、
  /// UI 至少能显示问候文案。
  Future<Map<MusicPeriod, PeriodContent>> loadPeriods() async {
    try {
      final jsonStr = await rootBundle.loadString(_assetPath);
      return _parse(jsonStr);
    } catch (e) {
      // assets 缺失/格式错误 → 全部回退默认
      return {
        for (final p in MusicPeriod.values) p: PeriodContent.fallback(p),
      };
    }
  }

  /// 把 JSON 字符串解析成「时段 → 内容」映射。
  ///
  /// JSON 顶层结构：{ "periods": { "morning": {...}, "afternoon": {...}, ... } }
  Map<MusicPeriod, PeriodContent> _parse(String jsonStr) {
    final decoded = json.decode(jsonStr) as Map<String, dynamic>;
    final periodsJson = decoded['periods'] as Map<String, dynamic>? ?? {};

    final result = <MusicPeriod, PeriodContent>{};
    for (final period in MusicPeriod.values) {
      // 枚举名（morning/afternoon/night）正好对应 JSON 的 key。
      final node = periodsJson[period.name] as Map<String, dynamic>?;
      result[period] = node != null
          ? PeriodContent.fromJson(period, node)
          : PeriodContent.fallback(period);
    }
    return result;
  }
}
