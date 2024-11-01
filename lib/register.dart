// Firebase Authenticationを使用するために必要なパッケージをインポート
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test5/main.dart';

// StatefulWidgetを継承したSignUpPageクラス
// 状態が変化する（ユーザー入力を受け付ける）ため、StatefulWidgetを使用
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

// SignUpPageの状態を管理するStateクラス
class _SignUpPageState extends State<SignUpPage> {
  // Firebase Authenticationのインスタンスを作成
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // フォームのキー（バリデーションに使用）
  final _formKey = GlobalKey<FormState>();

  // テキストフィールドのコントローラー（入力値の管理に使用）
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // メモリリーク防止のため、使用していないコントローラーを破棄
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          // パディングとサイズ制約を設定
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Form(
            key: _formKey,  // フォームのキーを設定
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // メールアドレス入力フィールド
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    border: OutlineInputBorder(),
                  ),
                  // 入力値の検証
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'メールアドレスを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),  // 余白

                // パスワード入力フィールド
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,  // パスワードを隠す
                  // 入力値の検証
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),  // 余白

                // サインアップボタン
                ElevatedButton(
                  onPressed: () async {
                    // フォームのバリデーションチェック
                    if (_formKey.currentState!.validate()) {
                      try {
                        // Firebase Authenticationでユーザー登録
                        final userCredential = await _auth.createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        // 登録成功時の処理
                        if (userCredential.user != null) {
                          print('ユーザー登録成功');
                          // ここに登録成功後の画面遷移などを記述
                          Navigator.push(context,MaterialPageRoute(builder:(context)=>MyApp()));
                        }
                      } on FirebaseAuthException catch (e) {
                        // エラー発生時にSnackBarでエラーメッセージを表示
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? 'エラーが発生しました')),
                        );
                      }
                    }
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}