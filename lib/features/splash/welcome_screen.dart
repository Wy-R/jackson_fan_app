import 'package:flutter/material.dart';

import '../shell/home_shell.dart';

/// 开屏欢迎页:全屏背景图 + enter 按钮,点击后进入首页。
///
/// 用 StatefulWidget(有状态组件):页面需要控制入场、离场动画状态,
/// 所以不能再用 StatelessWidget。
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showIntro = false;
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();

    // 等第一帧画出来后再切换状态,Animated* 组件才有起点和终点。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _showIntro = true);
    });
  }

  /// 点击 enter 后的跳转逻辑,单独抽成方法,build 里更清爽。
  Future<void> _enter(BuildContext context) async {
    if (_isLeaving) return;

    setState(() => _isLeaving = true);

    // 先让当前开屏页淡出,再切到首页。
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!context.mounted) return;

    // Navigator 是 Flutter 管理页面栈的核心,页面像一叠卡片堆着。
    // push      = 往栈顶压一个新页面(能返回上一页)
    // pushReplacement = 用新页面替换掉当前页面(当前页被销毁,无法返回)
    // 开屏页进首页后不该能退回开屏,所以用 pushReplacement。
    // 开屏进入后由 HomeShell 承载底部导航,默认停在首页 tab。
    Navigator.of(context).pushReplacement(
      // MaterialPageRoute 定义"一条路由",即怎么过渡到新页面,
      // builder 回调返回目标页面 Widget。下划线 _ 表示这个参数用不到。
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold 是页面骨架,提供 body、appBar、底部栏等标准槽位。
    // 这里只用 body,铺满整个屏幕。
    return Scaffold(
      // Stack 是"层叠布局":子组件像图层一样一层压一层,
      // 列表里越靠后的越在上层。这正是"背景图垫底 + 按钮浮在上面"的关键。
      body: AnimatedOpacity(
        opacity: _isLeaving ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Stack(
          // StackFit.expand 让 Stack 撑满父空间(整个屏幕),
          // 这样下面铺满型的子组件才有"满屏"的参照。
          fit: StackFit.expand,
          children: [
            // ===== 第 1 层:背景图(最底层)=====
            // Image.asset 加载打包进 App 的本地图片,
            // 路径就是 pubspec.yaml 里声明过的 assets 路径。
            AnimatedScale(
              scale: _showIntro ? 1.08 : 1,
              duration: const Duration(seconds: 5),
              curve: Curves.easeOutCubic,
              child: Image.asset(
                'assets/images/04.jpg',
                // BoxFit.cover:等比缩放图片直到铺满整个区域,超出部分裁掉,
                // 不会变形。做全屏背景几乎都用 cover。
                // (对比 contain 是完整显示可能留白,fill 是拉伸会变形)
                fit: BoxFit.cover,
              ),
            ),

            // ===== 第 2 层:渐变遮罩 =====
            // 盖在图上的一层半透明黑色渐变,让底部的白色按钮更清晰,
            // 否则碰上浅色背景图按钮会看不清。
            const DecoratedBox(
              decoration: BoxDecoration(
                // LinearGradient 线性渐变:从中间的全透明,过渡到底部的半透明黑。
                gradient: LinearGradient(
                  begin: Alignment.center, // 渐变起点:垂直中间
                  end: Alignment.bottomCenter, // 渐变终点:底部
                  colors: [Colors.transparent, Colors.black54], // 透明 → 半透明黑
                ),
              ),
            ),

            // ===== 第 3 层:enter 按钮(最上层)=====
            // SafeArea 自动避开刘海、底部小黑条等系统区域,
            // 防止按钮被遮挡或贴到屏幕边缘。
            SafeArea(
              // Align 控制子组件在父空间里的对齐位置,
              // bottomCenter = 底部居中。
              child: Align(
                alignment: Alignment.bottomCenter,
                // Padding 加内边距,这里让按钮离屏幕底部留 48 像素空隙。
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: AnimatedSlide(
                    offset: _showIntro ? Offset.zero : const Offset(0, 0.4),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: _showIntro ? 1 : 0,
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      // ElevatedButton 是带背景色的"实心"按钮。
                      child: ElevatedButton(
                        // onPressed 是点击回调;如果传 null 按钮会变灰、不可点。
                        // () => _enter(context) 是把点击事件转交给上面的方法。
                        onPressed: _isLeaving ? null : () => _enter(context),
                        // styleFrom 是快捷设置按钮样式的工具方法。
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // 按钮背景色
                          foregroundColor: Colors.black87, // 文字/图标颜色
                          disabledBackgroundColor: Colors.white70,
                          disabledForegroundColor: Colors.black54,
                          // symmetric:水平、垂直方向分别设内边距,撑大按钮点击区域。
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          // 圆角形状,32 的圆角让按钮变成胶囊形。
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: const Text(
                          'Enter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600, // 字重,w600 介于常规和粗体之间
                            letterSpacing: 1, // 字间距,让英文字母松一点更精致
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
