import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 今日一言悬浮卡:顶部浮动的引文卡片(毛玻璃效果)。
///
/// 占位版本:外框和毛玻璃背景已就位,内部文字待填充。
/// 定位(距顶/左右边距)由父级负责,这里只管自身样式。
class DailyQuoteCard extends StatelessWidget {
  const DailyQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    // ClipRect 把模糊裁在卡片矩形范围内(无圆角,所以用 ClipRect 而非 ClipRRect)。
    // BackdropFilter 对其"身后"的像素做高斯模糊,实现毛玻璃。
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // rgba(8,8,8,0.55):背景色 background 叠 0.55 透明度
            color: AppColors.background.withValues(alpha: 0.55),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('今日一言', style: TextStyle(color: AppColors.primary)),
              SizedBox(height: 12),
              Text(
                'I never needed you to love me, I just wanted you near me.  ',
                style: TextStyle(color: AppColors.foreground, fontSize: 18),
              ),
              SizedBox(height: 12),
              Text(
                'SONG INFO',
                style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
