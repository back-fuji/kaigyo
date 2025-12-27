import 'package:flutter/material.dart';

/// コンテンツヘッダーWidget
///
/// ページナビゲーションを表示するヘッダーです。
/// 左：戻るボタン、中央：現在ページ数、右：次へボタン
class ContentHeader extends StatelessWidget {
  /// 現在のページ数
  final int currentPage;

  /// 戻るボタンのコールバック
  final VoidCallback? onPrevious;

  /// 次へボタンのコールバック
  final VoidCallback? onNext;

  /// コンストラクタ
  const ContentHeader({
    super.key,
    required this.currentPage,
    this.onPrevious,
    this.onNext,
  });

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
            onPressed: onPrevious,
            icon: Icon(
              Icons.arrow_back_ios,
              color: onPrevious != null ? Colors.black : Colors.grey,
            ),
            disabledColor: Colors.grey,
          ),
          // ページ数表示（灰色ボックスの中に濃い灰色の文字）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'page$currentPage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          // 次へボタン
          IconButton(
            onPressed: onNext,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: onNext != null ? Colors.black : Colors.grey,
            ),
            disabledColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}
