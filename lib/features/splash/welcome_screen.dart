import 'package:flutter/material.dart';

import '../../core/stores/quotes_store.dart';
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

    // 预加载语录数据，进入首页时已有数据可用
    QuotesStore.instance.load();
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
            // Image.asset(
            //   'assets/images/04.jpg',
            //   fit: BoxFit.cover,
            // ),

            // ===== 第 2 层:渐变遮罩 =====
            // const DecoratedBox(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.center,
            //       end: Alignment.bottomCenter,
            //       colors: [Colors.transparent, Colors.black54],
            //     ),
            //   ),
            // ),


            // ===== slogan(屏幕居中,静态显示)=====
            // 独立的一层:Stack 里再加一个 Align 居中,放两行字。
            // 多行文字用 Column(多子) 承载,Align 只能有一个 child,
            // 所以先 Align → Column → 两个 Text。
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min, // 只占内容高度
                children: const [
                  Text(
                    'WELCOME TO OUR WORLD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 8), // 两行之间的间距
                  Text(
                    'A QUIET SPACE FOR US',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ],
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
