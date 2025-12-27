import 'package:flutter/material.dart';

/// バナー型広告Widget（ダミー）
///
/// 画面下部やコンテンツ間に表示する横バー型広告です。
/// 後からAdMob等の広告SDKに差し替えやすい構造になっています。
class BannerAdWidget extends StatelessWidget {
  /// コンストラクタ
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border(
          top: BorderSide(color: Colors.grey[400]!),
          bottom: BorderSide(color: Colors.grey[400]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.ads_click, size: 24, color: Colors.grey),
          const SizedBox(width: 8),
          const Text(
            '広告（ダミー）',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
