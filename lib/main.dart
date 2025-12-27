import 'package:flutter/material.dart';
import 'features/top/presentation/top_page.dart';
import 'ads/ad_manager.dart';

/// アプリケーションのエントリーポイント
///
/// このファイルはFlutterアプリの起動点です。
/// 起動時に広告を表示し、その後トップページに遷移します。
void main() {
  runApp(const MyApp());
}

/// アプリケーションのルートWidget
///
/// MaterialAppを返し、アプリ全体のテーマとルーティングを管理します。
class MyApp extends StatelessWidget {
  /// コンストラクタ
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '改行くん',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

/// スプラッシュページ
///
/// 起動時に広告を表示し、その後トップページに遷移します。
class SplashPage extends StatefulWidget {
  /// コンストラクタ
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _adShown = false;

  @override
  void initState() {
    super.initState();
    _showAd();
  }

  /// 広告を表示
  void _showAd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AdManager.showRandomAd(context, () {
          if (mounted) {
            setState(() {
              _adShown = true;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_adShown) {
      return const TopPage();
    }

    // 広告表示中はスプラッシュ画面を表示
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.text_fields, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              '改行くん',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
