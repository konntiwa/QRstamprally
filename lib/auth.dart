import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test5/debug.dart';
import 'package:test5/main.dart';
import 'package:test5/register.dart';
import 'package:test5/widget/BottomTab.dart';

// UserManagementクラス：Firestoreを使用してユーザー情報を管理するためのクラス
class UserManagement {
  // Firestoreのインスタンスを静的フィールドとして保持
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ユーザーデータが存在しない場合に作成するメソッド
  static Future<void> createUserIfNotExists({
    required String userId,    // Firebase Authenticationから取得したUID
    required String username,
  }) async {
    // users コレクション内の特定のユーザーIDのドキュメントを参照
    final userRef = _firestore.collection('users').doc(userId);

    try {
      // ドキュメントの存在確認
      final docSnapshot = await userRef.get();

      //ユーザードキュメント配下のkeyコレクションを確認
      final keysRef = userRef.collection('keys').doc('default');
      final keysSnapshot = await keysRef.get();


      // ドキュメントが存在しない場合のみ新規作成
      if (!docSnapshot.exists) {
        await userRef.set({
          'mail': username,
        });
        if (!keysSnapshot.exists) {
          await keysRef.set({
          });
        }
        print('New user data created for ID: $userId');
      }

    } catch (e) {
      print('Error creating user data: $e');
      rethrow;  // エラーを上位に伝播
    }
  }
}



// ログインページのメインウィジェット
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // UIの状態を管理する変数
  bool _isPasswordVisible = false;  // パスワードの表示/非表示
  bool _rememberMe = true;         // ログイン情報保存のチェックボックス
  bool _isLoading = false;         // ローディング状態

  // フォームのキーとテキストフィールドのコントローラー
  final _formKey = GlobalKey<FormState>();  // フォームのバリデーション用
  final _emailController = TextEditingController();    // メールアドレス入力用
  final _passwordController = TextEditingController(); // パスワード入力用

  // メモリリーク防止のためのコントローラー解放
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // エラーメッセージを表示するヘルパーメソッド
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
//sharedpreferencesを利用したrememberMeの状態保存等

  Future<void> _load_setting()async {
  final pp = await SharedPreferences.getInstance();
  setState(() {
    _rememberMe = pp.getBool('rememberMe') ?? false; //falseがデフォ値
  });
  }

  Future<void> _save_setting() async{
    final pp = await SharedPreferences.getInstance();
    await pp.setBool('rememberMe', _rememberMe);
  }

  // ログイン処理を行うメソッド
  Future<void> _handleLogin() async {
    // フォームのバリデーションチェック
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // ローディング状態を開始
    setState(() => _isLoading = true);

    try {
      // Firebase Authenticationでログイン
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // ログイン成功時の処理
      if (credential.user != null) {
        // Firestoreにユーザーデータが存在しない場合は作成
        await UserManagement.createUserIfNotExists(
          userId: credential.user!.uid,
          username: credential.user!.email ?? 'Anonymous',

        );

        // ウィジェットがまだマウントされている場合のみ画面遷移
        if (mounted) {
          await ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("ログインしました"),
                duration: Duration(seconds: 1),
              ));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  BottomTabPage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Firebase認証時のエラーハンドリング
      String errorMessage = 'An error occurred';

      // エラーコードに応じたメッセージを設定
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'メールアドレスが登録されていません。';
          break;
        case 'wrong-password':
          errorMessage = 'パスワードが間違っています。';
          break;
        case 'invalid-email':
          errorMessage = '無効なメールアドレスです。';
          break;
        case 'user-disabled':
          errorMessage = 'このアカウントは無効になっています。';
          break;
        default:
          errorMessage = 'ログインに失敗しました。もう一度お試しください。';
      }

      _showErrorSnackBar(errorMessage);
    } catch (e) {
      // その他の予期せぬエラーの処理
      _showErrorSnackBar('予期せぬエラーが発生しました。');
      print(e);
    } finally {
      // ウィジェットがまだマウントされている場合のみ状態を更新
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                    // アプリロゴの表示
                    const FlutterLogo(size: 100),
                    _gap(),

                    // ウェルカムメッセージ
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "わああああああああ",
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

                    // アカウント作成ページへの遷移ボタン
                    ElevatedButton(
                      // ローディング中は無効化
                      onPressed: _isLoading
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                      },
                      child: const Text("アカウントの作成はこちらから"),
                    ),
                    _gap(),

                    // メールアドレス入力フィールド
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isLoading,  // ローディング中は入力を無効化
                      // 入力値のバリデーション
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'メールアドレスを入力してください';
                        }
                        // メールアドレスの形式チェック
                        bool emailValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        ).hasMatch(value);
                        if (!emailValid) {
                          return '有効なメールアドレスを入力してください';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'メールアドレス',
                        hintText: 'メールアドレスを入力',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _gap(),

                    // パスワード入力フィールド
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,  // ローディング中は入力を無効化
                      // パスワードのバリデーション
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'パスワードを入力してください';
                        }
                        if (value.length < 6) {
                          return 'パスワードは6文字以上である必要があります';
                        }
                        return null;
                      },
                      obscureText: !_isPasswordVisible,  // パスワードの表示/非表示
                      decoration: InputDecoration(
                        labelText: 'パスワード',
                        hintText: 'パスワードを入力',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: const OutlineInputBorder(),
                        // パスワードの表示/非表示を切り替えるボタン
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: _isLoading
                              ? null
                              : () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    _gap(),

                    // ログイン情報保存のチェックボックス
                    CheckboxListTile(
                      value: _rememberMe,
                      enabled: !_isLoading,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _rememberMe = value;
                        });
                      },
                      title: const Text('ログイン情報を保存'),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.all(0),
                    ),
                    _gap(),

                    // ログインボタン
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleLogin,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          // ローディング中はプログレスインジケータを表示
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'ログイン',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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