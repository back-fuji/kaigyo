import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_card.dart';
import 'widgets/recommended_apps_section.dart';
import 'widgets/upgrade_modal.dart';
import '../domain/purchase_repository.dart';

/// 設定画面
///
/// アプリの設定や各種機能へのアクセスを提供する画面です。
/// ダークモード/ライトモードに応じてデザインが自動的に変更されます。
class SettingsPage extends StatefulWidget {
  /// 購入リポジトリ
  final PurchaseRepository purchaseRepository;

  /// コンストラクタ
  const SettingsPage({super.key, required this.purchaseRepository});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// おすすめアプリのカードAを非表示にするかどうか
  bool _hideRecommendedCardA = false;

  /// 購入リポジトリ
  PurchaseRepository get _purchaseRepository => widget.purchaseRepository;

  @override
  void initState() {
    super.initState();
    // ステータスバーの色を設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUI();
    });
  }

  /// システムUI（ステータスバー）の色を更新
  void _updateSystemUI() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100], // ダークモード対応
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            SettingsHeader(onBack: () => Navigator.of(context).pop()),
            // コンテンツエリア
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // アップグレード
                    _buildSectionTitle('アップグレード', isDark),
                    const SizedBox(height: 8),
                    SettingsCard(
                      icon: Icons.lock_open,
                      iconColor: Colors.red[300]!,
                      title: '改行くんをアップグレード',
                      onTap: () {
                        _showUpgradeModal();
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    // シェア
                    _buildSectionTitle('シェア', isDark),
                    const SizedBox(height: 8),
                    SettingsCard(
                      icon: Icons.share,
                      iconColor: Colors.green[300]!,
                      title: 'アプリを友達にすすめる',
                      onTap: () {
                        // TODO: シェア処理
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    // 評価・レビュー
                    _buildSectionTitle('評価・レビュー', isDark),
                    const SizedBox(height: 8),
                    SettingsCard(
                      icon: Icons.star,
                      iconColor: Colors.amber,
                      title: 'レビューを書いて応援する',
                      onTap: () {
                        _openStoreReview();
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    // ヘルプ
                    _buildSectionTitle('ヘルプ', isDark),
                    const SizedBox(height: 8),
                    SettingsCard(
                      icon: Icons.help_outline,
                      iconColor: Colors.blue[300]!,
                      title: 'よくある質問',
                      onTap: () {
                        // TODO: よくある質問処理
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    SettingsCard(
                      icon: Icons.email_outlined,
                      iconColor: Colors.blue[300]!,
                      title: 'お問い合わせ',
                      onTap: () {
                        // TODO: お問い合わせ処理
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    // おすすめのアプリ
                    _buildSectionTitle('おすすめのアプリ', isDark),
                    const SizedBox(height: 8),
                    RecommendedAppsSection(
                      hideCardA: _hideRecommendedCardA,
                      onDismissCardA: () {
                        setState(() {
                          _hideRecommendedCardA = true;
                        });
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    // デバッグ（開発用・一番下に配置・目立たないように）
                    if (kDebugMode) ...[
                      const SizedBox(height: 32),
                      Divider(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('デバッグ', isDark),
                      const SizedBox(height: 8),
                      SettingsCard(
                        icon: Icons.refresh,
                        iconColor: Colors.grey[400]!,
                        title: '購入データをリセット',
                        onTap: () async {
                          await _resetPurchaseData();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('購入データをリセットしました'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// セクションタイトルを構築
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[300] : Colors.grey[700],
      ),
    );
  }

  /// アップグレードモーダルを表示
  void _showUpgradeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          UpgradeModal(purchaseRepository: _purchaseRepository),
    );
  }

  /// 購入データをリセット
  Future<void> _resetPurchaseData() async {
    await _purchaseRepository.setAdRemovedPurchased(false);
    await _purchaseRepository.setPageLimit10Purchased(false);
    await _purchaseRepository.setPageLimit20Purchased(false);
  }

  /// ストアのレビュー画面を開く
  Future<void> _openStoreReview() async {
    try {
      final Uri storeUri;
      if (Platform.isIOS) {
        // iOS: App Storeのレビューを書く画面に直接遷移
        // App Store IDが設定されていない場合はエラーメッセージを表示
        if (AppConstants.iosAppStoreId == 'YOUR_APP_STORE_ID') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('App Store IDが設定されていません'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
        storeUri = Uri.parse(
          'https://apps.apple.com/app/id${AppConstants.iosAppStoreId}?action=write-review',
        );
      } else {
        // Android: Google Play Storeのアプリ詳細ページに遷移
        storeUri = Uri.parse(
          'https://play.google.com/store/apps/details?id=${AppConstants.androidPackageName}',
        );
      }

      if (await canLaunchUrl(storeUri)) {
        await launchUrl(storeUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ストアを開けませんでした'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('エラーが発生しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
