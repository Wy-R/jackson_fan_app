import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/sub_page.dart';

/// 设置页:二级页面(从「我的」push 进来)。
///
/// 骨架版本,后续放推送开关、关于、清除缓存等。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SubPage(
      title: '设置',
      child: Center(
        child: Text(
          '设置(待实现)',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
      ),
    );
  }
}
