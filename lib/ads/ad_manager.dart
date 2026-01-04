import 'dart:math';
import 'package:flutter/material.dart';
import '../features/settings/infrastructure/purchase_repository_impl.dart';
import 'fullscreen_ad_widget.dart';
import 'popup_ad_widget.dart';

/// 広告管理クラス
///
/// 広告の表示タイミングや種類を管理します。
/// セッション管理も行います。
class AdManager {
  static final Random _random = Random();
  static DateTime? _sessionStartTime;

  /// セッションを開始
  static void startSession() {
    _sessionStartTime = DateTime.now();
  }

  /// セッションが有効かどうかを確認
  ///
  /// セッション時間（3時間）を超えている場合は false を返します。
  static bool isSessionValid() {
    if (_sessionStartTime == null) {
      return false;
    }
    final now = DateTime.now();
    final difference = now.difference(_sessionStartTime!);
    return difference.inSeconds < 10800; // 3時間 = 10800秒
  }

  /// 広告を表示する必要があるかどうかを確認
  ///
  /// セッションが有効な場合は true を返します。
  /// 購入済みの場合は false を返します。
  static Future<bool> shouldShowAd() async {
    // 購入状態をチェック
    final purchaseRepository = PurchaseRepositoryImpl();
    final isAdRemoved = await purchaseRepository.isAdRemovedPurchased();
    if (isAdRemoved) {
      return false; // 広告非表示が購入済みの場合は広告を表示しない
    }

    if (_sessionStartTime == null) {
      startSession();
      return true;
    }
    return isSessionValid();
  }

  /// ランダムに広告を表示
  ///
  /// [context] BuildContext
  /// [onAdClosed] 広告が閉じられた際のコールバック
  static Future<void> showRandomAd(
    BuildContext context,
    VoidCallback onAdClosed,
  ) async {
    if (!await shouldShowAd()) {
      onAdClosed();
      return;
    }

    // ランダムに広告タイプを選択
    final adType = _random.nextInt(2);

    if (adType == 0) {
      // 全画面広告
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FullscreenAdWidget(
            onClose: () {
              Navigator.of(context).pop();
              onAdClosed();
            },
          ),
          fullscreenDialog: true,
        ),
      );
    } else {
      // ポップアップ広告
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopupAdWidget(
          onClose: () {
            Navigator.of(context).pop();
            onAdClosed();
          },
        ),
      );
    }
  }
}
