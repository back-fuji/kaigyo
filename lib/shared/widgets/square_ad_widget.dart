import 'package:flutter/material.dart';

/// 正方形広告Widget（ダミー）
///
/// モーダル内に表示する正方形の広告です。
/// 後からAdMob等の広告SDKに差し替えやすい構造になっています。
class SquareAdWidget extends StatelessWidget {
  /// コンストラクタ
  const SquareAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.ads_click, size: 32, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            '正方形広告（ダミー）',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
