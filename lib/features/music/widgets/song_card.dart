import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../models/day_period.dart';
import '../models/song.dart';

/// 单张歌曲卡片：时段渐变背景 + 装饰音符 + 底部歌名。
///
/// 不再使用封面图，背景由所属 [MusicPeriod] 的渐变色决定，
/// 省去封面资源依赖，也让卡片随时段呈现不同氛围。
class SongCard extends StatelessWidget {
  const SongCard({super.key, required this.song, required this.period});

  final Song song;

  /// 所属时段，用于取背景渐变色。
  final MusicPeriod period;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: period.gradient,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 右上角装饰音符（半透明，做点缀）
            Positioned(
              top: -10,
              right: -10,
              child: Icon(
                LucideIcons.music,
                size: 140,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            // 底部歌名区
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 小标：歌手（固定 Jackson）
                    Text(
                      'JACKSON WANG',
                      style: TextStyle(
                        fontFamily: 'Barlow Condensed',
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 歌名
                    Text(
                      song.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Anton',
                        color: Colors.white,
                        fontSize: 26,
                        letterSpacing: 0.5,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
