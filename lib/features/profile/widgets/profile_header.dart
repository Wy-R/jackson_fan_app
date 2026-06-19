import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 「我的」页顶部用户信息区:头像 + 昵称 + 加入信息 + 三项统计。
///
/// 占位版本:数据先写死,后续接入真实用户数据(本地存储 / Firebase)。
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 头像:粉色渐变圆 + 金色描边 + 文字
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          alignment: Alignment.center,
          child: const Text(
            '',
            style: TextStyle(
              fontFamily: 'Anton',
              color: AppColors.background,
              fontSize: 48,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 昵称 + 编辑图标
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '我的昵称',
              style: TextStyle(
                fontFamily: 'Anton',
                color: AppColors.foreground,
                fontSize: 24,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit, color: AppColors.primary, size: 16),
          ],
        ),
        const SizedBox(height: 8),
        // 加入信息
        Text(
          '加入 12 天',
          style: TextStyle(
            fontFamily: 'Barlow Condensed',
            color: AppColors.mutedForeground,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        // 三项统计
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _StatCell(value: '3', label: '已收藏'),
            SizedBox(width: 40),
            _StatCell(value: '12', label: '签到天数'),
            SizedBox(width: 40),
            _StatCell(value: '6', label: '看过语录'),
          ],
        ),
      ],
    );
  }
}

/// 单项统计:大数字 + 下方标签。
class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Anton',
            color: AppColors.mutedForeground,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.mutedForeground,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
