import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/artist_profile.dart';
import '../models/daily_quote.dart';
import '../models/gallery_photo.dart';
import '../models/work_item.dart';

class AssetDataService {
  const AssetDataService();

  /// jsDelivr CDN 地址（公共仓库 Wy-R/data）。
  static const _dailyQuotesUrl =
      'https://cdn.jsdelivr.net/gh/Wy-R/data@main/jackson_fan_app/daily_quotes.json';

  /// SharedPreferences 缓存 key。
  static const _cacheKey = 'daily_quotes_cache';
  static const _cacheTimeKey = 'daily_quotes_cache_time';

  /// 缓存有效期:1 小时。
  static const _cacheDuration = Duration(hours: 1);

  Future<ArtistProfile> loadArtistProfile() async {
    return const ArtistProfile(
      name: 'Jackson Wang',
      chineseName: '王嘉尔',
      bio: '音乐人、唱作人、舞台表演者。这里之后会改成 assets/data 里的真实简介。',
      avatar: '',
      heroImages: [],
    );
  }

  Future<List<WorkItem>> loadWorks() async {
    return const [];
  }

  Future<List<GalleryPhoto>> loadGalleryPhotos() async {
    return [];
  }

  /// 每日一言列表。
  ///
  /// 优先读缓存（1 小时内有效），否则拉远端 JSON。
  /// 网络失败 / 解析失败时回退到内置兜底数据。
  Future<List<DailyQuote>> loadDailyQuotes() async {
    // 1. 尝试读缓存
    final cached = await _readCache();
    if (cached != null) {
      print('[DailyQuotes] 命中缓存, ${cached.length} 条');
      return cached;
    }

    // 2. 拉远端
    try {
      final res = await http
          .get(Uri.parse(_dailyQuotesUrl))
          .timeout(const Duration(seconds: 8));

      print('[DailyQuotes] HTTP ${res.statusCode}, body length: ${res.bodyBytes.length}');

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body) as Map<String, dynamic>;
        final list = (decoded['quotes'] ?? decoded['quotesDefault']) as List;
        final quotes = list
            .map((e) => _parseQuote(e as Map<String, dynamic>))
            .toList();

        // print('[DailyQuotes] 解析成功, ${quotes.length} 条');
        // for (final q in quotes) {
        //   print('  → bg=${q.background}, lines=${q.lines}, source=${q.source}');
        // }

        // 写入缓存
        await _writeCache(quotes);
        return quotes;
      }
    } catch (e, st) {
      print('[DailyQuotes] 拉取失败: $e');
      print(st);
    }

    // 3. 兜底
    print('[DailyQuotes] 使用兜底数据');
    return _fallbackQuotes;
  }

  /// 把远端 JSON 解析为 DailyQuote。
  ///
  /// background 字段可能是完整 URL（如 CDN 地址），
  /// 也可能是数字编号（如 "1"，映射为本地资源路径）。
  DailyQuote _parseQuote(Map<String, dynamic> json) {
    final bg = json['background'] as String;
    final background = bg.startsWith('http') ? bg : 'assets/images/bgs/$bg.jpeg';
    return DailyQuote(
      background: background,
      lines: (json['lines'] as List).cast<String>(),
      source: json['source'] as String,
    );
  }

  // ---------- 缓存 ----------

  Future<List<DailyQuote>?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeMs = prefs.getInt(_cacheTimeKey);
      if (timeMs == null) return null;

      final cachedAt = DateTime.fromMillisecondsSinceEpoch(timeMs);
      if (DateTime.now().difference(cachedAt) > _cacheDuration) return null;

      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr == null) return null;

      final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
      return list
          .map((e) => DailyQuote.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(List<DailyQuote> quotes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(quotes.map((q) => q.toJson()).toList());
      await prefs.setString(_cacheKey, jsonStr);
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      // 写缓存失败不影响主流程
    }
  }

  // ---------- 兜底数据 ----------

  static const _fallbackQuotes = [
    DailyQuote(
      background: 'assets/images/bgs/1.jpeg',
      lines: ['I never needed you to love me,', 'I just wanted you near me.'],
      source: 'MAGIC MAN · 2022',
    ),
    DailyQuote(
      background: 'assets/images/bgs/2.jpeg',
      lines: ['Dreams are made', 'to be chased.'],
      source: 'TEAM WANG · 2021',
    ),
    DailyQuote(
      background: 'assets/images/bgs/3.jpeg',
      lines: ['Stay true', 'to yourself.'],
      source: 'JACKSON WANG · 2020',
    ),
    DailyQuote(
      background: 'assets/images/bgs/4.jpeg',
      lines: ['Pretty in pink,', 'tough in heart.'],
      source: 'PRETTY IN PINK · 2023',
    ),
    DailyQuote(
      background: 'assets/images/bgs/5.jpeg',
      lines: ['Light it up', 'and never stop.'],
      source: 'MAGIC MAN · 2022',
    ),
    DailyQuote(
      background: 'assets/images/bgs/6.jpeg',
      lines: ['Keep moving,', 'keep shining.'],
      source: 'TEAM WANG · 2024',
    ),
  ];
}
