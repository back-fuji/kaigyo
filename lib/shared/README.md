# shared/

このディレクトリには、複数の機能で共通して使用されるWidgetやサービスを配置します。

## ディレクトリ構成（推奨）

- `widgets/` - 共通Widget（ボタン、カード、ダイアログなど）
- `services/` - 共通サービス（ログ、キャッシュ、通知など）

## 使用例

```dart
// lib/shared/widgets/custom_button.dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

// lib/shared/services/logger.dart
class Logger {
  static void info(String message) {
    debugPrint('[INFO] $message');
  }
  
  static void error(String message, [Object? error]) {
    debugPrint('[ERROR] $message: $error');
  }
}
```

## features/ との違い

- `features/` は特定の機能に属するコード
- `shared/` は複数の機能で再利用される汎用的なコード


