# Flutterプロジェクト セットアップ完了

## ✅ 完了した作業

1. ✅ Flutterプロジェクトの作成 (`flutter create .`)
2. ✅ プロジェクトルールに基づくディレクトリ構造の作成
3. ✅ 基本的な`main.dart`のセットアップ
4. ✅ 依存関係の取得 (`flutter pub get`)

## 📁 プロジェクト構造

```
kaigyo/
├── lib/
│   ├── main.dart              # アプリのエントリーポイント
│   ├── core/                  # 定数・例外・テーマ・ユーティリティ
│   │   └── README.md          # core/ の説明
│   ├── features/              # 各機能（feature）ごとのモジュール
│   │   └── README.md          # features/ の説明と4層構造の説明
│   └── shared/                # 共通Widget・共通サービス
│       └── README.md          # shared/ の説明
├── test/                      # テストファイル
├── android/                   # Android固有の設定（編集禁止）
├── ios/                       # iOS固有の設定（編集禁止）
├── web/                       # Web固有の設定
├── macos/                     # macOS固有の設定
├── windows/                   # Windows固有の設定
├── linux/                     # Linux固有の設定
├── pubspec.yaml              # 依存関係とプロジェクト設定
└── README.md                 # プロジェクト説明
```

## 🚀 次のステップ

### 1. アプリの実行

```bash
# 利用可能なデバイスを確認
flutter devices

# アプリを実行（デフォルトで最初のデバイスに実行）
flutter run

# 特定のデバイスで実行
flutter run -d <device-id>
```

### 2. 開発の開始

#### 新しい機能を追加する場合

1. `lib/features/<feature_name>/` ディレクトリを作成
2. 以下の4層構造を作成：
   - `presentation/` - UI（Widget）
   - `application/` - state, usecase（アプリケーションロジック）
   - `domain/` - entity, repository interface（ドメインロジック）
   - `infrastructure/` - API実装・外部サービスとの接続

#### 例: ログイン機能を追加する場合

```bash
mkdir -p lib/features/auth/presentation
mkdir -p lib/features/auth/application
mkdir -p lib/features/auth/domain
mkdir -p lib/features/auth/infrastructure
```

### 3. 状態管理の選択

プロジェクトルールに従い、状態管理方式は**ユーザーが選択**します。
一般的な選択肢：
- Provider
- Riverpod
- Bloc
- GetX
- その他

選択後、プロジェクト全体で統一して使用します。

### 4. テーマの設定

将来的に `lib/core/theme/` にテーマ設定を移動することを推奨します。

```dart
// lib/core/theme/app_theme.dart を作成
class AppTheme {
  static ThemeData get lightTheme => ThemeData(...);
  static ThemeData get darkTheme => ThemeData(...);
}
```

## 📚 重要なルール

### コード規約

- ✅ `const` を使える箇所には必ず `const` を付ける
- ✅ `async/await` を使用し、`then` チェーンは禁止
- ✅ UIロジックとビジネスロジックは必ず分離
- ✅ クラス名：PascalCase
- ✅ ファイル名：snake_case
- ✅ private メソッド：_camelCase

### アーキテクチャ

- ✅ 依存方向は **UI → application → domain → infrastructure** の一方向のみ
- ✅ プレゼンテーション層は domain や infra に直接依存しない
- ✅ ビジネスロジックを Widget 内に書いてはならない

### ドキュメント

- ✅ public メソッド・public クラスには必ず DartDoc (`///`) を付与
- ✅ 役割・入出力・例外・依存関係を明記

## 🔧 よく使うコマンド

```bash
# 依存関係の取得
flutter pub get

# 依存関係の更新
flutter pub upgrade

# コードの分析
flutter analyze

# コードのフォーマット
flutter format .

# ビルド（Android APK）
flutter build apk

# ビルド（iOS）
flutter build ios

# ビルド（Web）
flutter build web
```

## 📖 参考資料

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Dart公式ドキュメント](https://dart.dev/)
- [Flutter APIリファレンス](https://api.flutter.dev/)

## ⚠️ 注意事項

- `android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/` ディレクトリ内のファイルは、要求がない限り編集しない
- `pubspec.yaml` の依存関係は、理由と用途を説明してから追加する
- 状態管理方式は推測で決めず、ユーザーが選択する

---

プロジェクトの準備が完了しました！🎉


