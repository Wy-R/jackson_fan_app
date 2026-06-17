import 'package:flutter/widgets.dart';

/// 底部 tab 切换能力的「抽象入口」。
///
/// 把「切换到第几个 tab」这个**动作**从具体实现里解耦出来:
/// - 深层组件只需 `TabSwitcher.of(context).switchTo(3)`,
///   不关心底层是 setState、状态管理还是路由。
/// - 将来若迁移到 GoRouter 等,只改 HomeShell 里传入的实现,
///   所有调用处一行都不用动。
///
/// 类比 React:相当于用 Context 暴露一个 `navigate()` 能力。
class TabSwitcher extends InheritedWidget {
  const TabSwitcher({
    super.key,
    required this.switchTo,
    required super.child,
  });

  /// 切换到指定索引的 tab。
  final void Function(int index) switchTo;

  /// 取最近的 TabSwitcher。不在其子树时返回 null(便于安全降级)。
  static TabSwitcher? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabSwitcher>();

  /// 取最近的 TabSwitcher,找不到直接报错(用于确信一定存在的场景)。
  static TabSwitcher of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, '在 widget 树中找不到 TabSwitcher');
    return result!;
  }

  // switchTo 是稳定回调,无需因它变化而通知;故恒为 false。
  @override
  bool updateShouldNotify(TabSwitcher oldWidget) => false;
}
