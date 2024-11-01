import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test5/auth.dart';
import 'package:test5/widget/BottomTab.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//kuga test
void main() async{
  WidgetsFlutterBinding.ensureInitialized(); //async await が時間かかるのでそのお知らせ？
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLogin = FirebaseAuth.instance.currentUser != null;
    return MaterialApp(  //アプリ全体の画面を管理
      title: 'Flutterデモ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLogin ? BottomTabPage() : LoginPage(), // BottomTabPageを最初のページに設定
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(   //ページ単体の画面を管理
      appBar: AppBar(
        title: const Text('Flutterデモ ホームページ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ボタンを押しても何も起こりません'),
            ElevatedButton(
              onPressed: null, // 機能しないように設定
              child: Text('次へ（飾り）'),
            ),
          ],
        ),
      ),
    );
  }
}
