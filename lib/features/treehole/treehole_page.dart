import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../core/models/letter.dart';
import '../../core/services/treehole_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/entrance_animation.dart';
import '../../core/widgets/section_title.dart';

/// 树洞页:底部导航「树洞」tab 对应的页面。
///
/// 一个安静的私密空间,用户可以写下想对 Jackson 说的话。
/// 信件纯本地存储,仅本人可见。支持新增与删除(不支持编辑)。
class TreeholePage extends StatefulWidget {
  const TreeholePage({super.key});

  @override
  State<TreeholePage> createState() => _TreeholePageState();
}

class _TreeholePageState extends State<TreeholePage> {
  static const _service = TreeholeService();

  List<Letter> _letters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _service.loadAll();
    if (mounted) {
      setState(() {
        _letters = list;
        _loading = false;
      });
    }
  }

  /// 打开写信弹窗,确认后落库并刷新列表。
  Future<void> _compose() async {
    final result = await showModalBottomSheet<_ComposeResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ComposeSheet(),
    );
    if (result == null) return;

    await _service.add(content: result.content, mood: result.mood);
    await _load();
  }

  Future<void> _remove(Letter letter) async {
    await _service.remove(letter.id);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已删除'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _letters.isEmpty
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              onPressed: _compose,
              child: Icon(LucideIcons.feather, size: 20),
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const _TitleBar(),
              const SizedBox(height: 40),
              Expanded(
                child: _loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      )
                    : _letters.isEmpty
                        ? _EmptyState(onWrite: _compose)
                        : _LetterList(
                            letters: _letters,
                            onRemove: _remove,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 顶部标题栏。
class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SectionTitle(eyebrow: 'TREE HOLE', title: '树洞'),
      ],
    );
  }
}

/// 信件列表(倒序),支持左滑删除。
class _LetterList extends StatelessWidget {
  const _LetterList({required this.letters, required this.onRemove});

  final List<Letter> letters;
  final void Function(Letter) onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        return _LetterCard(
          letter: letter,
          onRemove: () => onRemove(letter),
        );
      },
    );
  }
}

/// 单封信卡片:心情 + 时间 + 正文。
class _LetterCard extends StatelessWidget {
  const _LetterCard({required this.letter, required this.onRemove});

  final Letter letter;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(letter.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        color: AppColors.destructive,
        child: const Icon(LucideIcons.trash_2, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (letter.mood != null) ...[
                  Text(letter.mood!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                ],
                Text(
                  _formatTime(letter.createdAt),
                  style: TextStyle(
                    fontFamily: 'Barlow Condensed',
                    color: AppColors.mutedForeground,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              letter.content,
              style: TextStyle(
                color: AppColors.foreground,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化为 "2026-06-25 14:30"。
  static String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }
}

/// 空状态占位:毛玻璃卡片 + 提示文案 + 写信入口。
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onWrite});

  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EntranceAnimation(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.55),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '“有些话，只说给自己听就好。”',
                    style: TextStyle(
                      fontFamily: 'Anton',
                      color: AppColors.foreground,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '写下你想对他说的话\n这里只有你自己能看到',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: onWrite,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.feather,
                            color: AppColors.primaryForeground,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'To Jackson',
                            style: TextStyle(
                              color: AppColors.primaryForeground,
                              fontSize: 14,
                              fontWeight: AppColors.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 写信弹窗的返回结果。
class _ComposeResult {
  const _ComposeResult({required this.content, this.mood});

  final String content;
  final String? mood;
}

/// 可选心情表情。
const _moods = ['😊', '🥰', '😢', '😡', '🤔', '😴', '🎉', '💜'];

/// 写信底部弹窗:心情选择 + 正文输入。
class _ComposeSheet extends StatefulWidget {
  const _ComposeSheet();

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _controller = TextEditingController();
  String? _selectedMood;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    Navigator.of(context).pop(
      _ComposeResult(content: content, mood: _selectedMood),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 让弹窗避开键盘。
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '写给 Jackson',
                  style: TextStyle(
                    fontFamily: 'Anton',
                    color: AppColors.foreground,
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(LucideIcons.x, color: AppColors.mutedForeground),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 心情选择
            Text(
              '此刻心情',
              style: TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _moods.map((m) {
                final selected = _selectedMood == m;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedMood = selected ? null : m),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            selected ? AppColors.primary : Colors.transparent,
                      ),
                    ),
                    child: Text(m, style: const TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // 正文输入
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 5,
              minLines: 3,
              style: TextStyle(color: AppColors.foreground, height: 1.6),
              decoration: InputDecoration(
                hintText: '想对他说的话…',
                hintStyle: TextStyle(color: AppColors.mutedForeground),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 20),
            // 提交按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '放进树洞',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: AppColors.fontWeightMedium,
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
