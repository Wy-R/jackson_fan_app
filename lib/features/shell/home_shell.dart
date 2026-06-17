import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:jackson_fan_app/core/theme/app_colors.dart';

import '../home/home_page.dart';

/// 导航壳:承载底部导航栏 + 5 个 tab 页面的外层容器。
///
/// 底部导航需要"切换页面"和"记住当前选中哪个 tab",
/// 所以用 StatefulWidget 持有当前索引。
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  /// 当前选中的 tab 索引,0 = 首页。
  int _currentIndex = 0;

  /// 5 个 tab 对应的页面。首页是真内容,其余为占位页。
  /// 用 late final 因为 const 列表里不能放每次都新建的 widget,这里固定一次即可。
  static const _pages = <Widget>[
    HomePage(),
    _PlaceholderPage('音乐'),
    _PlaceholderPage('巡演'),
    _PlaceholderPage('每日'),
    _PlaceholderPage('我的'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack:同时保留所有页面的状态,只显示当前索引那个。
      // (相比每次 setState 重建,切回某个 tab 时它的滚动位置等状态还在)
      body: IndexedStack(index: _currentIndex, children: _pages),

      // NavigationBarTheme 局部覆盖主题,实现"深色底 + 黄高亮"。
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.primary)),
        ),
        // 包一层 Theme 关掉点击水波纹/高亮:
        // splashFactory = NoSplash 去掉按下扩散的椭圆,
        // splashColor/highlightColor 透明做双保险。
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppColors.navigationBackground,
            // 去掉选中项背后的指示块,纯靠图标/文字变黄来高亮(贴近参考图)。
            indicatorColor: AppColors.input,
            // 图标颜色:选中黄、未选中灰。WidgetStateProperty 按状态返回不同值。
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: selected ? AppColors.primary : AppColors.mutedForeground,
              );
            }),
            // 文字颜色同理。
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 11,
                color: selected ? AppColors.primary : AppColors.mutedForeground,
                fontWeight: selected
                    ? AppColors.fontWeightMedium
                    : AppColors.fontWeightNormal,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            // 点击某个 tab → 更新索引并重绘。
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(icon: Icon(LucideIcons.house_heart), label: '首页'),
              NavigationDestination(
                icon: Icon(LucideIcons.disc_3),
                label: '音乐',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.ticket),
                label: '巡演',
              ),
              NavigationDestination(icon: Icon(LucideIcons.book_open), label: '每日'),
              NavigationDestination(icon: Icon(LucideIcons.user), label: '我的'),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

/// tab 占位页:屏幕居中显示标题。后续逐个替换成真内容。
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
