import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/sub_page.dart';

/// 我的收藏:二级页面(从「我的」push 进来)。
///
/// 用通用的 [SubPage] 提供标题/返回/背景,本页只关心内容。
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SubPage(
      title: '我的收藏',
      child: Center(
        child: Text(
          '收藏的卡片(待实现)',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
      ),
    );
  }
}
