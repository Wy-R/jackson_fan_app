# Flutter 基础掌握学习

> 这份文档整理自实际做「王嘉尔粉丝 App」开屏页 + 首页时遇到并讨论过的基础知识,按主题归类,方便回顾和分享。

---

## 一、Widget 基础认知

### 一切都是 Widget
Flutter 里 UI 的一切都是 Widget:文字、按钮、内边距、对齐、甚至整个页面都是 Widget。写界面本质上就是「套娃」式地组合各种 Widget。

**重要澄清**:不是「用 Container 还是用 Widget」二选一 —— `Container` 只是众多 Widget 中的一个。它是个「全能选手」,把背景色、边框、圆角、内外边距、尺寸、对齐打包在一起,所以常见,但很多时候是杀鸡用牛刀。

### StatelessWidget vs StatefulWidget
判断标准:**界面会不会因为内部数据变化而需要重绘?**
- 不会 → `StatelessWidget`(纯展示,如静态的开屏背景)
- 会 → `StatefulWidget`(有会变化的状态,如动画标记位 `_showIntro` / `_isLeaving`)

---

## 二、布局 Widget 分类

### 单子布局(里面放一个 Widget)
| Widget | 用途 |
|---|---|
| `Container` | 万金油,要装饰/尺寸/边距时用 |
| `Padding` | 只想加内边距,比 Container 更轻 |
| `Center` / `Align` | 控制对齐(Align 可指定 bottomLeft 等位置) |
| `SizedBox` | 定尺寸,或当间隔用 |

### 多子布局(里面放一排/一列)
| Widget | 用途 |
|---|---|
| `Row` | 横向排列 |
| `Column` | 纵向排列 |
| `Stack` | 层叠(图层一样一层压一层,越靠后越在上层) |
| `Wrap` | 排不下自动换行 |

### 铺满 / 比例分配
| Widget | 用途 |
|---|---|
| `Expanded` / `Flexible` | 在 Row/Column 里按比例占剩余空间 |
| `Scaffold` | 页面骨架,提供 appBar、body、底部栏等槽位 |

### 选择口诀
**先想布局关系**(排一行?排一列?叠在一起?)→ 选对应的布局 Widget;
**再想某块要不要背景/圆角/边距** → 那块才用 `Container`。

### 典型组合:全屏背景图 + 底部按钮
```
Scaffold
└── Stack                    // 层叠
    ├── 背景图(铺满)         // Image + BoxFit.cover
    ├── 渐变遮罩              // DecoratedBox + LinearGradient
    └── Align/Center         // 把按钮/文字定位
        └── 按钮 / 文字
```

---

## 三、常用 API 速记

### 图片填充 BoxFit
- `BoxFit.cover` —— 等比缩放铺满 + 裁切,**不变形**(全屏背景标配)
- `BoxFit.contain` —— 完整显示,可能留白
- `BoxFit.fill` —— 拉伸铺满,**会变形**

### 层叠 Stack
- `fit: StackFit.expand` 让 Stack 撑满父空间
- children 列表里**越靠后的越在上层**

### 安全区 SafeArea
自动避开刘海、底部小黑条等系统区域,防止内容被遮挡或贴边。

### Navigator 页面栈(核心)
页面像一叠卡片堆着:
- `push` —— 往栈顶压新页面(能返回上一页)
- `pushReplacement` —— 用新页面替换当前页(当前页销毁,**无法返回**)
- `MaterialPageRoute(builder: (_) => Page())` —— 定义一条路由,builder 返回目标页面

> 开屏页进首页用 `pushReplacement`,这样进首页后不能退回开屏。

---

## 四、资源管理(Assets)

本地图片/视频统称 **assets**,放置分两步:

1. **放目录**:项目根目录(和 lib、pubspec.yaml 同级)建 `assets/`,按类型分子目录
   ```
   项目/
   ├── lib/          ← 只放 .dart 代码
   ├── assets/       ← 资源放这,和 lib 同级
   │   └── images/
   └── pubspec.yaml
   ```
   ⚠️ 不要放进 `lib/`,lib 是放 Dart 源代码的地方。

2. **在 pubspec.yaml 声明**(注意 YAML 缩进敏感):
   ```yaml
   flutter:
     assets:
       - assets/images/    # 带斜杠 = 声明整个文件夹
   ```

3. **代码引用**:`Image.asset('assets/images/01.jpg')`

### 踩过的坑
- **声明了空目录会导致打包失败 → 白屏**:pubspec 里声明了 `assets/videos/` 但目录是空的,会让所有 asset(含图片)加载不出来。解决:删掉空声明,或往目录里放文件。
- 改了 pubspec 必须重新 `flutter pub get`,并**完全重启** `flutter run`(光按 R 热重启不够)。

---

## 五、热重载 vs 热重启

| 操作 | 键 | 适用 |
|---|---|---|
| hot reload | `r`(小写) | 改当前正在看的页面 UI |
| hot restart | `R`(大写) | 改了入口/路由/已离开的页面,需从头走一遍 |

**常见困惑**:改了开屏页代码但浏览器没变化 —— 因为用 `pushReplacement` 进首页后,开屏页已被销毁,`r` 只重建当前活着的页面。改入口页应该用 `R` 从头重启。

---

## 六、动画:从简单到复杂

### 1. 隐式动画(新手首选)
组件以 `Animated` 开头,**改个值就自动补间**,不用管控制器:
- `AnimatedOpacity` —— 透明度渐变(淡入淡出)
- `AnimatedScale` —— 缩放(可做 Ken Burns 背景缓慢推近)
- `AnimatedSlide` —— 位移滑入
- `AnimatedContainer` —— 尺寸/颜色/圆角/边距一起平滑过渡
- `AnimatedAlign` / `AnimatedPositioned` —— 位置平滑移动

**进场动画的关键技巧**:隐式动画需要「起点值 → 终点值」的变化才会动。所以先让第一帧用初始值画出来,等画完(`addPostFrameCallback`)再 `setState` 切到终点值:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;        // 回调时页面可能已销毁,先判断
  setState(() => _showIntro = true);
});
```

**局限**:隐式动画只会从起点到终点播**一次**,不能循环呼吸(那需要 AnimationController + repeat)。

### 2. 显式动画(要精细控制时)
用 `AnimationController` 手动驱动,能控制播放/暂停/循环/反向:
- `FadeTransition` / `ScaleTransition` / `SlideTransition` / `RotationTransition`
- 配合 `CurvedAnimation` 调节奏(`easeIn` 缓入、`elasticOut` 回弹、`bounceOut` 弹跳)
- `repeat(reverse: true)` 做呼吸效果
- 要在 `initState` 创建、`dispose` 销毁

### 3. 现成动画包(省事)
- `lottie` —— 播放设计师 AE 导出的 JSON 动画,最专业
- `animated_text_kit` —— 文字打字机/淡入/波浪
- `flutter_animate` —— 链式写法,一行串多个动画
- `shimmer` —— 微光扫过的加载效果

### 4. 其他
- `Hero` —— 页面跳转时元素「飞」过去的共享转场
- 自定义 `PageRouteBuilder` —— 自定义页面切换转场

---

## 七、设计体系:Material / Cupertino

Flutter 官方有两套设计体系:
- **Material**(谷歌安卓风)—— `import 'package:flutter/material.dart'`,含 `MaterialApp`、`Scaffold`、`ElevatedButton` 等。**大多数 App 直接全程用它**,跨平台一致,生态最全。
- **Cupertino**(苹果 iOS 风)—— `import 'package:flutter/cupertino.dart'`,含 `CupertinoApp`、`CupertinoButton` 等。

**关键认知**:
- 不是 Flutter 强制风格,是你 import 了哪套、用了 `MaterialApp` 还是 `CupertinoApp` 决定的。
- **底层通用 Widget 不分体系**:`Container`、`Row`、`Column`、`Stack`、`Text`、`Padding`、`Image`、`Animated*` 两套都能用。
- **只有「长得有设计风格」的组件才分体系**:按钮、导航栏、开关、弹窗。

### 进阶风格(超出两套官方体系)
- 社区组件库:`fluent_ui`(Win11)、`macos_ui`、`shadcn_ui`、`forui` —— 独立设计语言
- 自己画:`CustomPaint` + `Canvas`、底层 Widget 拼装 —— 完全自由,Flutter 精髓
- 工程化:基于 Material 建自己的 Design System(用 `ThemeData` + 自封装组件统一风格)

---

## 八、按钮家族(Material)

按视觉权重从强到弱:
| 按钮 | 样式 | 适用 |
|---|---|---|
| `ElevatedButton` | 实心带阴影 | 最主要操作 |
| `FilledButton` | 实心无阴影(M3 新增) | 主操作,更现代 |
| `FilledButton.tonal` | 柔和实心 | 重要但非最重要 |
| `OutlinedButton` | 描边透明 | 次要操作(取消) |
| `TextButton` | 纯文字 | 最弱(跳过、链接式) |

其他:
- `.icon` 变体 —— 文字前带图标,如 `ElevatedButton.icon`
- `IconButton` —— 纯图标(工具栏小图标)
- `FloatingActionButton` —— 悬浮圆钮
- `InkWell` —— 让任意 Widget 可点击 + 水波纹涟漪
- `GestureDetector` —— 纯手势监听,无视觉反馈,最自由

---

## 九、主题与全局背景色

### 设置全局背景色(推荐做法)
在 `ThemeData` 里设,一处生效全局,所有 Scaffold 默认背景都变:
```dart
theme: ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,  // ← 全局页面背景
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,    // 主色,派生一套协调色
    brightness: Brightness.dark,     // 深色调要用 dark
    surface: AppColors.background,
  ),
),
```
- `scaffoldBackgroundColor` 才是真正管「页面背景」的属性
- 深色背景必须把 `brightness` 设为 `dark`,否则默认文字/图标颜色对比度不对
- 单个页面想特殊:在那个 `Scaffold` 上写 `backgroundColor`

### 设计 Token
把颜色集中到一个 `AppColors` 类里(单一来源),避免魔法色值散落各处。同理,动画时长等也建议抽成常量。

---

## 十、导航壳(Shell)与底部导航

### 概念
「导航壳(Shell)」= 装着底部导航栏 + 各个 tab 页面的**外层容器页面**。底部导航要切换页面、记住当前选中的 tab,需要一个 `StatefulWidget` 容器承载。导航栏只是壳里的一个部件。

### 底部导航(Material 3)
用 `NavigationBar`(而非老的 `BottomNavigationBar`):
```dart
Scaffold(
  body: IndexedStack(index: _currentIndex, children: _pages),  // 保留各 tab 状态
  bottomNavigationBar: NavigationBar(
    selectedIndex: _currentIndex,
    onDestinationSelected: (i) => setState(() => _currentIndex = i),
    destinations: const [
      NavigationDestination(icon: Icon(...), label: '首页'),
      // ...
    ],
  ),
)
```
- `IndexedStack` —— 同时保留所有页面状态,只显示当前索引那个(切回时滚动位置等还在)
- 用 `NavigationBarTheme` + `WidgetStateProperty.resolveWith` 按选中状态配不同颜色(深色底 + 黄高亮)
- `indicatorColor: Colors.transparent` 可去掉选中项背后的指示块

### 嵌套 Scaffold 的取舍
tab 页面里要不要再套 Scaffold?
- 占位页/纯内容、没有 appBar → **不需要**,直接返回 `Center` 等即可
- 这个 tab 要有自己的 AppBar / FAB → **需要**保留

---

## 十一、装饰与边框(BoxDecoration)

### 核心认知:为什么 border 要放进 decoration
边框、背景、圆角、阴影、渐变本质上是「同一套视觉装饰」,需要**协调绘制、互相感知**(比如圆角要同时裁剪背景色、背景图和边框)。所以 Flutter 把它们打包成一个 `BoxDecoration` 对象统一管理,而不是拆成 `Container` 上一堆容易打架的散装参数。

记住主线:**凡是「画在盒子上的视觉效果」,都归 decoration 管。**

`decoration` 的类型是抽象的 `Decoration`,`BoxDecoration` 只是最常用的实现(另有 `ShapeDecoration` 用于斜切角、星形等复杂形状)。它用在 `Container` 或 `DecoratedBox` 上。

### BoxDecoration 能放的全部属性
| 属性 | 作用 | 示例 |
|---|---|---|
| `color` | 背景纯色 | `color: AppColors.card` |
| `border` | 边框 | `Border.all(color: ..., width: 1)` |
| `borderRadius` | 圆角 | `BorderRadius.circular(12)` |
| `boxShadow` | 阴影(可多层,是 List) | `[BoxShadow(...)]` |
| `gradient` | 渐变背景 | `LinearGradient(...)` |
| `image` | 背景图 | `DecorationImage(...)` |
| `shape` | 整体形状 | `BoxShape.circle` / `.rectangle` |
| `backgroundBlendMode` | 背景混合模式 | 较少用 |

### border 的几种写法
```dart
// 四边统一
Border.all(color: AppColors.border, width: 1)

// 只要某条边(常用于分隔线)
Border(bottom: BorderSide(color: Colors.grey, width: 1))

// 各边不同
Border(
  top: BorderSide(color: Colors.red, width: 2),
  bottom: BorderSide(color: Colors.blue, width: 1),
)

// 圆形边框(配 shape: BoxShape.circle,此时不能用 borderRadius)
BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 3))
```
> `BorderSide` = 单条边的描述;`Border` = 四条边的集合。

### 渐变三种
`LinearGradient`(线性)、`RadialGradient`(径向)、`SweepGradient`(扫描)。

### 综合例子:一张典型卡片
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.card,                          // 背景色
    borderRadius: BorderRadius.circular(16),        // 圆角
    border: Border.all(color: AppColors.border),    // 描边
    boxShadow: const [                              // 阴影
      BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
    ],
  ),
  child: ...,
)
```

### 互斥关系(容易踩坑)
| 不能同时用 | 原因 |
|---|---|
| `Container.color` + `decoration` | 背景色要写进 decoration 里 |
| `color` + `gradient` | 都是定义背景填充 |
| `shape: circle` + `borderRadius` | 圆形没有「角」 |

### 背景图的两种思路
- **当背景装饰**:`BoxDecoration.image = DecorationImage(...)`(图在盒子背后,上面可叠内容)
- **当独立内容**:`Image.asset(...)` 作为 Widget(如首页 460 大图)

---

## 附:本项目踩坑清单

1. **图片放错目录**:放进了 `lib/assets/`,应放项目根 `assets/`
2. **声明空目录致白屏**:pubspec 声明了空的 `assets/videos/`
3. **改入口页用错刷新键**:改了开屏页却没变,因为它已被 pushReplacement 销毁,应按 `R` 而非 `r`
4. **加依赖后没 pub get**:引入 `lucide_icons` 后报 `depend_on_referenced_packages`,需 `flutter pub get` 刷新

---

## 十二、Column / Row 的空间分配(重点)

做底部「引文卡 + 艺人名 + 粉丝数」这组布局时反复纠结的核心知识。

### mainAxisSize:Column 自己占多高
- `MainAxisSize.max`(默认)—— 撑满父级给的全部空间
- `MainAxisSize.min` —— 只占内容本身的大小,刚好包住孩子

> 类比前端:`max` ≈ `height:100%`,`min` ≈ `height:fit-content`。
> 一个模块(如 `ArtistNameSection`)通常用 `min`,免得它贪婪撑满、把兄弟挤开。

### 三个易混属性分工
| 属性 | 管什么 |
|---|---|
| `mainAxisSize` | Column 自己**占多大**(纵向=高度) |
| `mainAxisAlignment` | 孩子在主轴上**怎么排**(start/center/end/spaceAround...) |
| `crossAxisAlignment` | 孩子在交叉轴上**怎么对齐**(纵向列里=左/中/右) |

⚠️ `mainAxisAlignment` 只有在 `MainAxisSize.max`(有多余空间)时才有意义;设了 `min` 紧包内容,就没空间可分了。

### 踩坑:textAlign 不生效
在 Column 里给每个 `Text` 写 `textAlign: TextAlign.left` 看不出效果 —— 因为 Text 只占自己内容宽度,没有多余空间,textAlign 无从对齐。**真正让整列靠左的是 `Column(crossAxisAlignment: CrossAxisAlignment.start)`**。

### 「从顶部布局」怎么改成「贴底」
`Column` 默认 `mainAxisAlignment: start`,所以内容堆在顶部。两种贴底思路:
- **整体贴底**:`mainAxisAlignment: MainAxisAlignment.end`,所有内容成团贴底向上堆
- **上下分离**:中间插 `Spacer()`,上半部分留顶、下半部分顶到底

---

## 十三、Expanded / Flexible / Spacer

放在 Row / Column 里分配**剩余空间**的三兄弟。

| 组件 | 行为 | 前端类比 |
|---|---|---|
| `Expanded` | **强制**占满分到的空间 | `flex: 1` |
| `Flexible` | **最多**占这么多,内容小就不占满 | `flex: 0 1 auto` |
| `Spacer` | 看不见的 Expanded,纯占空白 | 空的 `flex:1` div |

- 机制:固定大小的元素先摆好,**剩余空间**由这些 Expanded/Spacer 瓜分。
- 默认 `flex: 1`,可调比例:`Expanded(flex: 2)` 是 `flex: 1` 的两倍宽。
- 本质关系:`Spacer()` ≈ `Expanded(child: SizedBox())`。一个撑空白,一个撑内容。

### Spacer vs SizedBox(margin 的真正对应物)
- 固定间距 → `SizedBox(height: 16)`(这才等于前端的 `margin: 16px`)
- 弹性留白 → `Spacer()`(等于 `flex: 1`,随容器大小伸缩)

---

## 十四、列表项之间的分隔线

需求:N 个 item 之间要 N-1 条分隔线(首尾不多线)。

### 关键认知:位置逻辑归父级,别塞进 item
不要给每个 item 加 `border-left` —— 第一个会多出一条线(同前端 `:first-child` 要特殊处理的坑)。根本原因:**item 是独立 widget,它不知道自己是不是第一个/最后一个**,「我在第几位」是布局层(父级)才掌握的信息。塞进 item 会污染它的职责、也不利复用。

### 推荐写法:父级用循环穿插
```dart
Row(
  children: [
    for (var i = 0; i < items.length; i++) ...[
      Expanded(child: items[i]),       // 等宽平分,分隔线才落在均匀位置
      if (i < items.length - 1)         // 最后一个后面不加
        Container(width: 1, height: 50, color: AppColors.border),
    ],
  ],
)
```
- 用 `Expanded` 让每个 item 等宽,竖线才会卡在均匀位置(原 `spaceAround` 做不到)
- 顶部横线则用 `BoxDecoration(border: Border(top: BorderSide(...)))`
- 分隔线颜色用半透明 token(如主色 15% 透明)更自然

> `...[ ]` 是 Dart 的「展开(spread)」语法,把循环里生成的多个 widget 摊平进 children 列表。

---

## 十五、SVG 图标(flutter_svg)

把内置 `Icon` 换成自定义 SVG 图标(平台 logo 等)。

### 三步
1. **装包**:`flutter_svg`(pubspec 已有)
2. **注册目录**:把 SVG 放 `assets/icons/`,并在 pubspec 声明 + `flutter pub get`
   ```yaml
   flutter:
     assets:
       - assets/icons/
   ```
3. **代码引用**:
   ```dart
   SvgPicture.asset(
     'assets/icons/instagram.svg',
     width: 22,
     height: 22,
     // 给单色图标统一上色
     colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
   )
   ```

### colorFilter 要点
- `ColorFilter.mode(色, BlendMode.srcIn)` = 用图标形状、颜色全换成指定色,适合**单色 logo**。
- ⚠️ 对**多色/渐变 SVG**(如彩色 Instagram),`srcIn` 会把整个图标染成一个色、丢掉原配色。想保留原色就别加 `colorFilter`。
- 图标显示成色块/比例错乱 → 多半是该 SVG 内 `fill` 写死了颜色,或缺 `viewBox`。

---

## 十六、Dart 的 final / var / const

| Dart | 含义 | JS 类比 |
|---|---|---|
| `final x = 1;` | 赋值一次,之后不可重新赋值 | `const`(不可重新赋值) |
| `var x = 1;` | 可重新赋值 | `let` |
| `const x = 1;` | **编译期**就能确定的常量 | —— |

### final vs const(易混)
- `final`:**运行时**才算出值,但赋值后不变。
- `const`:**编译期**就定死,更严格。
- 例:`final style = GoogleFonts.anton(...)` 只能用 `final`,因为它是运行时函数调用算出来的;而 `const SizedBox(height: 8)` 编译期就确定,能用 `const`。

### 顺带:抽「通用样式」就是声明个变量复用
```dart
final nameStyle = GoogleFonts.anton(fontSize: 48, fontWeight: FontWeight.w700);
Text('JACKSON', style: nameStyle.copyWith(color: AppColors.foreground));
Text('WANG',    style: nameStyle.copyWith(color: AppColors.primary));
```
`final` 只负责「声明一个不再改的变量」;放在 build 顶部多处引用,就成了「通用样式」。类型可省略(Dart 自动从右值推断,同 TS)。`copyWith` 在共用基础上只改个别属性(这里只改颜色)。

---

## 十七、导航的两套体系:tab 切换 ≠ 页面路由

这是 Flutter 和前端最容易混的一点。**底部 tab 切换**和**二级页面跳转**是两回事,用不同机制。

| | 底部 tab(平级切换) | 二级页面跳转 |
|---|---|---|
| 性质 | 5 个 tab 互相平等,来回切 | 从 A 钻进 A 的子页 |
| 返回 | 没有「返回」概念 | 有返回栈,自动返回箭头 + iOS 侧滑返回 |
| 例子 | 大厅 / 音乐 / 信箱 / 我的 | 我的 → 我的收藏 → 卡片详情 |
| 前端类比 | tab 切换 | 路由 push |
| 实现 | AnimatedSwitcher / PageView + 索引 | `Navigator.push` |

**关键认知**:底部 tab 那套(PageView/AnimatedSwitcher)做不了「返回」,所以二级页面**不能**用它,要用 `Navigator`。

### Flutter 内置 Navigator,不用装 router
和前端不同,二级页面**不需要装 react-router 那种库**,Flutter 自带 `Navigator`(页面栈):
```dart
// 进入二级页(自动带返回箭头、支持侧滑返回)
Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
// 返回
Navigator.pop(context);
```
- `push` 压入新页面 / `pop` 弹出返回(同你笔记里开屏用的 `pushReplacement` 一家)
- 进去的页面只要用了 `AppBar`,返回箭头**自动出现**,不用手写

### 什么时候才需要 GoRouter
内置 `Navigator` 能撑很久。出现以下信号才升级到 `GoRouter`:
- 需要 URL / 网页深链接(分享链接直达某页,Web 端尤其要)
- 二三级页面特别多、跳转关系复杂
- 需要登录守卫、统一路由表
这些没有就别上,属于过早优化。

### 完整图景:两套导航叠加
```
HomeShell(底部 tab,平级)              ← AnimatedSwitcher
├── 大厅
├── 音乐
├── 信箱
└── 我的 ──push──> 我的收藏 / 设置        ← Navigator(纵向二级页)
```
横向 tab + 各 tab 内部 push 子页,这是 Flutter 标准做法,两者不冲突。

---

## 十八、命名路由:集中登记有哪些页面

二级页面多了,可以用「命名路由」集中管理,一眼看全有哪些路由。

### 路由名常量 + 路由表
```dart
// core/navigation/app_routes.dart
class AppRoutes {
  static const favorites = '/me/favorites';
  static const settings = '/me/settings';
}

final appRoutes = <String, WidgetBuilder>{
  AppRoutes.favorites: (_) => const FavoritesPage(),
  AppRoutes.settings: (_) => const SettingsPage(),
};
```
注册到 `MaterialApp(routes: appRoutes)`,跳转用 `Navigator.pushNamed(context, AppRoutes.favorites)`。

### 命名路由 vs 直接 push
| | 命名路由 `pushNamed` | 直接 `push(MaterialPageRoute)` |
|---|---|---|
| 路由总览 | ✅ 路由表一目了然 | ❌ 散落 |
| 传参 | ⚠️ 走 `arguments`,类型不安全(要强转) | ✅ 直接传构造参数,类型安全 |
| 适合 | 无参/简单的二级页 | 要传复杂参数(如某张卡的 id) |

---

## 十九、跨层级通信:InheritedWidget(= React Context)

**问题**:深层组件要触发顶层动作(如首页的卡片点击 → 切到「信箱」tab,而 tab 状态在最顶层 Shell,中间隔好几层)。

**做法**:用 `InheritedWidget` 自上而下共享一个「能力」,深层组件 `.of(context)` 直接拿,不用一层层传回调(避免 prop drilling)。它就是 **Flutter 内置的 React Context**。

```dart
// 顶层(Shell)提供「切 tab 能力」
TabSwitcher(switchTo: _switchToId, child: Scaffold(...))

// 任意深层组件取用
TabSwitcher.of(context).switchTo(TabId.mailbox);
```

要点:
- `dependOnInheritedWidgetOfExactType<T>()` 取最近的祖先(封装成 `maybeOf` / `of`)
- 对照表:`InheritedWidget` ≈ `Context.Provider`,`.of(context)` ≈ `useContext`

---

## 二十、封装「能力」以隔离实现 —— 贯穿全程的核心套路

反复用到的同一招:**封装「做什么」,隐藏「怎么做」**。调用方只表达意图,底层实现随时能换,迁移成本从「改几十处」降到「改一处」。

| 封装 | 暴露的能力(做什么) | 隐藏的实现(怎么做) | 将来换实现只改 |
|---|---|---|---|
| `AssetDataService` | `loadDailyQuotes()` 取数据 | 写死 → 将来 Firebase/接口 | service 一处 |
| `TabSwitcher` | `switchTo(TabId)` 切 tab | setState → 将来状态管理/路由 | Shell 一处 |
| 命名路由 / 跳转封装 | 「去收藏页」 | `Navigator` → 将来 GoRouter | 路由表一处 |

判断技术债的原则:**只要「意图」和「实现」解耦,底层就能随时换,就不算债。** 担心「现在不用 X 以后迁移麻烦」时,答案通常不是「现在就上 X」,而是「先封装好接口」。

### 配套:用枚举代替魔法索引
切 tab 别用数字(`switchTo(3)`),用语义枚举:
```dart
enum TabId { home, music, mailbox, profile }
TabSwitcher.of(context).switchTo(TabId.mailbox);  // 说「去信箱」,不说「去第3个」
```
即使 tab 增删/调序,这行也不用改 —— Shell 内部用 `indexWhere` 按身份查实际位置。

---

## 二十一、UI 唯一数据源:一份配置生成多处

**踩过的坑**:底部导航的 `destinations`(导航项)和 `_pages`(页面)分两处手写,靠索引一一对应。删一个 tab 忘了同步另一处,就**全部错位**。

**解法**:抽一个 tab 配置列表做**唯一数据源**,导航项和页面都从它生成:
```dart
class _TabItem { final TabId id; final IconData icon; final String label; final Widget page; ... }

static const _tabs = [
  _TabItem(id: TabId.home, icon: ..., label: '大厅', page: HomePage()),
  // ...
];

// 页面:   _tabs[_currentIndex].page
// 导航项: for (final tab in _tabs) NavigationDestination(icon: Icon(tab.icon), label: tab.label)
```
增删/调序 tab **只改 `_tabs` 一处**,两边自动同步、永不错位。原则:**同一份数据别写两遍。**

---

## 二十二、通用页面脚手架 & 截图/分享/保存

### 通用二级页脚手架(SubPage)
二级页都有「标题 + 返回 + 可选操作按钮」,抽成一个组件,各页只传标题和内容:
```dart
SubPage(
  title: '我的收藏',
  actions: [IconButton(...)],   // 可选,不传则没有
  child: 内容,
)
```
- 返回箭头由 `AppBar` + `push` **自动**提供,不用手写
- 改一处样式,所有二级页统一变

### Widget 截图成图片
用 `RepaintBoundary` + `GlobalKey` 把任意 widget 渲染成 PNG(所见即所得,叠加的水印等都进图):
```dart
final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
final image = await boundary.toImage(pixelRatio: 3.0);   // >1 更高清
final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
```
关键:`RepaintBoundary` 包在切换器(AnimatedSwitcher)**外层**,GlobalKey 才始终指向当前显示的内容。

### 分享 vs 保存到相册
| 功能 | 包 | 权限 | 最后一步 |
|---|---|---|---|
| 分享 | `share_plus` + `path_provider` | **不要** | 写临时文件 → `SharePlus.instance.share` 调系统面板 |
| 存相册 | `gal` | **要**(iOS 配 `NSPhotoLibraryAddUsageDescription`,Android 配权限) | `Gal.putImageBytes(bytes)` |

两者**共用截图那一步**(截图工具抽成 core 函数复用),只是末端不同。都用 try-catch 兜底,失败弹 SnackBar(toast)。

### 异步用 context 的防护(再次强调)
`_share`/`_download` 是 async,`await` 后用 `context`(如弹 SnackBar)前必须 `if (!mounted) return;` —— 和动画延迟回调同一个坑。

### 装原生包后必须完全重启
`share_plus` / `gal` / `path_provider` 含原生代码,装完 + 改了 Info.plist/AndroidManifest,**必须停掉 `flutter run` 重跑**,热重载/热重启都加载不了原生层。(同 pubspec 改 assets/字体的规律。)

---

## 二十三、Future / async / await(= JS 的 Promise)

`Future<T>` 代表「现在还没有、未来会有的值」—— Dart 版 Promise。网络请求、读文件、定位等耗时操作都返回它。

| Dart | JS |
|---|---|
| `Future<T>` | `Promise<T>` |
| `async` / `await` | `async` / `await`(完全一致) |
| `.then()` | `.then()` |
| `Future.value(x)` | `Promise.resolve(x)` |

```dart
Future<Weather> loadWeather() async {
  final res = await http.get(url);          // 等网络返回
  return Weather.fromJson(jsonDecode(res.body));
}
final w = await loadWeather();              // 调用方等它出结果
```

三种状态(同 Promise):未完成 / 完成有值 / 完成有错。

---

## 二十四、网络请求(http 包)

```dart
// pubspec: http
import 'package:http/http.dart' as http;
import 'dart:convert';

final res = await http.get(Uri.parse('https://...'));
if (res.statusCode != 200) throw Exception('请求失败');
final json = jsonDecode(res.body) as Map<String, dynamic>;  // 解析 JSON
final model = MyModel.fromJson(json);                        // 配 fromJson 用
```

要点:
- `Uri.parse(...)` 把字符串转成 URL 对象
- `jsonDecode` 把响应体字符串解析成 Map/List,再喂给模型的 `fromJson`
- iOS/Android 默认允许 HTTPS 出站,无需额外配置(HTTP 明文才需配 ATS)

### 免费天气 API:Open-Meteo
无需注册、无需 key、个人用约等于无限量。天气接口要**经纬度**(不收城市名),天气状况是 WMO **数字代码**,需自己映射成「晴/雨」+ emoji。

---

## 二十五、FutureBuilder:按异步状态渲染 UI

UI 的 build 不能 `await`(必须立刻返回 widget)。`FutureBuilder` 帮你监听一个 Future,在「加载中 / 成功 / 失败」三态分别渲染:

```dart
FutureBuilder<Weather>(
  future: _weatherFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return 加载中;
    if (snapshot.hasError || !snapshot.hasData) return 出错;
    return 显示(snapshot.data!);
  },
)
```

**最常见的坑**:`future:` 要在 `initState` 里取一次存起来(`late final _f = service.load()`),**别在 build 里直接** `future: service.load()` —— 否则每次 build 都重新发起请求。

### 缓存省请求
Service 内部加个内存缓存(记录上次结果 + 时间戳),TTL 内重复调用直接返回上次结果,不重复打网络:
```dart
if (_cache != null && DateTime.now().difference(_cacheAt!) < _ttl) return _cache!;
```

---

## 二十六、地理定位(geolocator)& 优雅降级

```dart
// pubspec: geolocator
// iOS Info.plist: NSLocationWhenInUseUsageDescription(权限说明,不配会闪退)
// Android Manifest: ACCESS_FINE/COARSE_LOCATION

// 流程:服务是否开启 → 检查/请求权限 → 取坐标
final ok = await Geolocator.isLocationServiceEnabled();
var perm = await Geolocator.checkPermission();
if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
final pos = await Geolocator.getCurrentPosition();   // pos.latitude / longitude
```

### 优雅降级(关键设计)
定位极易失败(用户拒绝/系统关定位/超时),所以**必须兜底**。把「定位 → 失败回默认值」封装在 Service 内部,UI 完全不用管:
```dart
try {
  final coord = await location.getCurrentCoordinates();  // 成功:真实位置
} catch (_) {
  // 失败:降级到默认城市(上海),保证功能始终可用
}
```

坑:
- **iOS 模拟器默认没位置**,要在模拟器菜单 `Features → Location` 设一个,否则定位拿不到、走降级
- 定位只给经纬度,要城市名得另调「逆地理编码」接口

---

## 二十七、自定义 App 图标(flutter_launcher_icons)

不用手动做几十个尺寸 —— 准备**一张 1024×1024 PNG**,工具自动生成各平台全部尺寸。

```yaml
# dev 依赖:flutter_launcher_icons
flutter_launcher_icons:
  image_path: "assets/images/logo/app_icon.png"
  android: true
  ios: true
  remove_alpha_ios: true            # iOS 图标不支持透明,去 alpha
  background_color_ios: "#080808"   # 透明处填此底色(否则变黑)
```
```
dart run flutter_launcher_icons   # 一键生成
```

要点:
- 源图**正方形、不要自己加圆角**(系统自动裁)、**iOS 不能透明**(透明处会黑,用 `remove_alpha_ios` + 背景色兜底)
- 图标是原生资源,生成后**必须完全重启**;且要回**模拟器桌面**看(app 内部看不到自己的图标)
- 各平台图标实际存放:iOS `Runner/Assets.xcassets/AppIcon.appiconset/`,Android `res/mipmap-*/`

---

## 二十八、按功能组织代码(feature-first)

把一个完整功能的所有文件收进一个 feature 目录,而非按文件类型散放。例:天气功能集中成 `features/sky/`:
```
features/sky/
├── models/weather.dart
├── services/weather_service.dart   # 数据 + 定位降级
│   └── location_service.dart
└── widgets/
    ├── sky_entry.dart              # 首页入口
    └── sky_sheet.dart              # 浮层
```
好处:改一个功能,相关文件都在一处;功能之间隔离;新增功能自成一块。

判断放哪:**某功能专属 → 放该 feature;跨功能通用 → 放 core**(主题、通用 widget、工具)。
