# Flutter開発ガイド

Flutter開発で覚えるべき知識をまとめたガイドです。

## 目次

1. [Dart言語の基礎](#dart言語の基礎)
2. [変数宣言](#変数宣言)
3. [非同期処理](#非同期処理)
4. [Widgetの基本概念](#widgetの基本概念)
5. [状態管理のパターン](#状態管理のパターン)
6. [ライフサイクル](#ライフサイクル)
7. [アーキテクチャパターン](#アーキテクチャパターン)
8. [パフォーマンス最適化](#パフォーマンス最適化)
9. [エラーハンドリング](#エラーハンドリング)
10. [ベストプラクティス](#ベストプラクティス)

---

## Dart言語の基礎

### 基本的な型

```dart
// 数値型
int count = 10;
double price = 99.99;
num number = 10;  // int または double

// 文字列型
String name = 'Flutter';
String message = "Hello, $name";  // 文字列補間

// 真偽値型
bool isActive = true;

// リスト（配列）
List<String> items = ['a', 'b', 'c'];
List<int> numbers = [1, 2, 3];

// マップ（連想配列）
Map<String, int> scores = {'Alice': 100, 'Bob': 90};

// null安全
String? nullableString;  // null を許可
String nonNullableString = 'text';  // null を許可しない
```

### 関数

```dart
// 通常の関数
void printMessage(String message) {
  print(message);
}

// 戻り値がある関数
int add(int a, int b) {
  return a + b;
}

// アロー関数（1行で値を返す）
int multiply(int a, int b) => a * b;

// 名前付きパラメータ
void greet({required String name, int age = 0}) {
  print('Hello, $name. Age: $age');
}
greet(name: 'Alice', age: 25);

// 位置パラメータ
void greet2(String name, [int? age]) {
  print('Hello, $name. Age: ${age ?? 'unknown'}');
}
greet2('Alice', 25);
```

### クラス

```dart
class Person {
  final String name;
  int age;

  // コンストラクタ
  Person({required this.name, this.age = 0});

  // 名前付きコンストラクタ
  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        age = json['age'];

  // メソッド
  void introduce() {
    print('I am $name, $age years old.');
  }
}
```

### プライベート（ライブラリプライベート）

`_` で始まる名前は同じファイル内でのみアクセス可能です。

```dart
class _PrivateClass {  // プライベートクラス
  String _privateField = 'private';  // プライベートフィールド
  
  void _privateMethod() {  // プライベートメソッド
    // ...
  }
}
```

---

## 変数宣言

### var - 型推論、再代入可能

```dart
var name = 'Flutter';
name = 'Dart';  // OK
```

### final - 再代入不可（実行時初期化）

```dart
final name = 'Flutter';
// name = 'Dart';  // エラー

final obj = {'key': 'value'};
obj['key'] = 'new';  // OK（オブジェクトの内容は変更可能）
```

### const - コンパイル時定数、再代入不可

```dart
const pi = 3.14159;
// pi = 3.14;  // エラー

const list = [1, 2, 3];
// list.add(4);  // エラー（const リストは変更不可）
```

### late - 後で初期化

```dart
late String name;
name = 'Flutter';  // 後で初期化

// 初期化前に使うとエラー
// print(name);  // エラー（初期化前）
```

### late final - 後で初期化、一度だけ

```dart
late final String name;
name = 'Flutter';  // OK
// name = 'Dart';  // エラー（2回目の代入不可）
```

### 明示的な型指定

```dart
String name = 'Flutter';
int count = 10;
bool isActive = true;
List<String> items = ['a', 'b'];
```

### 使い分けの指針

- **const**: コンパイル時に決まる定数値（パフォーマンス向上）
- **final**: 実行時に決まるが、一度設定したら変更しない値
- **late**: 初期化が後になる変数（initState などで初期化）
- **var**: 型推論したい場合（ローカル変数でよく使う）

---

## 非同期処理

### Future

```dart
Future<String> fetchData() async {
  await Future.delayed(const Duration(seconds: 1));
  return 'データ';
}
```

### async/await（推奨）

```dart
Future<void> loadData() async {
  try {
    final data = await fetchData();
    print(data);
  } catch (e) {
    print('エラー: $e');
  }
}
```

### .then()（非推奨、ただし必要な場合もある）

```dart
fetchData().then((value) {
  print(value);
}).catchError((error) {
  print('エラー: $error');
});
```

### Future.wait - 複数のFutureを並列実行

```dart
final results = await Future.wait([
  fetchData1(),
  fetchData2(),
  fetchData3(),
]);
```

### Stream

```dart
Stream<int> countStream() async* {
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
  }
}

// 使用
await for (final count in countStream()) {
  print(count);
}
```

---

## Widgetの基本概念

### Widgetツリー

FlutterのUIはWidgetのツリー構造で構成されます。

```dart
MaterialApp  // ルートWidget
  └─ Scaffold
      ├─ AppBar
      └─ Body
          └─ Column
              ├─ Text
              └─ ElevatedButton
```

### StatelessWidget vs StatefulWidget

**StatelessWidget**: 状態を持たないWidget（不変）

```dart
class MyWidget extends StatelessWidget {
  final String title;
  
  const MyWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}
```

**StatefulWidget**: 状態を持つWidget（可変）

```dart
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _increment,
      child: Text('Count: $_count'),
    );
  }
}
```

### key の役割

Widgetを識別するための一意の識別子。

```dart
const MyWidget(key: ValueKey('unique-id'));
```

### BuildContext

Widgetのビルドコンテキスト。Navigator、Theme、MediaQueryなどにアクセスするために使用。

```dart
Navigator.of(context).push(...);
Theme.of(context).primaryColor;
MediaQuery.of(context).size;
```

---

## 状態管理のパターン

### 1. setState（基本的な状態管理）

```dart
class _MyWidgetState extends State<MyWidget> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }
}
```

### 2. 状態を別クラスに分離

```dart
class CounterState {
  int count = 0;
  
  void increment() {
    count++;
  }
}

class _MyWidgetState extends State<MyWidget> {
  final _state = CounterState();
  
  void _increment() {
    setState(() {
      _state.increment();
    });
  }
}
```

### 3. 状態管理パッケージ（推奨）

- **Provider**: シンプルで人気
- **Riverpod**: Providerの改良版
- **Bloc**: ビジネスロジックコンポーネント
- **GetX**: 多機能な状態管理

※ プロジェクトルールに従い、ユーザーが選択した方式を使用すること

---

## ライフサイクル

### StatefulWidgetのライフサイクル

```
1. createState()        // State オブジェクトを作成
2. initState()         // 初期化（一度だけ）
3. didChangeDependencies()  // 依存関係が変更された時
4. build()              // UI構築（状態変更のたびに呼ばれる）
5. didUpdateWidget()    // Widgetが更新された時
6. setState()           // 状態更新
7. deactivate()         // Widgetツリーから削除される時
8. dispose()            // Widgetが破棄される時（一度だけ）
```

### 実装例

```dart
class _MyWidgetState extends State<MyWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 初期化処理
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // リソースの解放
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}
```

### mounted チェック

非同期処理の結果を `setState` で使う前に、Widgetがまだ存在するか確認します。

```dart
Future<void> loadData() async {
  final data = await fetchData();
  if (mounted) {  // Widgetがまだ存在するか確認
    setState(() {
      _data = data;
    });
  }
}
```

---

## アーキテクチャパターン

### クリーンアーキテクチャ（推奨）

このプロジェクトでは以下の4層構造を使用：

```
lib/features/<feature>/
├── presentation/    # UI（Widget）
├── application/     # state, usecase（アプリケーションロジック）
├── domain/          # entity, repository interface（ドメインロジック）
└── infrastructure/  # API実装・外部サービスとの接続
```

### 依存方向

```
UI → application → domain → infrastructure
```

- プレゼンテーション層は domain や infra に直接依存しない
- ビジネスロジックを Widget 内に書いてはならない

---

## パフォーマンス最適化

### const の活用

```dart
// 良い例
const Text('Hello')
const SizedBox(height: 16)

// 悪い例
Text('Hello')  // 毎回新しいインスタンスが作られる
```

### const コンストラクタ

```dart
class MyWidget extends StatelessWidget {
  final String title;
  
  const MyWidget({super.key, required this.title});  // const コンストラクタ
  
  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}

// 使用時も const を付ける
const MyWidget(title: 'Hello')
```

### 不要な再構築を避ける

```dart
// 良い例：変更される部分だけを setState で囲む
void _updateCounter() {
  setState(() {
    _counter++;  // 必要な部分だけ更新
  });
}

// 悪い例：全体を再構築
void _updateCounter() {
  setState(() {
    // 不要な処理も含めて全体を更新
  });
}
```

### ListView.builder の使用

長いリストでは `ListView.builder` を使用して、表示される部分だけを構築します。

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)
```

---

## エラーハンドリング

### try-catch

```dart
try {
  final data = await fetchData();
  // 処理
} on NetworkException catch (e) {
  // 特定の例外を処理
  print('ネットワークエラー: $e');
} catch (e, stackTrace) {
  // その他の例外を処理
  print('エラー: $e');
  print('スタックトレース: $stackTrace');
} finally {
  // 必ず実行される処理
  print('完了');
}
```

### Future のエラーハンドリング

```dart
Future<void> loadData() async {
  try {
    final data = await fetchData();
    setState(() {
      _data = data;
    });
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    }
  }
}
```

### null 安全

```dart
String? nullableString;

// null チェック
if (nullableString != null) {
  print(nullableString.length);
}

// null チェック演算子
print(nullableString?.length ?? 0);

// null アサーション演算子（null でないことを保証）
print(nullableString!.length);  // null の場合はエラー
```

---

## ベストプラクティス

### 1. const を積極的に使う

```dart
// 良い例
const Text('Hello')
const SizedBox(height: 16)

// 悪い例
Text('Hello')
SizedBox(height: 16)
```

### 2. async/await を使用（then チェーンは禁止）

```dart
// 良い例
Future<void> loadData() async {
  final data = await fetchData();
  // 処理
}

// 悪い例
fetchData().then((data) {
  // 処理
});
```

### 3. UIロジックとビジネスロジックを分離

```dart
// 良い例：ビジネスロジックを別クラスに
class CounterState {
  int count = 0;
  void increment() => count++;
}

// 悪い例：Widget内にビジネスロジック
class _MyWidgetState extends State<MyWidget> {
  int count = 0;
  void increment() {
    // 複雑なビジネスロジック...
    count++;
  }
}
```

### 4. リソースの適切な解放

```dart
@override
void dispose() {
  _controller.dispose();  // 必ず解放
  _subscription.cancel();
  super.dispose();
}
```

### 5. DartDoc を書く

```dart
/// カウンターをインクリメントします
///
/// [count] を1増やします。
/// カウンターが100を超える場合は何もしません。
void incrementCounter() {
  if (count < 100) {
    count++;
  }
}
```

### 6. 命名規則

- クラス名：PascalCase（`MyWidget`）
- ファイル名：snake_case（`my_widget.dart`）
- 変数・メソッド名：camelCase（`myVariable`）
- プライベート：`_` で始める（`_privateField`）
- 定数：lowerCamelCase または UPPER_CASE（`appName` または `APP_NAME`）

### 7. ファイル構成

```
lib/
├── main.dart
├── core/              # 定数・例外・テーマ・ユーティリティ
├── features/          # 各機能（feature）ごとのモジュール
│   └── <feature>/
│       ├── presentation/
│       ├── application/
│       ├── domain/
│       └── infrastructure/
└── shared/           # 共通Widget・共通サービス
```

### 8. エラーハンドリング

- 非同期処理では必ず try-catch を使用
- `mounted` チェックを忘れずに
- ユーザーフレンドリーなエラーメッセージを表示

### 9. テスト

```dart
// widget_test.dart
testWidgets('カウンターが正しく動作する', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  
  expect(find.text('0'), findsOneWidget);
  
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  
  expect(find.text('1'), findsOneWidget);
});
```

### 10. パフォーマンス

- `const` を積極的に使う
- `ListView.builder` で長いリストを表示
- 不要な再構築を避ける
- 画像は適切なサイズにリサイズ

---

## 参考リンク

- [Dart公式ドキュメント](https://dart.dev/guides)
- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://docs.flutter.dev/development/best-practices)

