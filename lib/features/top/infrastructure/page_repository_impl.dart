import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/page_entity.dart';
import '../domain/page_repository.dart';

/// ページリポジトリの実装
///
/// SharedPreferencesを使用してページデータを永続化します。
class PageRepositoryImpl implements PageRepository {
  static const String _pagesKey = 'pages';
  static const String _pageTextPrefix = 'page_text_';
  static const String _pageLastUpdatedAtPrefix = 'page_last_updated_at_';

  @override
  Future<List<PageEntity>> getAllPages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pagesJson = prefs.getString(_pagesKey);
      if (pagesJson == null) {
        // デフォルトのページを作成
        return _createDefaultPages();
      }
      final List<dynamic> pagesList = jsonDecode(pagesJson) as List<dynamic>;
      return pagesList
          .map((json) => PageEntity.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      // エラーが発生した場合はデフォルトのページを返す
      return _createDefaultPages();
    }
  }

  @override
  Future<List<PageEntity>> getPagesUpToLimit(int maxPageCount) async {
    final allPages = await getAllPages();
    final existingPageCount = allPages.length;

    // 不足しているページを自動的に作成
    if (existingPageCount < maxPageCount) {
      final newPages = <PageEntity>[];
      for (int i = existingPageCount; i < maxPageCount; i++) {
        newPages.add(
          PageEntity(id: 'page${i + 1}', name: 'Page${i + 1}', order: i),
        );
      }
      final updatedPages = [...allPages, ...newPages];
      await savePages(updatedPages);
      return updatedPages;
    }

    // 最大ページ数までに制限
    return allPages.take(maxPageCount).toList();
  }

  @override
  Future<void> savePages(List<PageEntity> pages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pagesJson = jsonEncode(pages.map((page) => page.toJson()).toList());
      await prefs.setString(_pagesKey, pagesJson);
    } catch (e) {
      // エラーが発生した場合は無視（ログに記録するなど）
      debugPrint('Error saving pages: $e');
    }
  }

  @override
  Future<String> getPageText(String pageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_pageTextPrefix$pageId') ?? '';
    } catch (e) {
      // エラーが発生した場合は空文字を返す
      // MissingPluginExceptionの場合はプラグインが未登録のため、デバッグモードでのみログ出力
      if (kDebugMode && e.toString().contains('MissingPluginException')) {
        debugPrint(
          'Warning: SharedPreferences plugin not registered. Please restart the app completely.',
        );
      } else {
        debugPrint('Error getting page text: $e');
      }
      return '';
    }
  }

  @override
  Future<void> savePageText(String pageId, String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_pageTextPrefix$pageId', text);
    } catch (e) {
      // エラーが発生した場合は無視（ログに記録するなど）
      debugPrint('Error saving page text: $e');
    }
  }

  @override
  Future<DateTime?> getPageLastUpdatedAt(String pageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_pageLastUpdatedAtPrefix$pageId';
      final timestamp = prefs.getInt(key);
      if (timestamp == null) {
        return null;
      }
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      debugPrint('Error getting page last updated at: $e');
      return null;
    }
  }

  @override
  Future<void> savePageLastUpdatedAt(
    String pageId,
    DateTime lastUpdatedAt,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_pageLastUpdatedAtPrefix$pageId';
      final timestamp = lastUpdatedAt.millisecondsSinceEpoch;
      await prefs.setInt(key, timestamp);
    } catch (e) {
      debugPrint('Error saving page last updated at: $e');
    }
  }

  /// デフォルトのページを作成
  List<PageEntity> _createDefaultPages() {
    return [
      const PageEntity(id: 'page1', name: 'Page1', order: 0),
      const PageEntity(id: 'page2', name: 'Page2', order: 1),
      const PageEntity(id: 'page3', name: 'Page3', order: 2),
    ];
  }
}
