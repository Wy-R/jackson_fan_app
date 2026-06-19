import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/profile_header.dart';

/// 我的页:底部导航「我的」tab。
///
/// 顶部用户信息区(ProfileHeader)+ 下方功能入口列表,整体可滚动。
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 顶部用户信息区
            const SizedBox(height: 16),
            const ProfileHeader(),
            const SizedBox(height: 32),
            // 功能入口:我的收藏 → 二级页面(命名路由)
            _MenuItem(
              icon: LucideIcons.heart,
              label: '我的收藏',
              onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
            ),
            // 设置 → 二级页面
            _MenuItem(
              icon: LucideIcons.settings,
              label: '设置',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            _MenuItem(
              icon: LucideIcons.mail,
              label: '意见反馈',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }
}

/// 设置/功能列表项:左图标 + 文字,右箭头,整行可点。
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.foreground,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              LucideIcons.chevron_right,
              color: AppColors.mutedForeground,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
