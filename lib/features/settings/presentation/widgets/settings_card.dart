import 'package:flutter/material.dart';

/// 設定項目のカード
///
/// アイコン、タイトル、右向き矢印を表示するカードです。
class SettingsCard extends StatelessWidget {
  /// アイコン
  final IconData icon;

  /// アイコンの色
  final Color iconColor;

  /// タイトル
  final String title;

  /// タップ時のコールバック
  final VoidCallback onTap;

  /// ダークモードかどうか
  final bool isDark;

  /// コンストラクタ
  const SettingsCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isDark
              ? null
              : Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Row(
          children: [
            // アイコン
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            // タイトル
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            // 右向き矢印
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
