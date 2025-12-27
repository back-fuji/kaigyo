import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../application/top_state.dart';
import 'widgets/content_header.dart';
import '../../../ads/banner_ad_widget.dart';
import '../../../core/constants/app_constants.dart';

/// 入力専用ページ
///
/// テキスト入力に集中するためのページです。
/// ContentHeaderの下に横バー型広告を表示します。
class InputPage extends StatefulWidget {
  /// トップページの状態
  final TopState state;

  /// テキスト更新のコールバック
  final ValueChanged<String> onTextChanged;

  /// コンストラクタ
  const InputPage({
    super.key,
    required this.state,
    required this.onTextChanged,
  });

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.text);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onTextChanged(_controller.text);
    // UIを更新するためにsetStateを呼ぶ
    setState(() {
      // widget.stateは既にonTextChanged内で更新されている
    });
  }

  /// テキストをコピー
  void _copyText() {
    if (widget.state.text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: widget.state.text));
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
      widget.state.clearText();
      _controller.clear();
    });
  }

  /// 最終更新時刻をフォーマット
  String _formatLastUpdated() {
    if (widget.state.lastUpdatedAt == null) {
      return '最終更新 --';
    }
    final date = widget.state.lastUpdatedAt!;
    return '最終更新 ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: SafeArea(
          child: Column(
            children: [
              // ContentHeader（全幅）
              ContentHeader(
                currentPage: widget.state.currentPage,
                onPrevious: widget.state.currentPage > 1
                    ? () {
                        setState(() {
                          widget.state.updatePage(widget.state.currentPage - 1);
                        });
                      }
                    : null,
                onNext: () {
                  setState(() {
                    widget.state.updatePage(widget.state.currentPage + 1);
                  });
                },
              ),
              // 横バー型広告（全幅）
              const BannerAdWidget(),
              // 入力エリアとボタンエリア（左右に隙間を設ける）
              Expanded(
                child: Row(
                  children: [
                    // 左の隙間（タップで戻る）
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: AppConstants.horizontalPadding,
                        color: Colors.transparent,
                      ),
                    ),
                    // メインコンテンツ
                    Expanded(
                      child: Column(
                        children: [
                          // 入力エリア
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.horizontalPadding,
                                vertical: 16,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _controller,
                                  maxLines: null,
                                  expands: true,
                                  decoration: const InputDecoration(
                                    filled: false,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                  autofocus: true,
                                ),
                              ),
                            ),
                          ),
                          // 情報表示エリア（最終更新時刻と文字数・タグ数）
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.horizontalPadding,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 左側：最終更新時刻
                                Text(
                                  _formatLastUpdated(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                // 右側：文字数・タグ数
                                Row(
                                  children: [
                                    Text(
                                      '文字 ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '${widget.state.characterCount}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'タグ ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '${widget.state.tagCount}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // ボタンエリア
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.horizontalPadding,
                              vertical: 16,
                            ),
                            child: Column(
                              children: [
                                // コピーボタン
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: widget.state.text.isEmpty
                                        ? null
                                        : _copyText,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[200],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
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
                                    onPressed: widget.state.text.isEmpty
                                        ? null
                                        : _deleteText,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[200],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 右の隙間（タップで戻る）
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: AppConstants.horizontalPadding,
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
