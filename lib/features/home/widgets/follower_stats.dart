import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';

/// 各平台粉丝数:底部横向排列的平台图标+关注数。
///
/// 占位版本:显示几个平台图标和数字,布局待调整。
class FollowerStats extends StatelessWidget {
  const FollowerStats({super.key});

  @override
  Widget build(BuildContext context) {
    // 各平台数据,后续替换为真实数据源
    const items = [
      _StatItem(
        icon: 'assets/icons/instagram.svg',
        count: '32.6M',
        label: 'INS',
      ),
      _StatItem(icon: 'assets/icons/weibo.svg', count: '8.2M', label: '微博'),
      _StatItem(icon: 'assets/icons/x.svg', count: '4.1M', label: 'X'),
      _StatItem(icon: 'assets/icons/netease.svg', count: '12.8M', label: '网易云'),
    ];

    return Container(
      // 横向间距由父级统一控制,这里只留上下内边距
      padding: const EdgeInsets.symmetric(vertical: 20),
      // 顶部横线
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(child: items[i]),
            // 在 item 之间插入竖线(最后一个后面不加)
            if (i < items.length - 1)
              Container(width: 1, height: 50, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

/// 单个平台项:图标 + 数字 + 平台名,纵向排列。
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
  });

  /// SVG 资源路径,如 'assets/icons/instagram.svg'
  final String icon;
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: 15,
          height: 15,
          // 给单色图标统一上主题色
          colorFilter: const ColorFilter.mode(
            AppColors.whiteAlpha30,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontFamily: 'Anton',
            color: AppColors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.whiteAlpha30,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
