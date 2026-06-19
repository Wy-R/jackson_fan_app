import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 首页右上角「同一片天空」天气入口。
///
/// 占位版本:图标 + 文案,点击回调先留空(后续接 showModalBottomSheet 浮层 +
/// Open-Meteo 天气数据)。
class SkyEntry extends StatelessWidget {
  const SkyEntry({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      // 圆形天气入口
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.background.withValues(alpha: 0.4),
          border: Border.all(color: AppColors.border),
        ),
        // 天气图标(emoji 占位,接入真实数据后按天气切换)
        child: const Text('🌧️', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
