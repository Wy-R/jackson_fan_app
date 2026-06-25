import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/letter.dart';

/// 树洞服务：管理用户写下的私密信件。
///
/// 纯本地存储：shared_preferences 单个 key（JSON 数组）。
/// 当前只支持新增 / 删除 / 读取，不支持编辑。
/// 量级通常几十上百条，prefs 足够；若以后要分页/全文搜索，再迁 sqflite。
class TreeholeService {
  const TreeholeService();

  static const _key = 'treehole_letters';

  /// 加载全部信件（按创建时间倒序，最新在前）。
  Future<List<Letter>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];

    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Letter.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 新增一封信。返回保存后的 [Letter] 对象（含生成的 id）。
  Future<Letter> add({required String content, String? mood}) async {
    final now = DateTime.now();
    final letter = Letter(
      id: now.millisecondsSinceEpoch.toString(),
      content: content,
      createdAt: now,
      mood: mood,
    );

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    final List<dynamic> list =
        jsonStr != null ? json.decode(jsonStr) as List<dynamic> : [];
    list.add(letter.toJson());
    await prefs.setString(_key, json.encode(list));

    return letter;
  }

  /// 删除一封信。
  Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return;

    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    final newList = list.where((e) => e['id'] != id).toList();
    await prefs.setString(_key, json.encode(newList));
  }
}
