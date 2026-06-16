# Jackson Fan App

一个基于 Flutter 的王嘉尔粉丝 App 示例项目。当前项目已经搭好基础页面结构和核心组件，主要用于集中展示艺人简介、作品集、相册、时间轴、收藏和表情包等内容。

目前数据层还是占位实现，页面中的作品、照片、动态等内容后续会改为从本地 `assets/data/*.json` 或接口读取。

## 功能概览

- 首页：展示 Jackson Wang / 王嘉尔主题 Hero 区、快速入口和最新动态模块。
- 作品集：作品列表页与作品详情页骨架。
- 相册：网格相册页面骨架。
- 时间轴：预留时间轴页面。
- 收藏：预留收藏页面和收藏服务。
- 表情包：预留表情包页面。
- 数据模型：已定义艺人资料、作品、相册照片等模型。
- 通用组件：已抽出区块标题、图片卡片、作品卡片等组件。

## 目录结构

```text
jackson_fan_app/
├── android/                 # Android 平台工程
├── ios/                     # iOS 平台工程
├── linux/                   # Linux 桌面端工程
├── macos/                   # macOS 桌面端工程
├── web/                     # Web 端入口与图标资源
├── windows/                 # Windows 桌面端工程
├── lib/
│   ├── main.dart            # 应用入口，启动 JacksonFanApp
│   ├── app.dart             # MaterialApp、主题和首页配置
│   ├── core/
│   │   ├── models/          # 数据模型：ArtistProfile、WorkItem、GalleryPhoto
│   │   ├── services/        # 数据与收藏服务，目前为占位实现
│   │   └── widgets/         # 通用 UI 组件
│   └── features/
│       ├── home/            # 首页、HeroBanner、LatestUpdates
│       ├── works/           # 作品列表、作品详情、WorkCard
│       ├── gallery/         # 相册页面
│       ├── timeline/        # 时间轴页面占位
│       ├── favorites/       # 收藏页面占位
│       └── stickers/        # 表情包页面占位
├── test/                    # Widget 测试
├── pubspec.yaml             # Flutter 项目配置和依赖
├── analysis_options.yaml    # Dart/Flutter lint 配置
└── README.md
```

## 环境要求

- Flutter SDK：`pubspec.yaml` 当前要求 Dart SDK `^3.12.1`。
- Xcode：运行 iOS/macOS 需要。
- Android Studio 或 Android SDK：运行 Android 需要。
- Chrome：运行 Web 版本需要。

检查本机环境：

```bash
flutter doctor
```

## 安装依赖

在项目目录执行：

```bash
cd flutter/jackson_fan_app
flutter pub get
```

## 启动项目

查看可用设备：

```bash
flutter devices
```

运行到默认设备：

```bash
flutter run
```

指定平台运行示例：

```bash
flutter run -d chrome
flutter run -d macos
flutter run -d ios
flutter run -d android
```

## 测试与检查

运行 Widget 测试：

```bash
flutter test
```

静态分析：

```bash
flutter analyze
```

格式化代码：

```bash
dart format lib test
```

## 构建

Web 构建：

```bash
flutter build web
```

Android APK：

```bash
flutter build apk
```

iOS 构建：

```bash
flutter build ios
```

macOS 构建：

```bash
flutter build macos
```

## 当前状态与后续方向

- `AssetDataService` 当前返回占位资料，后续可接入 `assets/data/profile.json`、`works.json`、`gallery.json`。
- `FavoritesService` 当前未做持久化，后续可接入 `shared_preferences` 或本地数据库。
- 首页的时间轴、收藏入口目前还未绑定跳转。
- 作品集和相册页面使用静态占位数据，后续需要替换为真实内容和图片资源。
- 如果要新增本地图片或 JSON，需要在 `pubspec.yaml` 的 `flutter.assets` 中声明资源路径。
