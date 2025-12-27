import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_card.dart';
import 'widgets/recommended_apps_section.dart';

/// 設定画面
///
/// アプリの設定や各種機能へのアクセスを提供する画面です。
/// ダークモード/ライトモードに応じてデザインが自動的に変更されます。
class SettingsPage extends StatefulWidget {
  /// コンストラクタ
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// おすすめアプリのカードAを非表示にするかどうか
  bool _hideRecommendedCardA = false;

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
                        // TODO: アップグレード処理
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
                        // TODO: レビュー処理
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
}
