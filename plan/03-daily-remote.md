# 03 · 每日一言(远端)

## 现状
- `core/services/asset_data_service.dart`:`loadDailyQuotes()` 写死 6 条,返回 `Future<List<DailyQuote>>`。
- `core/models/daily_quote.dart`:已有 `fromJson`(为接远端预留)。
- `features/daily/widgets/daily_card_swiper.dart`:用 `FutureBuilder` 消费,已有加载态。
- **关键优势**:Future 签名和 fromJson 都已就绪,接远端时调用方零改动。

## 待确认
1. 远端地址用哪个?
   - 推荐 **jsDelivr**:`https://cdn.jsdelivr.net/gh/<用户>/<仓库>@main/data/daily_quotes.json`(国内相对稳)。
   - 备选 GitHub raw:国内常连不上,仅适合测试。
2. 远端 JSON 里的 `background` 怎么处理?
   - 现在 background 是 **本地 assets 路径**(如 `assets/images/bgs/1.jpeg`)。
   - 若图也要远端化,需改成网络图 URL + 用 `Image.network`;否则远端只下发文字、背景仍用内置图(需约定图片编号/索引)。**这点要定**。

## 方案
- 远端只读 JSON,`http` GET 拉取 → `fromJson` 解析。
- **必须兜底**:网络失败 / 国内连不上时,回退到现在写死的 6 条(挪到 assets 或保留为常量)。
- 中文注意:用 `utf8.decode(res.bodyBytes)` 解析,避免乱码。
- 可选:加本地缓存(prefs 存上次拉取结果 + 时间戳),仿照 `WeatherService` 的 1 小时缓存思路,弱网也能秒开。

## 改动清单
- [ ] 准备远端 `daily_quotes.json` 并托管(GitHub 仓库)
- [ ] 新增 `RemoteDataService` 或改造 `AssetDataService.loadDailyQuotes()`:先拉远端,失败回退内置
- [ ] (可选)加 prefs 缓存层
- [ ] 确认 background 是「内置图」还是「网络图」,据此决定卡片渲染方式

## 验证
- 改远端 JSON → App 重开能看到新内容(注意 jsDelivr/raw 有 CDN 缓存延迟)。
- 断网 → 仍显示兜底内容,不报错、不白屏。
