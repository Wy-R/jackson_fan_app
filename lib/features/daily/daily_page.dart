import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/daily_card_swiper.dart';
import 'widgets/daily_subscribe_bar.dart';

/// 每日页:底部导航「每日」tab 对应的页面。
///
/// 纵向结构:卡片区(撑满中部空余) → 底部订阅提示条。
/// 顶部标题区、操作按钮栏后续再补。
class DailyPage extends StatelessWidget {
  const DailyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              // 卡片区:用 Expanded 吃掉中部所有剩余高度
              Expanded(child: DailyCardSwiper()),
              SizedBox(height: 16),
              // 底部订阅提示条:固定高度
              DailySubscribeBar(),
            ],
          ),
        ),
      ),
    );
  }
}
