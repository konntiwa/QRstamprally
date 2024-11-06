import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test5/debug.dart';
import 'package:test5/register.dart';

// ログインページのStatefulWidget
// StatefulWidgetを使用することで、画面上の状態（パスワードの表示/非表示など）を管理できます
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 画面の状態を管理する変数
  bool _isPasswordVisible = false;  // パスワードの表示/非表示を管理
  bool _rememberMe = true;         // Remember meチェックボックスの状態を管理

  // フォームのキーとテキストフィールドのコントローラー
  // GlobalKeyを使用してフォームの状態を管理し、バリデーションを行います
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();    // メールアドレス入力用
  final _passwordController = TextEditingController(); // パスワード入力用

  // コントローラーの解放
  // メモリリークを防ぐために、ウィジェットが破棄されるときにコントローラーを解放します
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Card(
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 350),  // カードの最大幅を設定
              child: SingleChildScrollView(  // スクロール可能にする
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ロゴ表示
                    const FlutterLogo(size: 100),
                    _gap(),

                    // ウェルカムメッセージ
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Welcome to Flutter!",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),

                    // サブタイトル
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Enter your email and password to continue.",
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _gap(),

                    // メールアドレス入力フィールド
                    ElevatedButton(onPressed:(){
                      Navigator.push(context, MaterialPageRoute(builder:(context)=>SignUpPage()));
                    }, child: Text("アカウントの作成はこちらから")),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        // メールアドレスの入力チェック
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        // メールアドレスの形式チェック
                        bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value);
                        if (!emailValid) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _gap(),

                    // パスワード入力フィールド
                    TextFormField(
                      controller: _passwordController,
                      validator: (value) {
                        // パスワードの入力チェック
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        // パスワードの長さチェック
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      obscureText: !_isPasswordVisible,  // パスワードの表示/非表示を制御
                      decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          border: const OutlineInputBorder(),
                          // パスワードの表示/非表示を切り替えるアイコンボタン
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          )
                      ),
                    ),
                    _gap(),

                    // Remember meチェックボックス
                    CheckboxListTile(
                      value: _rememberMe,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _rememberMe = value;
                        });
                      },
                      title: const Text('Remember me'),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.all(0),
                    ),
                    _gap(),

                    // サインインボタン
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)
                          ),
                        ),
                        onPressed: () async {
                          // フォームのバリデーションを実行
                          if (_formKey.currentState?.validate() ?? false) {
                            // ここにログイン処理を実装
                            // 以下は実装例です：
                            try {
                              final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text
                              );
                              Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>DebugPage()));
                              //Replacementにすることで戻れなくする
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                print('No user found for that email.');
                              } else if (e.code == 'wrong-password') {
                                print('Wrong password provided for that user.');
                              }
                            }

                            // 1. ローディング表示を開始する場合:
                            // setState(() => _isLoading = true);

                            // 2. APIを使用してログイン処理を実行する場合:
                            // try {
                            //   final response = await loginApi.login(
                            //     email: _emailController.text,
                            //     password: _passwordController.text,
                            //   );
                            //
                            //   if (response.success) {
                            //     // ログイン成功時の処理
                            //     // 例: トークンの保存
                            //     await saveToken(response.token);
                            //
                            //     // ホーム画面への遷移
                            //     Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => const HomePage(),
                            //       ),
                            //     );
                            //   }
                            // } catch (e) {
                            //   // エラー処理
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(content: Text(e.toString())),
                            //   );
                            // } finally {
                            //   // ローディング表示を終了
                            //   setState(() => _isLoading = false);
                            // }

                            // 現在は入力値をコンソールに出力するのみ
                            print('Email: ${_emailController.text}');
                            print('Password: ${_passwordController.text}');
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ウィジェット間のスペースを作成するユーティリティメソッド
  Widget _gap() => const SizedBox(height: 16);
}