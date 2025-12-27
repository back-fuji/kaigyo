import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../application/top_state.dart';
import '../domain/page_entity.dart';
import '../domain/page_repository.dart';
import '../infrastructure/page_repository_impl.dart';
import 'widgets/content_header.dart';
import 'widgets/page_edit_modal.dart';
import '../../../ads/banner_ad_widget.dart';
import '../../../core/constants/app_constants.dart';
import '../../settings/presentation/settings_page.dart';

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
  final PageRepository _pageRepository = PageRepositoryImpl();
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _showHeader = true;
  List<PageEntity> _pages = [];
  PageEntity? _currentPage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _state.text);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
    // デフォルトのページを設定（読み込み完了まで表示）
    _currentPage = const PageEntity(id: 'page1', name: 'Page1', order: 0);
    _pages = [_currentPage!];
    _loadPages();
    // 初期状態のステータスバー色を設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUI();
    });
  }

  /// ページを読み込む
  Future<void> _loadPages() async {
    final pages = await _pageRepository.getAllPages();
    if (!mounted) return;
    setState(() {
      _pages = pages;
      _currentPage = pages.firstWhere(
        (p) => p.id == _state.currentPageId,
        orElse: () => pages.first,
      );
      _state.updatePageId(_currentPage!.id);
    });
    await _loadPageText();
  }

  /// 現在のページのテキストを読み込む
  Future<void> _loadPageText() async {
    if (_currentPage == null || !mounted) return;
    final text = await _pageRepository.getPageText(_currentPage!.id);
    if (!mounted) return;
    setState(() {
      _state.updateText(text);
      _controller.text = text;
    });
  }

  /// 現在のページのテキストを保存
  Future<void> _savePageText() async {
    if (_currentPage == null) return;
    await _pageRepository.savePageText(_currentPage!.id, _state.text);
  }

  @override
  void dispose() {
    _savePageText(); // 最終保存
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  /// フォーカス状態が変更された際の処理
  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _showHeader = !_focusNode.hasFocus;
    });
    // ステータスバーの色を更新
    _updateSystemUI();
  }

  /// システムUI（ステータスバー）の色を更新
  void _updateSystemUI() {
    if (_showHeader) {
      // 入力前：濃いグレーの背景に合わせてライトコンテンツ
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    } else {
      // 入力後：コンテンツヘッダーと同じ色（Colors.grey[200]）
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.grey[200],
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    }
  }

  /// テキストが変更された際の処理
  void _onTextChanged() {
    _state.updateText(_controller.text);
    _savePageText(); // 自動保存
    setState(() {});
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

  /// 最終更新時刻をフォーマット
  String _formatLastUpdated() {
    if (_state.lastUpdatedAt == null) {
      return '最終更新 --';
    }
    final date = _state.lastUpdatedAt!;
    return '最終更新 ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 設定画面を開く
  void _openSettings() {
    setState(() {
      _state.hideSettingsBadge();
    });
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  /// ページを選択
  Future<void> _onPageSelected(PageEntity page) async {
    // 現在のページのテキストを保存
    await _savePageText();
    if (!mounted) return;
    // 新しいページに切り替え
    setState(() {
      _currentPage = page;
      _state.updatePageId(page.id);
    });
    await _loadPageText();
  }

  /// ページ編集モーダルを開く
  void _openPageEditModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PageEditModal(
        pages: _pages,
        onSave: (pages) async {
          await _pageRepository.savePages(pages);
          if (mounted) {
            await _loadPages();
          }
        },
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
              decoration: const BoxDecoration(
                color: Colors.grey,
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左側：スペーサー（中央揃えのため）
                  const SizedBox(width: 48),
                  // 中央：アプリ名
                  const Text(
                    '改行くん',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // 右側：設定アイコン
                  Stack(
                    children: [
                      IconButton(
                        onPressed: _openSettings,
                        icon: const Icon(Icons.settings, color: Colors.white),
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
          Padding(
            padding: EdgeInsets.only(
              top: _showHeader ? 0 : MediaQuery.of(context).padding.top,
            ),
            child: ContentHeader(
              currentPage:
                  _currentPage ??
                  const PageEntity(id: 'page1', name: 'Page1', order: 0),
              pages: _pages.isEmpty
                  ? [const PageEntity(id: 'page1', name: 'Page1', order: 0)]
                  : _pages,
              onPrevious:
                  _currentPage != null &&
                      _pages.isNotEmpty &&
                      _pages.indexOf(_currentPage!) > 0
                  ? () async {
                      final currentIndex = _pages.indexOf(_currentPage!);
                      await _onPageSelected(_pages[currentIndex - 1]);
                    }
                  : null,
              onNext:
                  _currentPage != null &&
                      _pages.isNotEmpty &&
                      _pages.indexOf(_currentPage!) < _pages.length - 1
                  ? () async {
                      final currentIndex = _pages.indexOf(_currentPage!);
                      await _onPageSelected(_pages[currentIndex + 1]);
                    }
                  : null,
              onPageSelected: _onPageSelected,
              onEditPages: _openPageEditModal,
              onPageButtonTap: () {
                // フォーカスを保持（入力後の状態を維持）
                if (_focusNode.hasFocus) {
                  // フォーカスを明示的に保持
                  FocusScope.of(context).requestFocus(_focusNode);
                }
              },
            ),
          ),
          // 入力モード時の広告（コンテンツヘッダーの下）
          if (!_showHeader) const BannerAdWidget(),
          // メインコンテンツ
          Expanded(
            child: GestureDetector(
              onTap: () {
                // bodyの空白部分をタップしたらフォーカスを外す
                if (_focusNode.hasFocus) {
                  _focusNode.unfocus();
                }
              },
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
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // 入力エリアをタップしたらフォーカスを当てる
                        _focusNode.requestFocus();
                      },
                      child: Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final isDark = theme.brightness == Brightness.dark;

                          return Container(
                            constraints: const BoxConstraints(minHeight: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withOpacity(
                                      0.3,
                                    ) // ダークモード：はっきりとした黒エリア
                                  : Colors.white,
                              border: isDark
                                  ? null // ダークモード：境界線なし（背景色で表現）
                                  : Border.all(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                // テキストフィールド
                                TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.white
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                // 未入力時の顔文字表示
                                if (_state.text.isEmpty)
                                  Center(
                                    child: Text(
                                      '*-*',
                                      style: TextStyle(
                                        fontSize: 48,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 情報表示エリア（最終更新時刻と文字数・タグ数）
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // 情報表示エリアをタップしたらフォーカスを外す
                        if (_focusNode.hasFocus) {
                          _focusNode.unfocus();
                        }
                      },
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
                                '${_state.characterCount}',
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
                                '${_state.tagCount}',
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
                    const SizedBox(height: 24),
                    // コピーボタン（常に有効な色）
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _state.text.isEmpty ? null : _copyText,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[200],
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.blue[200],
                          disabledForegroundColor: Colors.white,
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
                    // 削除ボタン（常に有効な色）
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _state.text.isEmpty ? null : _deleteText,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[200],
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.red[200],
                          disabledForegroundColor: Colors.white,
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
          ),
          // ボトム広告（ヘッダー表示時のみ）
          if (_showHeader) const BannerAdWidget(),
        ],
      ),
    );
  }
}
