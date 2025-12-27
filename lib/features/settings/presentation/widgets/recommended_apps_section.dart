import 'package:flutter/material.dart';

/// おすすめのアプリセクション
///
/// 角丸白枠エリア内に複数のアプリカードを表示します。
class RecommendedAppsSection extends StatelessWidget {
  /// カードAを非表示にするかどうか
  final bool hideCardA;

  /// カードAを閉じるコールバック
  final VoidCallback onDismissCardA;

  /// ダークモードかどうか
  final bool isDark;

  /// コンストラクタ
  const RecommendedAppsSection({
    super.key,
    required this.hideCardA,
    required this.onDismissCardA,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        children: [
          // カードA（ニューリリース）
          if (!hideCardA) ...[_buildCardA(isDark), const SizedBox(height: 12)],
          // カードB（InstaPlan）
          _buildCardB(isDark),
        ],
      ),
    );
  }

  /// カードA（ニューリリース）を構築
  Widget _buildCardA(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // 左側：雷マークアイコン
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 12),
              // 右側：テキスト
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ニューリリース',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '改行くんの開発者が作った新しいアプリです！',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 右上：閉じるボタン
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: onDismissCardA,
              icon: Icon(
                Icons.close,
                size: 20,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  /// カードB（InstaPlan）を構築
  Widget _buildCardB(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 左側：アイコン（ここでは例としてアプリアイコンを表示）
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          // 右側：テキストとApp Storeボタン
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 上段：InstaPlan - Feed Preview
                Text(
                  'InstaPlan - Feed Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // 中段：説明
                Text(
                  'Instagramの計画投稿アプリ',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                // 下段：App Store で見るボタン
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.cyan[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'App Store で見る',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.cyan[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
