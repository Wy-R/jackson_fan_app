import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 二级页面通用脚手架:统一「深色背景 + AppBar(标题/返回/可选操作)」。
///
/// 二级页(从 Navigator.push 进入)只需提供标题和内容,无需各自重复写
/// Scaffold/AppBar。返回箭头由 AppBar 自动提供(push 进来时)。
///
/// 用法:
/// ```dart
/// SubPage(
///   title: '我的收藏',
///   actions: [IconButton(...)], // 可选,右上角操作按钮
///   child: 内容,
/// )
/// ```
class SubPage extends StatelessWidget {
  const SubPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  /// 顶部标题。
  final String title;

  /// 页面主体内容。
  final Widget child;

  /// 右上角操作按钮(如分享)。不传则不显示。
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        title: Text(title),
        actions: actions,
      ),
      body: child,
    );
  }
}
