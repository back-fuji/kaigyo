/// トップページの状態管理クラス
///
/// テキスト、ページ数、設定アイコンの未読状態などを管理します。
class TopState {
  /// 入力テキスト
  String text = '';

  /// 現在のページ数
  int currentPage = 1;

  /// 設定アイコンの未読バッジ表示状態
  bool showSettingsBadge = true;

  /// 最終更新時刻
  DateTime? lastUpdatedAt;

  /// テキストを更新
  void updateText(String newText) {
    text = newText;
    lastUpdatedAt = DateTime.now();
  }

  /// ページ数を更新
  void updatePage(int newPage) {
    currentPage = newPage;
  }

  /// 設定バッジを非表示にする
  void hideSettingsBadge() {
    showSettingsBadge = false;
  }

  /// テキストを全削除
  void clearText() {
    text = '';
  }

  /// 文字数を取得
  int get characterCount => text.length;

  /// タグ数（#で始まる単語数）を取得
  ///
  /// #で始まり、その後に英数字やアンダースコアが続くパターンをカウントします。
  int get tagCount {
    final regex = RegExp(r'#\w+');
    final matches = regex.allMatches(text);
    return matches.length;
  }
}
