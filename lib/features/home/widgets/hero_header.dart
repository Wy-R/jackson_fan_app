import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../../../core/theme/app_colors.dart';
import '../../sky/widgets/sky_entry.dart';
import '../../sky/widgets/sky_sheet.dart';
import 'artist_name_section.dart';
import 'daily_quote_card.dart';

/// 首页顶部的人物背景大图区:背景图 + 渐变遮罩 + 左下角文字。
///
/// 独立成文件的好处:
/// 1. HomePage 的 build 只表达"页面有哪些块",干净易读
/// 2. 这块的内部细节(高度、遮罩、文字)都收纳在这里,改它不影响别处
/// 3. 别的页面要用同样的头图,可直接 import 复用
class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Stack(fit: expand) 撑满父给的空间(整个 body),实现全屏背景,
    // 不设固定高度,从而自适应任何屏幕尺寸。
    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景图,铺满整个区域
        Image.asset(
          'assets/images/bg.jpeg',
          // cover:等比缩放铺满 + 裁切,不变形
          fit: BoxFit.cover,
        ),

        // 底部渐变遮罩:从透明过渡到半透明深色,
        // 让左下角文字在任何图上都清晰(手法同开屏页)。
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.input,
                AppColors.background.withValues(alpha: 0.54),
              ],
            ),
          ),
        ),

        // 顶部一行:左 JW 标识,右 天气入口(同一片天空)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'JW',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Anton',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SkyEntry(onTap: () => showSkySheet(context)),
                ],
              ),
            ),
          ),
        ),

        // 浮在背景上的三块内容:顶部引文卡 → (留白) → 艺人名 → 粉丝数。
        // 用 SafeArea 避开刘海/状态栏,Column + Spacer 实现上下分布。
        // 底部留出 40 的空间给跑马灯。
        Positioned.fill(
          bottom: 40,
          child: SafeArea(
            child: Padding(
              // 统一的左右间距,三块内容共用(各子组件内部不再单独留横向边距)
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // 关键:从底部往上排
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  DailyQuoteCard(),
                  SizedBox(height: 80),
                  ArtistNameSection(),
                  SizedBox(height: 15),
                  // FollowerStats(), // 先注释掉
                  // SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity, // 撑满横向
            height: 40,
            color: AppColors.primary, // 黄色实心底
            child: Marquee(
              text: '这是一条跑马灯的通告I》制作中，敬请期待',
              // 黄底配深色字:primaryForeground 是主题里专门搭 primary 的前景色
              style: TextStyle(color: AppColors.primaryForeground),
              blankSpace: 40, // 一段文字结束到下一段开始的间隔
              velocity: 30, // 滚动速度
            ),
          ),
        ),
      ],
    );
  }
}
