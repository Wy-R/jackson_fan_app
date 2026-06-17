import 'package:flutter/material.dart';

import 'widgets/hero_header.dart';

/// 首页:王嘉尔背景大图铺满整个可视区(body)。
///
/// 背景图自适应任何屏幕尺寸:HeroHeader 用 Stack(fit: expand) 撑满,
/// HomePage 直接返回它,由外层壳(HomeShell)的 body 决定可用空间大小。
/// 因为 body 区域已被底部导航栏挤掉那块高度,所以背景不会盖住 tab。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 直接返回铺满的 HeroHeader(不用 ListView):
    // 全屏背景要"撑满",而 ListView 的子项高度是无界的、撑不满,二者不搭。
    return const HeroHeader();
  }
}
