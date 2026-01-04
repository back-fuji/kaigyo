import 'page_entity.dart';

/// ページリポジトリインターフェース
///
/// ページの永続化と取得を行うリポジトリです。
abstract class PageRepository {
  /// すべてのページを取得
  Future<List<PageEntity>> getAllPages();

  /// 購入状態に応じた最大ページ数までのページを取得
  ///
  /// [maxPageCount] 最大ページ数（購入状態に応じて3、10、20のいずれか）
  Future<List<PageEntity>> getPagesUpToLimit(int maxPageCount);

  /// ページを保存
  Future<void> savePages(List<PageEntity> pages);

  /// ページのテキストを取得
  Future<String> getPageText(String pageId);

  /// ページのテキストを保存
  Future<void> savePageText(String pageId, String text);

  /// ページの更新日時を取得
  Future<DateTime?> getPageLastUpdatedAt(String pageId);

  /// ページの更新日時を保存
  Future<void> savePageLastUpdatedAt(String pageId, DateTime lastUpdatedAt);
}
