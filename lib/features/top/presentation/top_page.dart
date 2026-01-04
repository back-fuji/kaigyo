import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../application/top_state.dart';
import '../domain/page_entity.dart';
import '../domain/page_repository.dart';
import 'widgets/content_header.dart';
import 'widgets/page_edit_modal.dart';
import '../../../ads/banner_ad_widget.dart';
import '../../../core/constants/app_constants.dart';
import '../../settings/presentation/settings_page.dart';
import '../../settings/domain/purchase_repository.dart';
import '../../../shared/widgets/copy_modal.dart';
import '../../../shared/widgets/delete_modal.dart';

/// トップページ
///
/// アプリのメイン画面です。
/// テキスト入力、コピー、削除などの機能を提供します。
class TopPage extends StatefulWidget {
  /// ページリポジトリ
  final PageRepository pageRepository;

  /// 購入リポジトリ
  final PurchaseRepository purchaseRepository;

  /// コンストラクタ
  const TopPage({
    super.key,
    required this.pageRepository,
    required this.purchaseRepository,
  });

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  final TopState _state = TopState();
  late final PageRepository _pageRepository;
  late final PurchaseRepository _purchaseRepository;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final PageController _pageController;
  bool _showHeader = true;
  List<PageEntity> _pages = [];
  PageEntity? _currentPage;
  int _currentPageIndex = 0;
  int _maxPageCount = 3; // デフォルトは3ページ
  bool _isAdRemoved = false; // 広告非表示の購入状態
  DateTime? _currentPageLastUpdatedAt; // 現在のページの更新日時
  bool _isPageSelectionInProgress = false; // ページ選択処理中フラグ
  final Map<String, String> _pageTextCache = {}; // ページテキストのキャッシュ

  @override
  void initState() {
    super.initState();
    // 注入されたリポジトリを使用
    _pageRepository = widget.pageRepository;
    _purchaseRepository = widget.purchaseRepository;
    _controller = TextEditingController(text: _state.text);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
    // デフォルトのページを設定（読み込み完了まで表示）
    _currentPage = const PageEntity(id: 'page1', name: 'Page1', order: 0);
    _pages = [_currentPage!];
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_onPageChanged);
    _loadPages();
    // 初期状態のステータスバー色を設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUI();
    });
  }

  /// ページを読み込む
  Future<void> _loadPages() async {
    // 購入状態に応じた最大ページ数を取得
    final maxPageCount = await _purchaseRepository.getMaxPageCount();
    // 広告非表示の購入状態を取得
    final isAdRemoved = await _purchaseRepository.isAdRemovedPurchased();
    if (!mounted) return;

    setState(() {
      _maxPageCount = maxPageCount;
      _isAdRemoved = isAdRemoved;
    });

    // 購入状態に応じた最大ページ数までのページを取得
    final pages = await _pageRepository.getPagesUpToLimit(maxPageCount);
    if (!mounted) return;
    final sortedPages = List<PageEntity>.from(pages)
      ..sort((a, b) => a.order.compareTo(b.order));

    final currentIndex = sortedPages.indexWhere(
      (p) => p.id == _state.currentPageId,
    );
    final targetIndex = currentIndex >= 0 ? currentIndex : 0;

    setState(() {
      _pages = sortedPages;
      _currentPage = sortedPages[targetIndex];
      _currentPageIndex = targetIndex;
      _state.updatePageId(_currentPage!.id);
    });

    // PageControllerの位置を更新（必要に応じて）
    if (_pageController.hasClients &&
        _pageController.page?.round() != targetIndex) {
      _pageController.jumpToPage(targetIndex);
    }

    await _loadPageText();

    // すべてのページのテキストをキャッシュに読み込む
    for (final page in sortedPages) {
      if (!_pageTextCache.containsKey(page.id)) {
        final text = await _pageRepository.getPageText(page.id);
        _pageTextCache[page.id] = text;
      }
    }
  }

  /// 現在のページのテキストを読み込む
  Future<void> _loadPageText() async {
    if (_currentPage == null || !mounted) return;
    final pageId = _currentPage!.id;
    final text = await _pageRepository.getPageText(pageId);
    final lastUpdatedAt = await _pageRepository.getPageLastUpdatedAt(pageId);
    if (!mounted) return;
    // キャッシュに追加
    _pageTextCache[pageId] = text;
    // リスナーを一時的に削除して、_controller.text設定時に_onTextChangedが発火しないようにする
    _controller.removeListener(_onTextChanged);
    setState(() {
      _state.updateText(text);
      _controller.text = text;
      _currentPageLastUpdatedAt = lastUpdatedAt;
    });
    // リスナーを再度追加
    _controller.addListener(_onTextChanged);
  }

  /// 現在のページのテキストを保存
  ///
  /// [updateLastModified]がtrueの場合、更新日時も更新します。
  /// デフォルトはfalseで、テキストが実際に変更されたときのみ更新日時を更新するために使用します。
  Future<void> _savePageText({bool updateLastModified = false}) async {
    if (_currentPage == null) return;
    final pageId = _currentPage!.id;
    await _pageRepository.savePageText(pageId, _state.text);
    if (updateLastModified) {
      final now = DateTime.now();
      await _pageRepository.savePageLastUpdatedAt(pageId, now);
      if (mounted) {
        setState(() {
          _currentPageLastUpdatedAt = now;
        });
      }
    }
  }

  @override
  void dispose() {
    _savePageText(); // 最終保存
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  /// フォーカス状態が変更された際の処理
  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _showHeader = !_focusNode.hasFocus;
    });
    // ステータスバーの色を更新（フレーム完了後に実行）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateSystemUI();
      }
    });
  }

  /// システムUI（ステータスバー）の色を更新
  ///
  /// テキスト入力接続の不整合を防ぐため、このメソッドは
  /// フレーム完了後に呼び出されることを想定しています。
  void _updateSystemUI() {
    if (!mounted) return;
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
    _savePageText(updateLastModified: true); // 自動保存（更新日時も更新）
    setState(() {});
  }

  /// テキストをコピー
  void _copyText() async {
    // テキストが入力されている場合はコピーを実行
    if (_state.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _state.text));
    }

    // モーダルを表示
    if (mounted) {
      // 広告非表示の購入状態を取得
      final isAdRemoved = await _purchaseRepository.isAdRemovedPurchased();
      showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) =>
            CopyModal(hasText: _state.text.isNotEmpty, showAd: !isAdRemoved),
      );
    }
  }

  /// テキストを削除
  void _deleteText() async {
    // 削除確認モーダルを表示
    if (mounted) {
      // 広告非表示の購入状態を取得
      final isAdRemoved = await _purchaseRepository.isAdRemovedPurchased();
      showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => DeleteModal(
          onDelete: () async {
            setState(() {
              _state.clearText();
              _controller.clear();
            });
            // 削除時に更新日時も保存
            await _savePageText(updateLastModified: true);
          },
          showAd: !isAdRemoved,
        ),
      );
    }
  }

  /// 最終更新時刻をフォーマット
  String _formatLastUpdated() {
    if (_currentPageLastUpdatedAt == null) {
      return '最終更新 --';
    }
    final date = _currentPageLastUpdatedAt!;
    return '最終更新 ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 設定画面を開く
  Future<void> _openSettings() async {
    setState(() {
      _state.hideSettingsBadge();
    });
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SettingsPage(purchaseRepository: _purchaseRepository),
      ),
    );
    // 設定ページから戻ってきたときにページを再読み込み（購入状態が変更された可能性があるため）
    if (mounted) {
      await _loadPages();
    }
  }

  /// ページが変更された際の処理（PageViewのスクロール時）
  void _onPageChanged() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page;
    if (page == null) return;

    // ページ選択処理中の場合は無視
    if (_isPageSelectionInProgress) {
      return;
    }

    final newIndex = page.round();
    if (newIndex != _currentPageIndex &&
        newIndex >= 0 &&
        newIndex < _pages.length) {
      // ページが変更された場合、保存して新しいページを読み込む
      // 更新日時は更新しない（テキストのみ保存）
      _savePageText(updateLastModified: false).then((_) {
        if (!mounted) return;
        final newPage = _pages[newIndex];
        setState(() {
          _currentPage = newPage;
          _currentPageIndex = newIndex;
          _state.updatePageId(newPage.id);
        });
        _loadPageText();
      });
    }
  }

  /// ページを選択
  Future<void> _onPageSelected(PageEntity page) async {
    // 現在のページのテキストを保存（更新日時も更新）
    await _savePageText(updateLastModified: true);
    if (!mounted) return;

    // 選択されたページのインデックスを取得
    final targetIndex = _pages.indexWhere((p) => p.id == page.id);
    if (targetIndex < 0) {
      return;
    }

    // 既に同じページの場合は何もしない
    if (_currentPageIndex == targetIndex && _currentPage?.id == page.id) {
      return;
    }

    // ページ選択処理中フラグを設定
    _isPageSelectionInProgress = true;

    // PageControllerでページを切り替え（先にPageControllerを更新）
    if (_pageController.hasClients) {
      // jumpToPageを使用して即座に切り替え（アニメーションは不要）
      _pageController.jumpToPage(targetIndex);
    }

    // 新しいページに切り替え（状態を更新）
    // jumpToPageの後にsetStateを呼ぶことで、PageViewが正しく更新される
    setState(() {
      _currentPage = page;
      _currentPageIndex = targetIndex;
      _state.updatePageId(page.id);
    });

    // jumpToPageの後にPageControllerの状態を確認
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final afterPageControllerIndex = _pageController.hasClients
            ? _pageController.page?.round()
            : null;
        // PageControllerの位置が正しく更新されているか確認
        if (afterPageControllerIndex != targetIndex) {
          // 再度jumpToPageを試みる
          _pageController.jumpToPage(targetIndex);
        }
      }
    });

    // フレーム完了後にフラグをリセット
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isPageSelectionInProgress = false;
    });

    // 新しいページのテキストを読み込む
    await _loadPageText();
  }

  /// ページ編集モーダルを開く
  /// [modalContext]はshowDialogのcontextを渡す（showDialogを閉じずにモーダルを開くため）
  void _openPageEditModal([BuildContext? modalContext]) async {
    // モーダルを開く
    // modalContextが指定されている場合はそれを使用（showDialogの上に表示）
    // 指定されていない場合はTopPageのcontextを使用
    final contextToUse = modalContext ?? context;

    // showGeneralDialogを使って背景をスケールダウンするアニメーションを実現
    await showGeneralDialog(
      context: contextToUse,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(
        contextToUse,
      ).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PageEditModal(
          pages: _pages,
          maxPageCount: _maxPageCount,
          onSave: (pages) async {
            await _pageRepository.savePages(pages);
            if (mounted) {
              await _loadPages();
            }
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // 背景を少し小さくして後ろに引くアニメーション
        // Navigator全体をラップしてスケールダウン
        final scaleAnimation = Tween<double>(
          begin: 1.0,
          end: 0.95,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        final fadeAnimation = Tween<double>(
          begin: 1.0,
          end: 0.8,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        // 新しい画面を下からスライドイン
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Stack(
              children: [
                // 背景全体をスケールダウン（Navigator全体をラップ）
                Transform.scale(
                  scale: scaleAnimation.value,
                  child: Opacity(
                    opacity: fadeAnimation.value,
                    child: IgnorePointer(
                      child: Container(color: Colors.transparent, child: child),
                    ),
                  ),
                ),
                // 新しい画面を下からスライドイン
                SlideTransition(position: slideAnimation, child: child),
              ],
            );
          },
        );
      },
    );

    // モーダルを閉じた後に状態を復元
    if (mounted) {
      // システムUIの状態を復元（フレーム完了後に実行）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateSystemUI();
        }
      });
    }
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
                      _currentPageIndex > 0
                  ? () async {
                      // インデックスの範囲チェック
                      if (_currentPageIndex > 0 &&
                          _currentPageIndex < _pages.length) {
                        await _onPageSelected(_pages[_currentPageIndex - 1]);
                      }
                    }
                  : null,
              onNext:
                  _currentPage != null &&
                      _pages.isNotEmpty &&
                      _currentPageIndex < _pages.length - 1
                  ? () async {
                      // インデックスの範囲チェック
                      if (_currentPageIndex >= 0 &&
                          _currentPageIndex < _pages.length - 1) {
                        await _onPageSelected(_pages[_currentPageIndex + 1]);
                      }
                    }
                  : null,
              onPageSelected: _onPageSelected,
              onEditPages: (dialogContext) => _openPageEditModal(dialogContext),
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
          if (!_showHeader && !_isAdRemoved) const BannerAdWidget(),
          // メインコンテンツ（PageViewで横スクロール可能）
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.isEmpty ? 1 : _pages.length,
              onPageChanged: (index) {
                // ページが変更されたときの処理は_onPageChangedで行う
              },
              itemBuilder: (context, index) {
                // PageViewはPageConstrollerの位置に基づいて表示するページを決定する
                // itemBuilder内でisCurrentPageを判定する必要はない
                // PageViewが表示するページは、PageControllerの位置と一致する
                final pageId = index < _pages.length ? _pages[index].id : null;
                // このインデックスのページが現在のページかどうかを確認
                // PageViewが表示するページは、PageControllerの位置と一致するため、
                // indexがPageControllerの位置と一致するかどうかを確認する必要がある
                // しかし、PageController.pageを直接参照するとエラーになる可能性があるため、
                // _currentPageIndexを使用する（_onPageSelectedで更新される）
                final isCurrentPage = index == _currentPageIndex;

                return GestureDetector(
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
                            // 入力エリアをタップしたらフォーカスを当てる（現在のページの場合のみ）
                            if (isCurrentPage) {
                              _focusNode.requestFocus();
                            } else {
                              // 別のページをタップした場合は、そのページに切り替え
                              if (pageId != null) {
                                final page = _pages.firstWhere(
                                  (p) => p.id == pageId,
                                );
                                _onPageSelected(page);
                              }
                            }
                          },
                          child: Builder(
                            builder: (context) {
                              final theme = Theme.of(context);
                              final isDark =
                                  theme.brightness == Brightness.dark;

                              return Container(
                                constraints: const BoxConstraints(
                                  minHeight: 200,
                                ),
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
                                    // テキストフィールド（現在のページの場合のみ編集可能）
                                    if (isCurrentPage)
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
                                              : theme
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                        ),
                                      )
                                    else
                                      // 別のページの場合は読み取り専用テキストを表示
                                      Builder(
                                        builder: (context) {
                                          // キャッシュからテキストを取得、なければ空文字
                                          final text = pageId != null
                                              ? (_pageTextCache[pageId] ?? '')
                                              : '';
                                          return Text(
                                            text.isEmpty ? '*-*' : text,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: text.isEmpty
                                                  ? Colors.grey[400]
                                                  : (isDark
                                                        ? Colors.white
                                                        : theme
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.color),
                                            ),
                                          );
                                        },
                                      ),
                                    // 未入力時の顔文字表示（現在のページの場合のみ）
                                    if (isCurrentPage && _state.text.isEmpty)
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
                        // コピーボタン（常に有効）
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _copyText,
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
                        // 削除ボタン（常に有効）
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _deleteText,
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
                );
              },
            ),
          ),
          // ボトム広告（ヘッダー表示時のみ）
          if (_showHeader && !_isAdRemoved)
            SafeArea(top: false, child: const BannerAdWidget()),
        ],
      ),
    );
  }
}
