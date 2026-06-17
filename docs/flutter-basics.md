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
