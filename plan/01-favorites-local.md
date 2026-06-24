# 01 · 收藏(本地)

## 现状
- `core/services/favorites_service.dart`:空壳,`loadFavoriteIds` 返回 `[]`,`toggleFavorite` 空实现。
- `features/profile/pages/favorites_page.dart`:占位文字「收藏的卡片(待实现)」。
- `features/daily/widgets/daily_card_swiper.dart:389`:已有心形按钮 `_CircleButton(icon: LucideIcons.heart, onTap: () {})`,`onTap` 为空。
- 目前唯一可收藏的内容是「每日一言」`DailyQuote`(无 id 字段)。

## 待确认
1. **存 id 还是存完整快照?**
   - 推荐「存快照」:收藏页能显示「当时那张卡片」,不依赖远端,远端内容改了也不影响。
   - `DailyQuote` 目前没有 `id`,存快照可绕开「没有 id」的问题(用 background 路径或内容做 key)。
2. 收藏对象目前只有 `DailyQuote`,还是以后作品/图集也要能收藏?(影响要不要做成「带 type 的通用收藏」)

## 方案(按「存快照 + 通用收藏」设计)
- 依赖:`shared_preferences`
- 存储结构(单个 key `favorites`,值为 JSON):
  ```
  {
    "<key>": { "type": "quote", "data": { ...DailyQuote.toJson() }, "savedAt": "..." }
  }
  ```
- `DailyQuote` 补 `toJson()`(已有 `fromJson`)。

## 改动清单
- [ ] pubspec 加 `shared_preferences`
- [ ] `DailyQuote` 加 `toJson()`;确定 key 怎么取(background 路径 or 内容 hash)
- [ ] 重写 `FavoritesService`:`add / remove / toggle / isFavorited / loadAll`
- [ ] `daily_card_swiper.dart` 心形按钮接 `toggle`,并根据 `isFavorited` 显示选中态
- [ ] `favorites_page.dart` 渲染收藏列表(复用每日卡片样式)

## 验证
- 收藏一张 → 杀进程重开 → 收藏页还在、心形仍高亮。
