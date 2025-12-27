# features/

このディレクトリには、機能ごとのモジュールを配置します。

## ディレクトリ構造

各機能（feature）は、以下の4層構造で必ず構成します：

```
features/
└── <feature>/
    ├── presentation/    # UI（Widget）
    ├── application/     # state, usecase（アプリケーションロジック）
    ├── domain/          # entity, repository interface（ドメインロジック）
    └── infrastructure/  # API実装・外部サービスとの接続
```

## 依存関係の方向

**UI → application → domain → infrastructure** の一方向のみ

- `presentation` は `application` のみに依存
- `application` は `domain` のみに依存
- `domain` は他の層に依存しない（純粋なビジネスロジック）
- `infrastructure` は `domain` のインターフェースを実装

## 使用例

### 例: ユーザー認証機能（auth）

```
features/
└── auth/
    ├── presentation/
    │   ├── login_page.dart          # ログイン画面
    │   └── widgets/
    │       └── login_form.dart      # ログインフォームWidget
    ├── application/
    │   ├── auth_state.dart          # 認証状態管理
    │   └── login_usecase.dart       # ログイン処理のユースケース
    ├── domain/
    │   ├── user_entity.dart         # ユーザーエンティティ
    │   └── auth_repository.dart     # 認証リポジトリのインターフェース
    └── infrastructure/
        └── auth_repository_impl.dart # 認証リポジトリの実装（API呼び出しなど）
```

## 注意事項

- ビジネスロジックをWidget内に書いてはならない
- 状態管理方式はユーザーが選択した方式に統一する
- 各層の責務を明確に分離する


