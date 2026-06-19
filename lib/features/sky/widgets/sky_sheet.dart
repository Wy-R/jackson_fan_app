import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

/// 天气服务单例:浮层每次打开都复用它,以命中 1 小时缓存。
final _weatherService = WeatherService();

/// 打开「同一片天空」浮层(从底部升起的模态面板)。
///
/// 用 showModalBottomSheet + isScrollControlled 做成接近全屏、顶部留空、
/// 底部导航仍可见的效果(对应设计稿)。天气数据来自 Open-Meteo。
Future<void> showSkySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 允许超过默认半屏高度
    backgroundColor: AppColors.background,
    builder: (_) => const _SkySheet(),
  );
}

/// 「同一片天空」浮层内容:天气 + 今日陪伴文案 + 今天适合听。
class _SkySheet extends StatefulWidget {
  const _SkySheet();

  @override
  State<_SkySheet> createState() => _SkySheetState();
}

class _SkySheetState extends State<_SkySheet> {
  // initState 取一次 Future,避免每次 build 重新请求。
  late final Future<Weather> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _weatherService.loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // 占屏幕约 85% 高,顶部留出空隙
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部:右上角关闭按钮
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  LucideIcons.x,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _SectionLabel('★ 同一片天空'),
            const SizedBox(height: 12),

            // 天气主体:异步加载真实天气
            FutureBuilder<Weather>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _WeatherRow(emoji: '⏳', desc: '', sub: '');
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const _WeatherRow(
                    emoji: '🌐',
                    desc: '获取失败',
                    sub: '请稍后再试',
                  );
                }
                final w = snapshot.data!;
                return _WeatherRow(
                  emoji: w.emoji,
                  desc: w.description,
                  sub: '${w.city} · ${w.temperatureText}',
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 24),

            // 今日陪伴
            _SectionLabel('今日陪伴'),
            const SizedBox(height: 12),
            const Text(
              '下雨了。不用去哪,就待着听首歌吧,反正他的声音比雨声好听。',
              style: TextStyle(
                color: AppColors.foreground,
                fontSize: 20,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // 今天适合听
            _SectionLabel('今天适合听'),
            const SizedBox(height: 12),
            const Text(
              "Giving you all I've got,\neven if the world forgot.",
              style: TextStyle(
                fontFamily: 'Anton',
                color: AppColors.foreground,
                fontSize: 22,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(width: 24, height: 1, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'DRIVE · 2024',
                  style: TextStyle(
                    fontFamily: 'Barlow Condensed',
                    color: AppColors.mutedForeground,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 天气主体一行:大 emoji + 状况 + 城市·温度。
class _WeatherRow extends StatelessWidget {
  const _WeatherRow({
    required this.emoji,
    required this.desc,
    required this.sub,
  });

  final String emoji;
  final String desc;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              desc,
              style: const TextStyle(
                fontFamily: 'Anton',
                color: AppColors.foreground,
                fontSize: 40,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(
                fontFamily: 'Barlow Condensed',
                color: AppColors.mutedForeground,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 小节标签(粉色小字,如「今日陪伴」「今天适合听」)。
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: AppColors.primary, fontSize: 9, letterSpacing: 2),
    );
  }
}
