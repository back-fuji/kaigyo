import 'package:flutter/material.dart';
import '../../domain/page_entity.dart';
import 'page_select_menu.dart';

/// コンテンツヘッダーWidget
///
/// ページナビゲーションを表示するヘッダーです。
/// 左：戻るボタン、中央：現在ページ数、右：次へボタン
class ContentHeader extends StatefulWidget {
  /// 現在のページ
  final PageEntity currentPage;

  /// すべてのページ
  final List<PageEntity> pages;

  /// 戻るボタンのコールバック
  final VoidCallback? onPrevious;

  /// 次へボタンのコールバック
  final VoidCallback? onNext;

  /// ページ選択時のコールバック
  final ValueChanged<PageEntity>? onPageSelected;

  /// ページ編集を開くコールバック
  final VoidCallback? onEditPages;

  /// ページボタンタップ時のコールバック（フォーカス保持用）
  final VoidCallback? onPageButtonTap;

  /// コンストラクタ
  const ContentHeader({
    super.key,
    required this.currentPage,
    required this.pages,
    this.onPrevious,
    this.onNext,
    this.onPageSelected,
    this.onEditPages,
    this.onPageButtonTap,
  });

  @override
  State<ContentHeader> createState() => _ContentHeaderState();
}

class _ContentHeaderState extends State<ContentHeader> {
  final GlobalKey _pageButtonKey = GlobalKey();

  /// ページ選択メニューを表示
  void _showPageSelectMenu(BuildContext context) {
    if (widget.onPageSelected == null || widget.onEditPages == null) return;

    // フォーカスを保持するためにコールバックを呼ぶ
    widget.onPageButtonTap?.call();

    // page1ボタンの位置を取得
    final RenderBox? buttonBox =
        _pageButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;

    final buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final buttonSize = buttonBox.size;
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = screenWidth * 0.55;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        // ダイアログが表示された後にフォーカスを再設定
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onPageButtonTap?.call();
        });
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // 背景をタップして閉じる
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: Container(color: Colors.transparent),
                ),
              ),
              // メニューをpage1ボタンの下に配置（隣接）
              Positioned(
                left: (screenWidth - menuWidth) / 2, // 中央揃え
                top: buttonPosition.dy + buttonSize.height, // page1ボタンのすぐ下に隣接
                child: PageSelectMenu(
                  currentPageId: widget.currentPage.id,
                  pages: widget.pages,
                  onPageSelected: (page) {
                    Navigator.of(dialogContext).pop();
                    widget.onPageSelected!(page);
                  },
                  onEditPages: () {
                    Navigator.of(dialogContext).pop();
                    widget.onEditPages!();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 戻るボタン
          IconButton(
            onPressed: widget.onPrevious,
            icon: Icon(
              Icons.arrow_back_ios,
              color: widget.onPrevious != null ? Colors.black : Colors.grey,
            ),
            disabledColor: Colors.grey,
          ),
          // ページ数表示（タップ可能）
          GestureDetector(
            onTap: () => _showPageSelectMenu(context),
            child: Container(
              key: _pageButtonKey,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.grey[300]!, width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.currentPage.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          // 次へボタン
          IconButton(
            onPressed: widget.onNext,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: widget.onNext != null ? Colors.black : Colors.grey,
            ),
            disabledColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}
