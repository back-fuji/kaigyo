import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'action_modal.dart';

/// コピーモーダル
///
/// テキストコピー時の成功/失敗を表示するモーダルです。
class CopyModal extends StatelessWidget {
  /// テキストが入力されているかどうか
  final bool hasText;

  /// Instagramを開くコールバック
  final VoidCallback? onOpenInstagram;

  /// 閉じるコールバック
  final VoidCallback? onClose;

  /// 広告を表示するかどうか
  final bool showAd;

  /// コンストラクタ
  const CopyModal({
    super.key,
    required this.hasText,
    this.onOpenInstagram,
    this.onClose,
    this.showAd = true,
  });

  /// Instagramを開く
  Future<void> _openInstagram() async {
    try {
      // InstagramアプリのURLスキーム
      final instagramUri = Uri.parse('instagram://');

      // まずInstagramアプリを開くことを試みる
      try {
        await launchUrl(instagramUri, mode: LaunchMode.externalApplication);
        return;
      } catch (e) {
        // Instagramアプリがインストールされていない場合はストアを開く
      }

      // プラットフォームに応じてストアURLを選択
      final storeUri = Platform.isIOS
          ? Uri.parse('https://apps.apple.com/app/instagram/id389801252')
          : Uri.parse(
              'https://play.google.com/store/apps/details?id=com.instagram.android',
            );

      if (await canLaunchUrl(storeUri)) {
        await launchUrl(storeUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // エラーが発生した場合は何もしない
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasText) {
      // テキストが入力されている場合：成功モーダル
      return ActionModal(
        iconBackgroundColor: const Color(0xFF3cb371), // ライムグリーン #3cb371
        icon: Icons.check,
        iconColor: Colors.white,
        showSquareAd: showAd,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // 「コピーしました」
            const Text(
              'コピーしました',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 「投稿アプリに貼り付けてご利用ください」
            const Text(
              '投稿アプリに貼り付けてご利用ください',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // 注意書き
            Text(
              '※ 投稿アプリの文字数制限や行動制限により貼り付けられないことがあります',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        buttons: [
          // Instagramを開くボタン
          ElevatedButton(
            onPressed: () {
              _openInstagram();
              onOpenInstagram?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3cb371), // ライムグリーン #3cb371
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Instagramを開く',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // 閉じるボタン
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onClose?.call();
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
              '閉じる',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    } else {
      // テキストが入力されていない場合：エラーモーダル
      return ActionModal(
        iconBackgroundColor: Colors.yellow,
        icon: Icons.priority_high,
        iconColor: Colors.grey[800]!,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // 「テキストを入力してください」
            const Text(
              'テキストを入力してください',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        showSquareAd: false,
        buttons: [
          // 閉じるボタン
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onClose?.call();
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
              '閉じる',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }
  }
}
