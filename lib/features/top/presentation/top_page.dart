import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../application/top_state.dart';
import 'widgets/content_header.dart';
import 'input_page.dart';
import '../../../ads/banner_ad_widget.dart';
import '../../../core/constants/app_constants.dart';

/// トップページ
///
/// アプリのメイン画面です。
/// テキスト入力、コピー、削除などの機能を提供します。
class TopPage extends StatefulWidget {
  /// コンストラクタ
  const TopPage({super.key});

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  final TopState _state = TopState();
  late final TextEditingController _controller;
  bool _showHeader = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _state.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 入力エリアをタップした際の処理
  void _onInputTap() {
    setState(() {
      _showHeader = false;
    });
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => InputPage(
              state: _state,
              onTextChanged: (text) {
                _state.updateText(text);
              },
            ),
          ),
        )
        .then((_) {
          setState(() {
            _showHeader = true;
            _controller.text = _state.text;
          });
        });
  }

  /// テキストをコピー
  void _copyText() {
    if (_state.text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _state.text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('コピーしました'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// テキストを削除
  void _deleteText() {
    setState(() {
      _state.clearText();
      _controller.clear();
    });
  }

  /// 設定画面を開く（仮実装）
  void _openSettings() {
    setState(() {
      _state.hideSettingsBadge();
    });
    // TODO: 設定画面を実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('設定画面（未実装）'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // ヘッダー
          if (_showHeader)
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: AppConstants.horizontalPadding,
                right: AppConstants.horizontalPadding,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 設定アイコン
                  Stack(
                    children: [
                      IconButton(
                        onPressed: _openSettings,
                        icon: const Icon(Icons.settings),
                        iconSize: 28,
                      ),
                      // 未読バッジ
                      if (_state.showSettingsBadge)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          // コンテンツヘッダー
          if (_showHeader)
            ContentHeader(
              currentPage: _state.currentPage,
              onPrevious: _state.currentPage > 1
                  ? () {
                      setState(() {
                        _state.updatePage(_state.currentPage - 1);
                      });
                    }
                  : null,
              onNext: () {
                setState(() {
                  _state.updatePage(_state.currentPage + 1);
                });
              },
            ),
          // メインコンテンツ
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // 入力エリア
                  GestureDetector(
                    onTap: _onInputTap,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        enabled: false,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'テキストを入力してください...',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 文字数・タグ数カウント
                  Row(
                    children: [
                      Text(
                        '文字数: ${_state.characterCount}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'タグ数: ${_state.tagCount}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // コピーボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _state.text.isEmpty ? null : _copyText,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[200],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'テキストをコピー',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 削除ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _state.text.isEmpty ? null : _deleteText,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[200],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '削除',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // ボトム広告
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
