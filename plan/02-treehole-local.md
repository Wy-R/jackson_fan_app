# 02 · 树洞(本地)

## 现状
- `features/treehole/treehole_page.dart`:占位版,`_EmptyState` 提示,无写入逻辑。
- 注释已写明定位:「一个安静的私密空间,用户写下想对 Jackson 说的话」→ **私密、仅本人可见** → 纯本地。

## 待确认
1. 一条树洞包含哪些字段?建议:`id`、`content`(正文)、`createdAt`(时间)、可选 `mood`(心情/表情)。
2. 是否需要「编辑已有信件」,还是只「新增 + 删除」?
3. 列表怎么排?默认按时间倒序(最新在上)。

## 方案
- 先用 `shared_preferences` + JSON 数组(一个 key `treehole_letters`,值为 `List<Map>` 的 JSON)。
- 粉丝 App 树洞量级通常几十上百条,prefs 足够;**若以后要分页/全文搜索/量很大,再迁移到 sqflite**(届时只改 service 内部,页面不动)。

## 新增清单
- [ ] `core/models/letter.dart`:`Letter` 模型 + `toJson` / `fromJson`
- [ ] `core/services/treehole_service.dart`:`add / delete / loadAll`(可选 `update`)
- [ ] 树洞页:写信入口(底部按钮/FAB)+ 写信页/弹窗 + 信件列表
- [ ] 空态保留(没有信件时显示 `_EmptyState`)

## 验证
- 写一封 → 重开 App 还在;删除后不再出现。
