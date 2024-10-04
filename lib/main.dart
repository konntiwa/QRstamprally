import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:test5/scan_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // このウィジェットはアプリケーションのルート（基盤）です。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutterデモ',
      theme: ThemeData(
        // これはアプリケーションのテーマです。
        //
        // 試してみてください: アプリケーションを "flutter run" で実行してください。紫色のツールバーが表示されます。
        // その後、アプリを終了せずに、以下の colorScheme 内の seedColor を Colors.green に変更し、
        // "hot reload" を実行（変更を保存するか、Flutter対応のIDEで "hot reload" ボタンを押すか、
        // コマンドラインで "r" を押す）してみてください。
        //
        // カウンタがリセットされないことに注目してください。アプリケーションの状態は
        // リロード中に失われません。状態をリセットするには、代わりに hot restart を使用してください。
        //
        // これは値だけでなく、コードにも適用されます。ほとんどのコードの変更は
        // hot reload でテストできます。
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutterデモ ホームページ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // このウィジェットはアプリケーションのホームページです。これはステートフルであり、
  // Stateオブジェクト（下で定義）が含まれており、外観に影響を与えるフィールドを持っています。

  // このクラスは状態の構成です。これは、親（この場合はAppウィジェット）によって提供される値
  // （この場合はタイトル）を保持し、Stateのbuildメソッドで使用されます。
  // Widgetサブクラスのフィールドは常に "final" としてマークされます。
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // このsetStateの呼び出しは、Flutterフレームワークにこの状態が変わったことを伝え、
      // buildメソッドを再実行させることで、ディスプレイが更新された値を反映できるようにします。
      // setStateを呼ばずに_counterを変更すると、buildメソッドは再び呼び出されないため、
      // 表示には何も反映されません。
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // setStateが呼ばれるたびにこのメソッドが再実行されます。
    //
    // Flutterフレームワークは、buildメソッドを再実行することを最適化しており、
    // 更新が必要なものだけを再構築できるようになっています。
    // 個々のウィジェットインスタンスを変更するのではなく、再構築する方が効率的です。
    return Scaffold(
      appBar: AppBar(
        // 試してみてください: ここで色を特定の色（例えば Colors.amber）に変更し、
        // hot reload をトリガーして、AppBarの色が他の色は変わらないまま変わるのを確認してください。
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // ここでMyHomePageオブジェクトからApp.buildメソッドで作成された値を取得し、
        // AppBarのタイトルとして使用しています。
        title: Text(widget.title),
      ),
      body: Center(
        // Centerはレイアウトウィジェットで、1つの子ウィジェットを中央に配置します。
        child: Column(
          // Columnもレイアウトウィジェットで、子ウィジェットのリストを縦方向に並べます。
          // デフォルトでは、横方向に子ウィジェットに合わせてサイズを調整し、
          // 親の高さに合わせようとします。
          //
          // Columnには、サイズや子ウィジェットの配置を制御するためのさまざまなプロパティがあります。
          // ここでは、mainAxisAlignment を使用して、子ウィジェットを垂直方向（主軸）の中央に配置しています。
          // 主軸は縦方向で、交差軸は横方向です。
          //
          // 試してみてください: "debug painting" を呼び出し（IDEで "Toggle Debug Paint" アクションを選択するか、
          // コンソールで "p" を押す）と、各ウィジェットのワイヤーフレームが表示されます。
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'ボタンを押した回数:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              child: const Text('次へ'),
              onPressed: () {
                //ここに発火時の動作を記述をする
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScanPage())
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'インクリメント',
        child: const Icon(Icons.add),
      ),// このカンマは自動フォーマットを適用するために使われます。
    );
  }
}
