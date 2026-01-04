import 'package:flutter/material.dart';
import '../../domain/page_entity.dart';

/// ページ編集モーダル
///
/// ページ名の変更と並び替えを行うモーダルです。
class PageEditModal extends StatefulWidget {
  /// ページリスト
  final List<PageEntity> pages;

  /// 最大ページ数（購入状態に応じて3、10、20のいずれか）
  final int maxPageCount;

  /// 保存時のコールバック
  final ValueChanged<List<PageEntity>> onSave;

  /// コンストラクタ
  const PageEditModal({
    super.key,
    required this.pages,
    required this.maxPageCount,
    required this.onSave,
  });

  @override
  State<PageEditModal> createState() => _PageEditModalState();
}

class _PageEditModalState extends State<PageEditModal> {
  late List<PageEntity> _pages;
  final Map<String, TextEditingController> _controllers = {};
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    // 最大ページ数までに制限
    _pages = List.from(widget.pages.take(widget.maxPageCount));
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
    // showModalBottomSheetのbuilderで提供されたcontextを使用
    // このcontextはモーダル用のNavigatorを参照している
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - statusBarHeight;
    final modalHeight = availableHeight * 0.95; // 高さを95%に増やす

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            // 下方向へのドラッグのみを検出
            if (details.delta.dy > 0) {
              setState(() {
                _dragOffset += details.delta.dy;
              });
            }
          },
          onVerticalDragEnd: (details) {
            // ドラッグ距離が一定以上の場合、モーダルを閉じる
            if (_dragOffset > 100) {
              Navigator.of(context).pop();
            } else {
              // ドラッグ距離が小さい場合は元に戻す
              setState(() {
                _dragOffset = 0.0;
              });
            }
          },
          child: Transform.translate(
            offset: Offset(0, _dragOffset > 0 ? _dragOffset : 0),
            child: SizedBox(
              height: modalHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    // ヘッダー
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor,
                            width: 1,
                          ),
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
                                onPressed: () {
                                  // showModalBottomSheetのbuilderで提供されたcontextを使用
                                  // このcontextはモーダル用のNavigatorを参照している
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: theme.iconTheme.color,
                                ),
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
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ボディ
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ReorderableListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              onReorder: (oldIndex, newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) {
                                    newIndex -= 1;
                                  }
                                  final item = _pages.removeAt(oldIndex);
                                  _pages.insert(newIndex, item);
                                });
                              },
                              buildDefaultDragHandles: false,
                              padding: EdgeInsets.zero,
                              children: _pages.asMap().entries.map((entry) {
                                return _PageEditCard(
                                  key: ValueKey(entry.value.id),
                                  page: entry.value,
                                  controller: _controllers[entry.value.id]!,
                                  index: entry.key,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // アップグレードセクション
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 0,
                        bottom: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: theme.dividerColor,
                              width: 1,
                            ),
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ページ編集カード
class _PageEditCard extends StatefulWidget {
  /// ページ
  final PageEntity page;

  /// テキストコントローラー
  final TextEditingController controller;

  /// インデックス
  final int index;

  /// コンストラクタ
  const _PageEditCard({
    super.key,
    required this.page,
    required this.controller,
    required this.index,
  });

  @override
  State<_PageEditCard> createState() => _PageEditCardState();
}

class _PageEditCardState extends State<_PageEditCard> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.3) // ダークモード：はっきりとした黒エリア
            : theme.scaffoldBackgroundColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // 入力欄（左90%）
          Expanded(
            flex: 9,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                border: isDark
                    ? InputBorder.none
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                          width: 1,
                        ),
                      ),
                enabledBorder: isDark
                    ? InputBorder.none
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                          width: 1,
                        ),
                      ),
                focusedBorder: isDark
                    ? InputBorder.none
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                filled: isDark,
                fillColor: isDark
                    ? _isFocused
                          ? Colors.black.withOpacity(0.6) // フォーカス時：より濃く
                          : Colors.black.withOpacity(0.5) // ダークモード：周りより暗く
                    : null,
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
            child: GestureDetector(
              onLongPressStart: (_) {
                // ドラッグ開始時にフォーカスを解除
                // これにより ReorderableListView のジェスチャー認識が正常に動作する
                FocusScope.of(context).unfocus();
              },
              child: ReorderableDragStartListener(
                index: widget.index,
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
            ),
          ),
        ],
      ),
    );
  }
}
