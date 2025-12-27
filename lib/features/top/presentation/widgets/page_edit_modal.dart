import 'package:flutter/material.dart';
import '../../domain/page_entity.dart';

/// ページ編集モーダル
///
/// ページ名の変更と並び替えを行うモーダルです。
class PageEditModal extends StatefulWidget {
  /// ページリスト
  final List<PageEntity> pages;

  /// 保存時のコールバック
  final ValueChanged<List<PageEntity>> onSave;

  /// コンストラクタ
  const PageEditModal({super.key, required this.pages, required this.onSave});

  @override
  State<PageEditModal> createState() => _PageEditModalState();
}

class _PageEditModalState extends State<PageEditModal> {
  late List<PageEntity> _pages;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _pages = List.from(widget.pages);
    for (final page in _pages) {
      _controllers[page.id] = TextEditingController(text: page.name);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 保存処理
  void _save() {
    // ページ名を更新
    final updatedPages = _pages.map((page) {
      final controller = _controllers[page.id];
      if (controller != null && controller.text.isNotEmpty) {
        return page.copyWith(name: controller.text);
      }
      return page;
    }).toList();

    // 順序を更新
    final orderedPages = updatedPages.asMap().entries.map((entry) {
      return entry.value.copyWith(order: entry.key);
    }).toList();

    widget.onSave(orderedPages);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - statusBarHeight;
    final modalHeight = availableHeight * 0.95;

    return SizedBox(
      height: modalHeight,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // 左側のスペーサー（バツボタンと対称にするため）
                      const SizedBox(width: 48),
                      // タイトル
                      const Expanded(
                        child: Text(
                          'ページの編集',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // バツボタン（右上）
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: theme.iconTheme.color),
                      ),
                    ],
                  ),
                  // 説明文
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'ページ名の変更と並び替えができます',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ボディ
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = _pages.removeAt(oldIndex);
                      _pages.insert(newIndex, item);
                    });
                  },
                  children: _pages.map((page) {
                    return _PageEditCard(
                      key: ValueKey(page.id),
                      page: page,
                      controller: _controllers[page.id]!,
                    );
                  }).toList(),
                ),
              ),
            ),
            // アップグレードセクション
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber[600]),
                      const SizedBox(width: 8),
                      Text(
                        'アップグレード',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: アップグレード処理
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.cardColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            // フッター
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.cyan[50],
                border: Border(
                  top: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan[100],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '保存',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

/// ページ編集カード
class _PageEditCard extends StatelessWidget {
  /// ページ
  final PageEntity page;

  /// テキストコントローラー
  final TextEditingController controller;

  /// コンストラクタ
  const _PageEditCard({
    super.key,
    required this.page,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.3) // ダークモード：はっきりとした黒エリア
            : theme.scaffoldBackgroundColor,
        border: isDark
            ? null // ダークモード：境界線なし（背景色で表現）
            : Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 入力欄（左90%）
          Expanded(
            flex: 9,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          // ドラッグハンドル（右10%）
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
