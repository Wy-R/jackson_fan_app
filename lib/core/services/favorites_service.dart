import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite.dart';

/// 收藏服务：管理每日一言卡片的收藏记录。
///
/// 数据存储在 shared_preferences（JSON 数组），
/// 截图文件存储在 App Documents/favorites/ 目录。
class FavoritesService {
  const FavoritesService();

  static const _key = 'favorites';

  /// 加载全部收藏记录（按收藏时间倒序）。
  Future<List<Favorite>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];

    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Favorite.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // 最新在前
  }

  /// 保存一条收藏记录。
  ///
  /// [imageBytes] 为截图 PNG 字节，会写入本地文件。
  /// 返回保存后的 [Favorite] 对象（含生成的 id 和 imagePath）。
  Future<Favorite> save({
    required List<int> imageBytes,
    required String source,
    required List<String> lines,
  }) async {
    // 1. 生成唯一 id
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final random = Random().nextInt(0xFFFF).toRadixString(16).padLeft(4, '0');
    final id = '${dateStr}_$random';

    // 2. 保存截图文件
    final dir = await getApplicationDocumentsDirectory();
    final favDir = Directory('${dir.path}/favorites');
    if (!await favDir.exists()) {
      await favDir.create(recursive: true);
    }
    final imagePath = '${favDir.path}/fav_$id.png';
    await File(imagePath).writeAsBytes(imageBytes);

    // 3. 构建收藏记录
    final favorite = Favorite(
      id: id,
      date: dateStr,
      imagePath: imagePath,
      source: source,
      lines: lines,
    );

    // 4. 追加到 prefs
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    final List<dynamic> list =
        jsonStr != null ? json.decode(jsonStr) as List<dynamic> : [];
    list.add(favorite.toJson());
    await prefs.setString(_key, json.encode(list));

    return favorite;
  }

  /// 删除一条收藏记录（同时删除截图文件）。
  Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return;

    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    final newList = list.where((e) => e['id'] != id).toList();
    await prefs.setString(_key, json.encode(newList));

    // 删除截图文件
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/favorites/fav_$id.png');
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 检查某张卡片是否已收藏（通过 source 匹配）。
  Future<bool> isFavorited(String source) async {
    final all = await loadAll();
    return all.any((f) => f.source == source);
  }

  /// 根据 source 获取收藏记录（用于取消收藏时删除文件）。
  Future<Favorite?> findBySource(String source) async {
    final all = await loadAll();
    try {
      return all.firstWhere((f) => f.source == source);
    } catch (_) {
      return null;
    }
  }
}
