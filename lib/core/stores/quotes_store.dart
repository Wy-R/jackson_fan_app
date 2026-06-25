import 'package:signals/signals.dart';

import '../models/daily_quote.dart';
import '../services/asset_data_service.dart';

/// 全局语录数据仓库。
///
/// 用 Signals 管理状态，任何页面都可以直接读取，不需要 BuildContext。
/// 类似 Vue 的全局 store。
class QuotesStore {
  QuotesStore._();

  static final instance = QuotesStore._();

  final _service = const AssetDataService();

  /// quotesDefault 数据（首页背景用）。
  final defaultQuote = signal<DailyQuote?>(null);

  /// 全部语录列表（每日一言轮播用）。
  final quotes = listSignal<DailyQuote>([]);

  /// 是否正在加载。
  final loading = signal(false);

  /// 加载远端数据。
  Future<void> load() async {
    if (loading.value) return;
    loading.value = true;

    try {
      final result = await _service.loadDefaultAndQuotes();
      defaultQuote.value = result.defaultQuote;
      quotes.value = result.quotes;
    } catch (_) {
      // 加载失败不影响使用，兜底数据在 service 层已处理
    } finally {
      loading.value = false;
    }
  }
}
