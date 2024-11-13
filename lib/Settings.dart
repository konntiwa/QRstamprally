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
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? userData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
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
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('ユーザー名'),
              subtitle: Text(userData?['username'] ?? '未設定'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('年齢'),
              subtitle: Text('${userData?['age'] ?? '未設定'} 歳'),
            ),
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildUserDataCard(),

          // Account Settings Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'アカウント設定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text("プロフィール編集"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    ).then((_) => _loadUserData());
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text("パスワード変更"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const test1Page()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Other Settings Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'その他',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("アプリの使い方"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // アプリの使い方ページへの遷移
              },
            ),
          ),

          const SizedBox(height: 24.0),

          // Logout Button
          if (_auth.currentUser != null) ...[
            ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                setState(() {
                  userData = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ログアウトしました'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                "ログアウト",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ).then((_) => _loadUserData());
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text("ログイン"),
            ),
          ],
        ],
      ),
    );
  }
}