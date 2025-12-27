# core/

このディレクトリには、アプリケーション全体で使用される共通の要素を配置します。

## ディレクトリ構成（推奨）

- `constants/` - 定数（文字列、数値、設定値など）
- `exceptions/` - カスタム例外クラス
- `theme/` - テーマ設定（色、テキストスタイルなど）
- `utils/` - ユーティリティ関数（日付フォーマット、バリデーションなど）

## 使用例

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'Kaigyo';
  static const int maxRetryCount = 3;
}

// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(...);
  static ThemeData get darkTheme => ThemeData(...);
}
```


