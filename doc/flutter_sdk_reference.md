# Flutter SDK リファレンス

Flutter SDKでよく使う機能をまとめたリファレンスです。

## 目次

1. [基本Widget](#基本widget)
2. [レイアウトWidget](#レイアウトwidget)
3. [入力Widget](#入力widget)
4. [ボタンWidget](#ボタンwidget)
5. [ナビゲーション](#ナビゲーション)
6. [状態管理](#状態管理)
7. [ライフサイクル](#ライフサイクル)
8. [非同期処理](#非同期処理)
9. [よく使うクラス](#よく使うクラス)
10. [よく使うメソッド](#よく使うメソッド)

---

## 基本Widget

### MaterialApp
アプリケーションのルートWidget。テーマやルーティングを管理します。

```dart
MaterialApp(
  title: 'アプリ名',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
  ),
  home: const HomePage(),
)
```

### Scaffold
画面の基本構造を提供します。AppBar、Body、FloatingActionButtonなどを配置できます。

```dart
Scaffold(
  appBar: AppBar(title: const Text('タイトル')),
  body: const Center(child: Text('コンテンツ')),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.add),
  ),
)
```

### Text
テキストを表示するWidget。

```dart
Text(
  'Hello World',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
)
```

### Icon
アイコンを表示するWidget。

```dart
const Icon(
  Icons.settings,
  size: 24,
  color: Colors.blue,
)
```

### Container
スタイリングとレイアウトを提供するWidget。

```dart
Container(
  width: 100,
  height: 100,
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey),
  ),
  child: const Text('コンテンツ'),
)
```

### SizedBox
固定サイズのスペースを作成するWidget。

```dart
const SizedBox(width: 16)  // 幅16のスペース
const SizedBox(height: 24)  // 高さ24のスペース
const SizedBox(width: 16, height: 24)  // 両方指定
```

### SafeArea
システムUI（ステータスバーなど）を避けてコンテンツを表示します。

```dart
SafeArea(
  child: Column(
    children: [
      // コンテンツ
    ],
  ),
)
```

---

## レイアウトWidget

### Column
縦方向にWidgetを配置します。

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,  // 縦方向の配置
  crossAxisAlignment: CrossAxisAlignment.start,  // 横方向の配置
  children: [
    const Text('上'),
    const Text('中'),
    const Text('下'),
  ],
)
```

### Row
横方向にWidgetを配置します。

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 横方向の配置
  crossAxisAlignment: CrossAxisAlignment.center,  // 縦方向の配置
  children: [
    const Text('左'),
    const Text('中'),
    const Text('右'),
  ],
)
```

### Expanded
親Widgetの残りのスペースを埋めるWidget。

```dart
Row(
  children: [
    const Text('固定幅'),
    Expanded(  // 残りのスペースを埋める
      child: Container(color: Colors.blue),
    ),
  ],
)
```

### Flexible
Expandedと似ているが、必要最小限のスペースのみ使用します。

```dart
Row(
  children: [
    Flexible(
      flex: 2,  // 比率を指定
      child: Container(color: Colors.blue),
    ),
    Flexible(
      flex: 1,
      child: Container(color: Colors.red),
    ),
  ],
)
```

### Stack
Widgetを重ねて配置します。

```dart
Stack(
  children: [
    Container(color: Colors.blue),  // 背景
    Positioned(  // 位置を指定
      right: 8,
      top: 8,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    ),
  ],
)
```

### SingleChildScrollView
スクロール可能なコンテンツを作成します。

```dart
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      // 長いコンテンツ
    ],
  ),
)
```

### Padding
内側の余白を設定します。

```dart
Padding(
  padding: const EdgeInsets.all(16),  // 全方向
  // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),  // 対称的
  // padding: const EdgeInsets.only(left: 16, top: 8),  // 個別指定
  child: const Text('コンテンツ'),
)
```

---

## 入力Widget

### TextField
テキスト入力フィールド。

```dart
TextField(
  controller: _controller,
  decoration: const InputDecoration(
    labelText: 'ラベル',
    hintText: 'プレースホルダー',
    border: OutlineInputBorder(),
  ),
  onChanged: (text) {
    // テキスト変更時の処理
  },
)
```

### TextEditingController
TextFieldのテキストを管理するコントローラ。

```dart
class _MyWidgetState extends State<MyWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      // テキスト変更を監視
      print(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();  // 必ず破棄する
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}
```

---

## ボタンWidget

### ElevatedButton
浮き上がった見た目のボタン。

```dart
ElevatedButton(
  onPressed: () {
    // ボタンが押された時の処理
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: const Text('ボタン'),
)
```

### TextButton
テキストのみのボタン。

```dart
TextButton(
  onPressed: () {},
  child: const Text('テキストボタン'),
)
```

### IconButton
アイコンのボタン。

```dart
IconButton(
  onPressed: () {},
  icon: const Icon(Icons.settings),
  iconSize: 24,
)
```

### GestureDetector
タップ、ドラッグなどのジェスチャーを検出します。

```dart
GestureDetector(
  onTap: () {
    // タップ時の処理
  },
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
  ),
)
```

---

## ナビゲーション

### Navigator.push
新しい画面に遷移します。

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const NextPage(),
  ),
);
```

### Navigator.pop
前の画面に戻ります。

```dart
Navigator.of(context).pop();
```

### Navigator.push の戻り値を受け取る

```dart
final result = await Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const NextPage(),
  ),
);
// result に NextPage から返された値が入る
```

### PopScope
戻るボタン（Android）やスワイプ（iOS）の動作を制御します。

```dart
PopScope(
  canPop: true,  // 戻れるかどうか
  onPopInvoked: (didPop) {
    // 戻る動作が発生した時の処理
  },
  child: Scaffold(
    // コンテンツ
  ),
)
```

---

## 状態管理

### StatefulWidget
状態を持つWidget。

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('Count: $_counter');
  }
}
```

### StatelessWidget
状態を持たないWidget。

```dart
class MyWidget extends StatelessWidget {
  final String title;

  const MyWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}
```

### setState
状態を更新してUIを再描画します。

```dart
setState(() {
  _counter++;
  // 状態を変更
});
```

---

## ライフサイクル

### initState
Widgetが作成された時に一度だけ呼ばれます。

```dart
@override
void initState() {
  super.initState();
  // 初期化処理
  _controller = TextEditingController();
}
```

### dispose
Widgetが破棄される時に呼ばれます。

```dart
@override
void dispose() {
  // リソースの解放
  _controller.dispose();
  super.dispose();
}
```

### build
UIを構築するメソッド。状態が変更されるたびに呼ばれます。

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    // UIを構築
  );
}
```

### mounted
Widgetがまだツリーに存在するかどうかを確認します。

```dart
if (mounted) {
  setState(() {
    // 安全に状態を更新
  });
}
```

---

## 非同期処理

### Future
非同期処理の結果を表す型（JavaScriptのPromiseに相当）。

```dart
Future<String> fetchData() async {
  await Future.delayed(const Duration(seconds: 1));
  return 'データ';
}
```

### async/await
非同期処理を同期的に書く構文。

```dart
Future<void> loadData() async {
  final data = await fetchData();
  print(data);
}
```

### Future.delayed
指定した時間後に処理を実行します。

```dart
Future.delayed(const Duration(seconds: 2), () {
  print('2秒後');
});
```

### .then()
Futureの結果を受け取ります（async/awaitの方が推奨）。

```dart
fetchData().then((value) {
  print(value);
});
```

---

## よく使うクラス

### BuildContext
Widgetのビルドコンテキスト。NavigatorやThemeなどにアクセスするために使用。

```dart
Navigator.of(context).push(...);
Theme.of(context).primaryColor;
MediaQuery.of(context).size;
```

### ThemeData
アプリのテーマ設定。

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
)
```

### ColorScheme
カラーパレット。

```dart
ColorScheme.fromSeed(seedColor: Colors.blue)
// primary, secondary, error などの色が自動生成される
```

### MediaQuery
画面サイズなどの情報を取得。

```dart
MediaQuery.of(context).size.width  // 画面幅
MediaQuery.of(context).size.height  // 画面高さ
MediaQuery.of(context).padding.top  // ステータスバーの高さ
```

### Duration
時間の長さを表す。

```dart
const Duration(seconds: 2)
const Duration(milliseconds: 500)
const Duration(minutes: 1)
```

### EdgeInsets
余白を表す。

```dart
const EdgeInsets.all(16)  // 全方向16
const EdgeInsets.symmetric(horizontal: 16, vertical: 8)  // 対称的
const EdgeInsets.only(left: 16, top: 8)  // 個別指定
```

### BorderRadius
角丸を設定。

```dart
BorderRadius.circular(8)  // 全角8
BorderRadius.only(
  topLeft: Radius.circular(8),
  topRight: Radius.circular(8),
)
```

### BoxDecoration
Containerの装飾を設定。

```dart
BoxDecoration(
  color: Colors.blue,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: Colors.grey, width: 1),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ],
)
```

### TextStyle
テキストのスタイル。

```dart
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.blue,
  letterSpacing: 1.0,
)
```

### Clipboard
クリップボードにアクセス。

```dart
Clipboard.setData(ClipboardData(text: 'コピーするテキスト'));

final data = await Clipboard.getData(ClipboardFormat.text);
print(data?.text);
```

### ScaffoldMessenger
スナックバーを表示。

```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('メッセージ'),
    duration: Duration(seconds: 2),
  ),
);
```

---

## よく使うメソッド

### WidgetsBinding.instance.addPostFrameCallback
フレーム描画後に処理を実行します。

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  // フレーム描画後の処理
});
```

### runApp
アプリを起動します。

```dart
void main() {
  runApp(const MyApp());
}
```

### super.key
親クラスのコンストラクタにkeyを渡します。

```dart
const MyWidget({super.key});
```

### required
必須パラメータを指定します。

```dart
const MyWidget({
  super.key,
  required this.title,  // 必須
});
```

### const
コンパイル時定数を指定します（パフォーマンス向上）。

```dart
const Text('Hello')  // const を付けると再構築されない
```

---

## 参考リンク

- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [Flutter APIリファレンス](https://api.flutter.dev/)
- [Flutter Widgetカタログ](https://docs.flutter.dev/ui/widgets)

