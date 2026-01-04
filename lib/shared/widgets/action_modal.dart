import 'package:flutter/material.dart';
import 'square_ad_widget.dart';

/// アクションモーダル
///
/// 再利用可能なモーダルコンポーネントです。
/// アイコン、コンテンツ、ボタンをカスタマイズ可能です。
class ActionModal extends StatelessWidget {
  /// アイコンの背景色
  final Color iconBackgroundColor;

  /// アイコン
  final IconData icon;

  /// アイコンの色
  final Color iconColor;

  /// カードの背景色（デフォルトは白）
  final Color cardColor;

  /// コンテンツWidget
  final Widget content;

  /// ボタンWidgetのリスト
  final List<Widget> buttons;

  /// 正方形広告を表示するかどうか
  final bool showSquareAd;

  /// アイコンの背景色を表示するかどうか（デフォルトはtrue）
  final bool showIconBackground;

  /// コンストラクタ
  const ActionModal({
    super.key,
    required this.iconBackgroundColor,
    required this.icon,
    required this.iconColor,
    this.cardColor = Colors.white,
    required this.content,
    required this.buttons,
    this.showSquareAd = true,
    this.showIconBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    // アイコンの半径（30px）
    const iconRadius = 30.0;
    // アイコン周りのパディング（4px）
    const iconPadding = 4.0;
    // 外側の白い円の半径
    final outerRadius = iconRadius + iconPadding;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // カード部分
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: EdgeInsets.only(top: outerRadius),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // アイコンの下半分が表示されるためのスペース
                SizedBox(height: outerRadius),
                // コンテンツエリア
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: content,
                ),
                // 正方形広告
                if (showSquareAd) ...[
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: SquareAdWidget(),
                  ),
                ],
                // ボタンエリア
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      for (int i = 0; i < buttons.length; i++) ...[
                        SizedBox(width: double.infinity, child: buttons[i]),
                        if (i < buttons.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // アイコン（透明領域とカードの境界に配置）
          Positioned(
            top: 0,
            child: Container(
              width: outerRadius * 2,
              height: outerRadius * 2,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(iconPadding),
              child: showIconBackground
                  ? Container(
                      width: iconRadius * 2,
                      height: iconRadius * 2,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 30),
                    )
                  : Icon(icon, color: iconColor, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
