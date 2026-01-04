/// 購入リポジトリインターフェース
///
/// 購入状態の取得・保存を行うリポジトリのインターフェースです。
abstract class PurchaseRepository {
  /// 広告非表示の購入状態を取得
  Future<bool> isAdRemovedPurchased();

  /// 広告非表示の購入状態を保存
  Future<void> setAdRemovedPurchased(bool value);

  /// ページ数上限増加（3→10）の購入状態を取得
  Future<bool> isPageLimit10Purchased();

  /// ページ数上限増加（3→10）の購入状態を保存
  Future<void> setPageLimit10Purchased(bool value);

  /// ページ数上限増加（10→20）の購入状態を取得
  Future<bool> isPageLimit20Purchased();

  /// ページ数上限増加（10→20）の購入状態を保存
  Future<void> setPageLimit20Purchased(bool value);

  /// 最大ページ数を取得
  ///
  /// 購入状態に応じて3、10、20のいずれかを返します。
  Future<int> getMaxPageCount();
}
