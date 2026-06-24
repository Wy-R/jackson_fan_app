import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/entrance_animation.dart';
import '../../core/widgets/section_title.dart';

/// 树洞页:底部导航「树洞」tab 对应的页面。
///
/// 一个安静的私密空间,用户可以写下想对 Jackson 说的话。
/// 当前为占位版本,后续实现写信功能。
class TreeholePage extends StatelessWidget {
  const TreeholePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 顶部标题区
              const _TitleBar(),
              const SizedBox(height: 40),
              // 中间内容区:占位提示
              const Expanded(child: _EmptyState()),
            ],
          ),
        ),
      ),
    );
  }
}

/// 顶部标题栏。
class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SectionTitle(eyebrow: 'TREE HOLE', title: '树洞'),
      ],
    );
  }
}

/// 空状态占位:毛玻璃卡片 + 提示文案。
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EntranceAnimation(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.55),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.pen_line,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '这里是一个安静的树洞',
                    style: TextStyle(
                      fontFamily: 'Anton',
                      color: AppColors.foreground,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '写下你想对他说的话\n这里只有你自己能看到',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // 写信入口按钮
                  GestureDetector(
                    onTap: () {
                      // TODO: 跳转写信页面
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.feather,
                            color: AppColors.primaryForeground,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '写给嘉尔',
                            style: TextStyle(
                              color: AppColors.primaryForeground,
                              fontSize: 14,
                              fontWeight: AppColors.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
