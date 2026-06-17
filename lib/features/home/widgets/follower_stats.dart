import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';

/// 各平台粉丝数:底部横向排列的平台图标+关注数。
///
/// 占位版本:显示几个平台图标和数字,布局待调整。
class FollowerStats extends StatelessWidget {
  const FollowerStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // TODO: INS/X/YT/Music 图标 + 数字,间距、尺寸待调
          // 占位图标:lucide 里只有 user/music/circle/play,后续替换
          _StatItem(icon: LucideIcons.user, count: '32.6M'),
          _StatItem(icon: LucideIcons.circle, count: '8.2M'),
          _StatItem(icon: LucideIcons.play, count: '4.1M'),
          _StatItem(icon: LucideIcons.music, count: '12.8M'),
        ],
      ),
    );
  }
}

/// 单个平台项:图标 + 数字,纵向排列。
class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.count});

  final IconData icon;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            color: AppColors.foreground,
            fontSize: 14,
            fontWeight: AppColors.fontWeightMedium,
          ),
        ),
      ],
    );
  }
}
