import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:jackson_fan_app/core/theme/app_colors.dart';
import 'package:jackson_fan_app/core/widgets/tab_switcher.dart';

import '../daily/daily_page.dart';
import '../home/home_page.dart';

/// 导航壳:承载底部导航栏 + 5 个 tab 页面的外层容器。
///
/// 底部导航需要"切换页面"和"记住当前选中哪个 tab",
/// 所以用 StatefulWidget 持有当前索引。
///
/// 页面切换用 AnimatedSwitcher(渐隐渐现):
/// - 切 tab 时旧页淡出、新页淡入,不生硬
/// - 借助 ValueKey(_currentIndex),切换会重建目标页,
///   从而让页内的 EntranceAnimation 每次切回都重新播放进场动画
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  /// 当前选中的 tab 索引,0 = 首页。
  int _currentIndex = 0;

  /// 5 个 tab 对应的页面。首页是真内容,其余为占位页。
  static const _pages = <Widget>[
    HomePage(),
    _PlaceholderPage('音乐'),
    _PlaceholderPage('巡演'),
    DailyPage(),
    _PlaceholderPage('我的'),
  ];

  /// 切换到指定 tab。既供底部导航点击用,也通过 TabSwitcher 暴露给深层组件。
  void _switchTo(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // TabSwitcher:把"切 tab"能力下发给整棵子树,
    // 深层组件(如今日信箱卡)可 TabSwitcher.of(context).switchTo(index) 调用。
    return TabSwitcher(
      switchTo: _switchTo,
      child: Scaffold(
        // AnimatedSwitcher:child 一变就用淡入淡出在新旧页间过渡。
        // KeyedSubtree + ValueKey(_currentIndex):key 变化让 AnimatedSwitcher
        // 认定是"新内容",触发过渡,同时目标页重建 → 进场动画重播。
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _pages[_currentIndex],
          ),
        ),

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
                    color: selected
                        ? AppColors.primary
                        : AppColors.mutedForeground,
                  );
                }),
                // 文字颜色同理。
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontSize: 11,
                    color: selected
                        ? AppColors.primary
                        : AppColors.mutedForeground,
                    fontWeight: selected
                        ? AppColors.fontWeightMedium
                        : AppColors.fontWeightNormal,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                // 点击某个 tab → 切换(触发淡入淡出)。
                onDestinationSelected: _switchTo,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(LucideIcons.house_heart),
                    label: '首页',
                  ),
                  NavigationDestination(
                    icon: Icon(LucideIcons.disc_3),
                    label: '音乐',
                  ),
                  NavigationDestination(
                    icon: Icon(LucideIcons.ticket),
                    label: '巡演',
                  ),
                  NavigationDestination(
                    icon: Icon(LucideIcons.book_open),
                    label: '每日',
                  ),
                  NavigationDestination(
                    icon: Icon(LucideIcons.user),
                    label: '我的',
                  ),
                ],
              ),
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
