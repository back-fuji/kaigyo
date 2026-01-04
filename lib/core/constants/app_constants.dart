/// アプリケーション全体で使用する定数
class AppConstants {
  /// セッション時間（3時間 = 10800秒）
  static const int sessionDurationSeconds = 10800;

  /// 全画面広告の表示時間（5秒）
  static const int fullscreenAdDisplaySeconds = 5;

  /// 左右の余白（16px）
  static const double horizontalPadding = 16.0;

  /// Androidパッケージ名
  static const String androidPackageName = 'com.kaigyo.app';

  /// iOS App Store ID（アプリ公開後に設定してください）
  /// App Store Connectで確認できる数値IDを設定します
  static const String iosAppStoreId = 'YOUR_APP_STORE_ID';
}
