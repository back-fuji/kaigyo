import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// TODO: 以下のimportを有効化するには、pubspec.yamlにin_app_purchaseパッケージを追加してください
// import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../shared/widgets/action_modal.dart';
import '../../domain/purchase_repository.dart';

/// アップグレードモーダル
///
/// アプリ内課金の購入オプションを表示するモーダルです。
/// 下からスライドインして表示されます。
class UpgradeModal extends StatefulWidget {
  /// 購入リポジトリ
  final PurchaseRepository purchaseRepository;

  /// コンストラクタ
  const UpgradeModal({super.key, required this.purchaseRepository});

  @override
  State<UpgradeModal> createState() => _UpgradeModalState();
}

class _UpgradeModalState extends State<UpgradeModal> {
  /// 購入リポジトリ
  PurchaseRepository get _purchaseRepository => widget.purchaseRepository;

  // TODO: 以下の行を有効化するには、pubspec.yamlにin_app_purchaseパッケージを追加してください
  // /// InAppPurchaseインスタンス
  // final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // /// 購入更新のストリームサブスクリプション
  // StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// 広告非表示の購入状態
  bool _isAdRemovedPurchased = false;

  /// ページ数上限増加（3→10）の購入状態
  bool _isPageLimit10Purchased = false;

  /// ページ数上限増加（10→20）の購入状態
  bool _isPageLimit20Purchased = false;

  /// 読み込み中かどうか
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchaseStatus();
    // TODO: 以下のコードを有効化するには、pubspec.yamlにin_app_purchaseパッケージを追加してください
    // _subscription = _inAppPurchase.purchaseStream.listen(
    //   _onPurchaseUpdate,
    //   onDone: () => _subscription?.cancel(),
    //   onError: (error) => debugPrint('Purchase stream error: $error'),
    // );
  }

  @override
  void dispose() {
    // TODO: 以下のコードを有効化するには、pubspec.yamlにin_app_purchaseパッケージを追加してください
    // _subscription?.cancel();
    super.dispose();
  }

  /// 購入状態を読み込む
  Future<void> _loadPurchaseStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adRemoved = await _purchaseRepository.isAdRemovedPurchased();
      final pageLimit10 = await _purchaseRepository.isPageLimit10Purchased();
      final pageLimit20 = await _purchaseRepository.isPageLimit20Purchased();

      if (mounted) {
        setState(() {
          _isAdRemovedPurchased = adRemoved;
          _isPageLimit10Purchased = pageLimit10;
          _isPageLimit20Purchased = pageLimit20;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 購入更新のハンドラー
  ///
  /// このメソッドは、in_app_purchaseパッケージを追加した後に有効化してください。
  /// 購入ストリームから購入更新を受け取り、購入状態を更新します。
  // Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
  //   for (final purchase in purchases) {
  //     if (purchase.status == PurchaseStatus.purchased ||
  //         purchase.status == PurchaseStatus.restored) {
  //       // 購入成功または復元成功
  //       await _handlePurchaseSuccess(purchase.productID);
  //     } else if (purchase.status == PurchaseStatus.error) {
  //       // 購入エラー
  //       if (mounted) {
  //         _showPurchaseFailedModal();
  //       }
  //     }
  //     // 購入を完了としてマーク
  //     if (purchase.pendingCompletePurchase) {
  //       await _inAppPurchase.completePurchase(purchase);
  //     }
  //   }
  // }

  /// 購入成功時の処理
  Future<void> _handlePurchaseSuccess(String productId) async {
    debugPrint('Purchase success: $productId');
    switch (productId) {
      case 'remove_ads':
        await _purchaseRepository.setAdRemovedPurchased(true);
        debugPrint('Set ad removed: true');
        break;
      case 'page_limit_10':
        await _purchaseRepository.setPageLimit10Purchased(true);
        debugPrint('Set page limit 10: true');
        break;
      case 'page_limit_20':
        await _purchaseRepository.setPageLimit20Purchased(true);
        debugPrint('Set page limit 20: true');
        break;
      default:
        debugPrint('Unknown product ID: $productId');
    }
    if (mounted) {
      await _loadPurchaseStatus();
    }
  }

  /// 購入処理
  ///
  /// テスト用: クリックしたら即座に購入成功として扱います
  /// 本番環境では、in_app_purchaseパッケージを追加した後に実装を置き換えてください。
  Future<void> _purchase(String productId) async {
    debugPrint('Purchase called with productId: $productId');
    // テスト用: 即座に購入成功として扱う
    // 指定されたproductIdのみを購入済みにする
    await _handlePurchaseSuccess(productId);

    // TODO: 本番環境では以下のコードを有効化してください
    // TODO: 以下の実装を有効化するには、pubspec.yamlにin_app_purchaseパッケージを追加してください
    //
    // try {
    //   // 購入が利用可能かチェック
    //   final bool available = await _inAppPurchase.isAvailable();
    //   if (!available) {
    //     if (mounted) {
    //       _showPurchaseFailedModal();
    //     }
    //     return;
    //   }
    //
    //   // 商品情報を取得
    //   final ProductDetailsResponse response =
    //       await _inAppPurchase.queryProductDetails({productId});
    //
    //   if (response.error != null) {
    //     // エラーが発生した場合
    //     if (mounted) {
    //       _showPurchaseFailedModal();
    //     }
    //     return;
    //   }
    //
    //   if (response.productDetails.isEmpty) {
    //     // 商品が見つからない場合
    //     debugPrint('Product not found: $productId');
    //     if (mounted) {
    //       _showPurchaseFailedModal();
    //     }
    //     return;
    //   }
    //
    //   // 購入を開始
    //   final ProductDetails productDetails = response.productDetails.first;
    //   final PurchaseParam purchaseParam = PurchaseParam(
    //     productDetails: productDetails,
    //   );
    //
    //   await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    //   // 購入結果は_onPurchaseUpdateで処理される
    // } catch (e) {
    //   debugPrint('Purchase error: $e');
    //   if (mounted) {
    //     _showPurchaseFailedModal();
    //   }
    // }

    // プレースホルダー：購入成功をシミュレート
    // 実際の実装では、購入APIの結果に応じて処理を分岐
    try {
      // TODO: 実際の購入APIの結果に置き換え
      // 現時点では常に失敗として扱う（デモ用）
      const bool purchaseSuccess = false;

      if (purchaseSuccess) {
        // 購入成功時は購入状態を更新
        await _handlePurchaseSuccess(productId);
      } else {
        // 購入キャンセル時は失敗モーダルを表示
        if (mounted) {
          _showPurchaseFailedModal();
        }
      }
    } catch (e) {
      // エラー時は失敗モーダルを表示
      if (mounted) {
        _showPurchaseFailedModal();
      }
    }
  }

  /// 復元処理
  ///
  /// このメソッドは、in_app_purchaseパッケージを追加した後に実装を置き換えてください。
  /// 現在はプレースホルダーとして、常に成功として扱われています。
  Future<void> _restorePurchases() async {
    // TODO: 以下の実装を有効化するには、pubspec.yamlにin_app_purchaseパッケージを追加してください
    //
    // try {
    //   await _inAppPurchase.restorePurchases();
    //   // 復元結果は_onPurchaseUpdateで処理される
    //   if (mounted) {
    //     _showRestoreSuccessModal();
    //   }
    // } catch (e) {
    //   debugPrint('Restore error: $e');
    //   if (mounted) {
    //     _showRestoreSuccessModal(); // エラーでも成功モーダルを表示（UXのため）
    //   }
    // }

    // プレースホルダー：復元成功をシミュレート
    // 実際の実装では、復元APIの結果に応じて購入状態を更新
    try {
      // TODO: 実際の復元APIの結果に基づいて購入状態を更新
      // 例：
      // final restoredPurchases = await _inAppPurchase.restorePurchases();
      // for (final purchase in restoredPurchases) {
      //   if (purchase.productID == 'remove_ads') {
      //     await _purchaseRepository.setAdRemovedPurchased(true);
      //   }
      //   // ... 他の商品も同様に処理
      // }

      // 状態を再読み込み
      await _loadPurchaseStatus();

      // 復元成功モーダルを表示
      if (mounted) {
        _showRestoreSuccessModal();
      }
    } catch (e) {
      // エラー時も復元成功モーダルを表示（ユーザー体験のため）
      if (mounted) {
        _showRestoreSuccessModal();
      }
    }
  }

  /// 復元成功モーダルを表示
  void _showRestoreSuccessModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // チェックマークアイコン
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 40),
              ),
              const SizedBox(height: 24),
              // 「購入済みをアイテムを復元しました」
              const Text(
                '購入済みをアイテムを復元しました',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 購入失敗モーダルを表示
  void _showPurchaseFailedModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (context) {
        // 1秒後に自動で閉じる
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // バツボタン（大きめ、白色）
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 16),
                // 「購入に失敗しました😢」
                const Text(
                  '購入に失敗しました😢',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // 「Payment is cancelled」
                const Text(
                  'Payment is cancelled',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 購入不可時の情報モーダルを表示
  void _showCannotPurchaseModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => ActionModal(
        iconBackgroundColor: const Color(0xFF0000CD), // #0000cd
        icon: Icons.info,
        iconColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // 「このアイテムは購入できません」
            const Text(
              'このアイテムは購入できません',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        showSquareAd: false,
        buttons: [
          // 閉じるボタン
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ヘッダー
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 左：復元ボタン
                TextButton(
                  onPressed: _restorePurchases,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('復元', style: TextStyle(fontSize: 16)),
                ),
                // 中央：「改行くんをアップグレード」（白文字）
                Expanded(
                  child: Text(
                    '改行くんをアップグレード',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // 右：バツボタン（黒）
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // 少しのPadding
          const SizedBox(height: 8),
          // コンテンツ
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 「※いずれも月額ではなく買い切りです」
                        Center(
                          child: Text(
                            '※いずれも月額ではなく買い切りです',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // カード1：すべての広告を非表示にする
                        _buildPurchaseCard(
                          title: 'すべての広告を非表示にする',
                          description: 'アプリ内のすべての広告を非表示にします',
                          price: '￥300',
                          isPurchased: _isAdRemovedPurchased,
                          canPurchase: true,
                          onTap: () {
                            if (_isAdRemovedPurchased) return;
                            _purchase('remove_ads');
                          },
                          leftWidthRatio: 0.8,
                          isDark: isDark,
                        ),
                        // カード2：ページ数の上限を増やす
                        _buildPurchaseCard(
                          title: 'ページ数の上限を増やす',
                          description: 'テキストを保存できるページの数を3ページから10ページに増やします',
                          price: '￥300',
                          isPurchased: _isPageLimit10Purchased,
                          canPurchase: true,
                          onTap: () {
                            if (_isPageLimit10Purchased) return;
                            _purchase('page_limit_10');
                          },
                          leftWidthRatio: 0.8,
                          isDark: isDark,
                        ),
                        // カード3：ページ数の上限をさらに増やす
                        _buildPurchaseCard(
                          title: 'ページ数の上限をさらに増やす',
                          description: 'テキストを保存できるページの数を10ページから20ページに増やします',
                          price: '￥300',
                          isPurchased: _isPageLimit20Purchased,
                          canPurchase:
                              _isPageLimit10Purchased, // 2個目が購入されていないと購入不可
                          onTap: () {
                            if (!_isPageLimit10Purchased) {
                              _showCannotPurchaseModal();
                              return;
                            }
                            if (_isPageLimit20Purchased) return;
                            _purchase('page_limit_20');
                          },
                          leftWidthRatio: 0.55,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// 購入カードを構築
  Widget _buildPurchaseCard({
    required String title,
    required String description,
    required String price,
    required bool isPurchased,
    required bool canPurchase,
    required VoidCallback onTap,
    required double leftWidthRatio,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              // 左側
              Expanded(
                flex: (leftWidthRatio * 100).round(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: canPurchase && !isPurchased ? 16 : 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 説明
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // 右側
              Expanded(
                flex: ((1 - leftWidthRatio) * 100).round(),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildPriceWidget(
                    price: price,
                    isPurchased: isPurchased,
                    canPurchase: canPurchase,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 価格ウィジェットを構築
  Widget _buildPriceWidget({
    required String price,
    required bool isPurchased,
    required bool canPurchase,
    required bool isDark,
  }) {
    if (isPurchased) {
      // 購入済み
      return Text(
        '購入済み',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
    } else if (!canPurchase) {
      // 購入不可
      return Text('購入できません', style: TextStyle(fontSize: 14, color: Colors.red));
    } else {
      // 購入可能（￥300）
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      );
    }
  }
}
