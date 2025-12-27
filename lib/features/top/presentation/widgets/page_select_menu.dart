import 'package:flutter/material.dart';
import '../../domain/page_entity.dart';

/// ページ選択メニュー
///
/// ページを選択するためのポップアップメニューです。
class PageSelectMenu extends StatelessWidget {
  /// 現在のページID
  final String currentPageId;

  /// すべてのページ
  final List<PageEntity> pages;

  /// ページ選択時のコールバック
  final ValueChanged<PageEntity> onPageSelected;

  /// ページ編集を開くコールバック
  final VoidCallback onEditPages;

  /// コンストラクタ
  const PageSelectMenu({
    super.key,
    required this.currentPageId,
    required this.pages,
    required this.onPageSelected,
    required this.onEditPages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ページリスト
            ...pages.map((page) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  onPageSelected(page);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        page.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: page.id == currentPageId
                              ? Colors.blue
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: page.id == currentPageId
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // 区切り（隙間を開ける）
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // ページの編集
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                onEditPages();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      'ページの編集',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
