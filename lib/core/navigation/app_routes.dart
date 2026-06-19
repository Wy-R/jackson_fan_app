import 'package:flutter/material.dart';

import '../../features/profile/pages/favorites_page.dart';
import '../../features/profile/pages/settings_page.dart';

/// 应用内命名路由(集中登记,一眼看全有哪些二级页面)。
///
/// 用法:
/// - 在 MaterialApp 里:`routes: appRoutes`
/// - 跳转:`Navigator.pushNamed(context, AppRoutes.favorites)`
///
/// 将来若迁移到 GoRouter,这些路由名常量可直接复用,只需改注册与跳转实现。
class AppRoutes {
  const AppRoutes._();

  static const favorites = '/me/favorites';
  static const settings = '/me/settings';
}

/// 路由表:供 MaterialApp 注册。新增二级页面时在此加一行即可。
final appRoutes = <String, WidgetBuilder>{
  AppRoutes.favorites: (_) => const FavoritesPage(),
  AppRoutes.settings: (_) => const SettingsPage(),
};
