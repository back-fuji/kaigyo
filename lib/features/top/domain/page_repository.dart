import 'page_entity.dart';

/// ページリポジトリインターフェース
///
/// ページの永続化と取得を行うリポジトリです。
abstract class PageRepository {
  /// すべてのページを取得
  Future<List<PageEntity>> getAllPages();

  /// ページを保存
  Future<void> savePages(List<PageEntity> pages);

  /// ページのテキストを取得
  Future<String> getPageText(String pageId);

  /// ページのテキストを保存
  Future<void> savePageText(String pageId, String text);
}
