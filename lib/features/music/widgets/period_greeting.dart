import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/entrance_animation.dart';
import '../models/day_period.dart';

/// 时段问候:音乐 Tab 顶部的一句问候，按当前时段展示
/// 「emoji + 名称」+「描述文案」。
///
/// 数据来自 [MusicPeriod]（当前为本地默认值，模块 2 接远端后描述可被远端覆盖）。
/// 视觉上保持轻量——只是一段文字，把视觉重心留给下方的推荐卡片。
class PeriodGreeting extends StatelessWidget {
  const PeriodGreeting({super.key, required this.period});

  /// 当前时段。由页面传入，方便后续做成可刷新/可测。
  final MusicPeriod period;

  @override
  Widget build(BuildContext context) {
    return EntranceAnimation(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：emoji + 时段名称
          Row(
            children: [
              Text(period.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                period.label,
                style: TextStyle(
                  fontFamily: 'Anton',
                  color: AppColors.foreground,
                  fontSize: 20,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 第二行：描述文案
          Text(
            period.description,
            style: TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
