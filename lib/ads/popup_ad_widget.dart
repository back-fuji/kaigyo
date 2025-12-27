import 'package:flutter/material.dart';

/// ポップアップ型広告Widget（ダミー）
///
/// 即座に閉じられるポップアップ型広告です。
/// 後からAdMob等の広告SDKに差し替えやすい構造になっています。
class PopupAdWidget extends StatelessWidget {
  /// 広告を閉じた際のコールバック
  final VoidCallback onClose;

  /// コンストラクタ
  const PopupAdWidget({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 閉じるボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            // 広告コンテンツ（ダミー）
            const Icon(Icons.ads_click, size: 60, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              '広告（ダミー）',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'ポップアップ型広告',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // 閉じるボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('閉じる'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
