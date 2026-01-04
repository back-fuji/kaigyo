import 'package:flutter/material.dart';
import 'action_modal.dart';

/// 削除モーダル
///
/// テキスト削除の確認を表示するモーダルです。
class DeleteModal extends StatelessWidget {
  /// 削除を実行するコールバック
  final VoidCallback? onDelete;

  /// キャンセルコールバック
  final VoidCallback? onCancel;

  /// 広告を表示するかどうか
  final bool showAd;

  /// コンストラクタ
  const DeleteModal({
    super.key,
    this.onDelete,
    this.onCancel,
    this.showAd = true,
  });

  @override
  Widget build(BuildContext context) {
    return ActionModal(
      iconBackgroundColor: Colors.yellow,
      icon: Icons.priority_high,
      iconColor: Colors.grey[800]!,
      showSquareAd: showAd,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          // 「確認」
          const Text(
            '確認',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // 「テキストを削除しますか？」
          const Text(
            'テキストを削除しますか？',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      buttons: [
        // 削除ボタン
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDelete?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            '削除',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // キャンセルボタン
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'キャンセル',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
