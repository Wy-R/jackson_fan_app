import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 通用双行标题:英文小标(eyebrow)+ 中文大标(title)。
///
/// 抽取自树洞页与每日一言页共用的标题样式。右侧若需附加内容
/// (如「3 / 6」计数),由调用方在外层自行用 Row 组合,本组件只
/// 负责标题本身,保持单一职责。
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.eyebrow, required this.title});

  /// 英文小标,如 'TREE HOLE' / 'DAILY DROP'。
  final String eyebrow;

  /// 中文大标,如 '树洞' / '每日一言'。
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            fontFamily: 'Barlow Condensed',
            color: AppColors.accent,
            fontSize: 10,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Anton',
            fontWeight: FontWeight.w700,
            color: AppColors.foreground,
            fontSize: 25,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
