import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// 全画面広告Widget（ダミー）
///
/// 一定時間（5秒）経過後に×ボタンで閉じられる全画面広告です。
/// 後からAdMob等の広告SDKに差し替えやすい構造になっています。
class FullscreenAdWidget extends StatefulWidget {
  /// 広告を閉じた際のコールバック
  final VoidCallback onClose;

  /// コンストラクタ
  const FullscreenAdWidget({super.key, required this.onClose});

  @override
  State<FullscreenAdWidget> createState() => _FullscreenAdWidgetState();
}

class _FullscreenAdWidgetState extends State<FullscreenAdWidget> {
  bool _canClose = false;
  int _remainingSeconds = AppConstants.fullscreenAdDisplaySeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  /// カウントダウンを開始
  void _startCountdown() {
    Future.delayed(
      const Duration(seconds: AppConstants.fullscreenAdDisplaySeconds),
      () {
        if (mounted) {
          setState(() {
            _canClose = true;
          });
        }
      },
    );

    // 残り秒数を更新
    _updateRemainingSeconds();
  }

  /// 残り秒数を更新
  void _updateRemainingSeconds() {
    if (_remainingSeconds > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
          if (_remainingSeconds > 0) {
            _updateRemainingSeconds();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_canClose) {
          widget.onClose();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: Stack(
          children: [
            // 広告コンテンツ（ダミー）
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.ads_click, size: 80, color: Colors.white),
                  const SizedBox(height: 24),
                  const Text(
                    '広告（ダミー）',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '残り $_remainingSeconds秒',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            // 閉じるボタン
            if (_canClose)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: const CircleBorder(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
