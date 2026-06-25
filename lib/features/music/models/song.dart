/// 一首推荐歌曲。
///
/// 数据来自远端/本地 JSON 的 `songs` 数组，字段与 JSON 一一对应。
/// 没有歌手字段（默认都是 Jackson），没有 id（去重时用 [url] 即可）。
class Song {
  const Song({
    required this.title,
    required this.cover,
    required this.url,
  });

  /// 歌名。
  final String title;

  /// 封面图 URL（网络图）。
  final String cover;

  /// 跳转链接（网易云 / QQ 音乐）。点击卡片时用外部浏览器/音乐 App 打开。
  final String url;

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        title: json['title'] as String,
        cover: json['cover'] as String,
        url: json['url'] as String,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'cover': cover,
        'url': url,
      };
}
