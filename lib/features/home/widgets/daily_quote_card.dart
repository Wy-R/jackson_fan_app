import 'dart:ui';

import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/entrance_animation.dart';
import '../../../core/widgets/tab_switcher.dart';

const dailyContent = [
  'I never needed you to love me',
  'I just wanted you near me.',
];

/// 今日一言悬浮卡:顶部浮动的引文卡片(毛玻璃效果)。
///
/// 进场动画交给可复用的 [EntranceAnimation](延迟 + 上滑 + 淡入),
/// tab 切回时会自动重播。本组件只管卡片自身样式与内容。
class DailyQuoteCard extends StatelessWidget {
  const DailyQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return EntranceAnimation(
      // 点击整张卡 → 切到「每日」tab。
      // behavior.opaque 让透明区域(毛玻璃半透明处)也能响应点击。
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => TabSwitcher.of(context).switchTo(TabId.mailbox),
        child: _buildCard(context),
      ),
    );
  }

  /// 卡片本体(毛玻璃外框 + 内容)。
  Widget _buildCard(BuildContext context) {
    // ClipRect 把模糊裁在卡片矩形范围内(无圆角,所以用 ClipRect 而非 ClipRRect)。
    // BackdropFilter 对其"身后"的像素做高斯模糊,实现毛玻璃。
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity, // 横向撑满父级可用宽度(左右 20 间距由父级 Padding 控制)
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // rgba(8,8,8,0.55):背景色 background 叠 0.55 透明度
            color: AppColors.background.withValues(alpha: 0.55),
            border: Border.all(color: AppColors.primary, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 左右两边的
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(LucideIcons.dot, color: AppColors.primary, size: 9),
                      Text(
                        '今日信箱',
                        style: TextStyle(color: AppColors.primary, fontSize: 9),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formatMonthDay(DateTime.now()), // 系统当前日期,格式如 "JUN 19"
                        style: const TextStyle(
                          fontFamily: 'Barlow Condensed',
                          color: AppColors.mutedForeground,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(LucideIcons.move_right, color: AppColors.mutedForeground, size: 9,)
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              // 逐行渲染引文,直接摊进外层 Column,无需多套一层
              for (final line in dailyContent) _DailyQuote(text: line),
              const SizedBox(height: 12),
              Text(
                '---- Magic MAN · 2022',
                style: TextStyle(
                  // fontFamily: 'Barlow Condensed',
                  fontSize: 9,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyQuote extends StatelessWidget {
  const _DailyQuote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontFamily: 'Anton',
        color: AppColors.foreground,
        fontWeight: FontWeight.w400,
        letterSpacing: 1,
      ),
    );
  }
}
