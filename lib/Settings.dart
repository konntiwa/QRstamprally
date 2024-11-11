import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test5/auth.dart';
import 'package:test5/register.dart';
import 'package:test5/test1.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key, required this.title});

  final String title;

  @override
  State<SettingPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SettingPage> {
  // Firestore インスタンスの取得
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ユーザーデータを保持する変数
  Map<String, dynamic>? userData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 画面表示時にユーザーデータを取得
    _loadUserData();
  }

  // ユーザーデータを取得するメソッド
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // 現在のユーザーIDを取得
      final user = _auth.currentUser;
      if (user != null) {
        // Firestoreからユーザーデータを取得
        final docSnapshot = await _db.collection("users").doc(user.uid).get();

        if (docSnapshot.exists) {
          setState(() {
            userData = docSnapshot.data();
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ユーザーデータの読み込みに失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ユーザーデータ表示用ウィジェット
  Widget _buildUserDataCard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('ログインしていません'),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ユーザー情報',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            // ユーザー名の表示
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('ユーザー名'),
              subtitle: Text(userData?['username'] ?? '未設定'),
            ),
            // 年齢の表示
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('年齢'),
              subtitle: Text('${userData?['age'] ?? '未設定'} 歳'),
            ),
            // アカウント作成日の表示
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('アカウント作成日'),
              subtitle: Text(
                  userData?['createdAt'] != null
                      ? (userData!['createdAt'] as Timestamp).toDate().toString()
                      : '不明'
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // データ更新ボタン
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
        ],
      ),
      body: ListView(
        children: [
          // ユーザーデータの表示
          _buildUserDataCard(),

          // 各種ボタン
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    ).then((_) => _loadUserData()); // ログイン後にデータを再読み込み
                  },
                  child: const Text("ログインページ"),
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    ).then((_) => _loadUserData()); // 登録後にデータを再読み込み
                  },
                  child: const Text("登録ページ"),
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const test1Page()),
                    );
                  },
                  child: const Text("test1"),
                ),


                // ログアウトボタン
                if (_auth.currentUser != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      setState(() {
                        userData = null;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ログアウトしました'),
                            duration: Duration(seconds: 1)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("ログアウト"),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}