import 'package:flutter/material.dart';

/// 設定画面のヘッダー
///
/// 左側に戻るボタン、中央に「設定」の文字を表示します。
class SettingsHeader extends StatelessWidget {
  /// 戻るボタンのコールバック
  final VoidCallback onBack;

  /// コンストラクタ
  const SettingsHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 左側：戻るボタン
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          // 中央：設定の文字
          Expanded(
            child: Center(
              child: Text(
                '設定',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          // 右側：スペーサー（中央揃えのため）
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
