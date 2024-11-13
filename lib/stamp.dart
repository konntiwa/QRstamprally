import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StampPage extends StatefulWidget {
  const StampPage({Key? key}) : super(key: key);

  @override
  State<StampPage> createState() => _QRKeyDisplayPageState();
}

class _QRKeyDisplayPageState extends State<StampPage> {
  List<Map<String, dynamic>>? _userKeys;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserKeys();
  }

  Future<void> _loadUserKeys() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('keys')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _userKeys = querySnapshot.docs
            .map((doc) => {
          'key': doc.data()['key'],
          'name': doc.data()['name'],
          'timestamp': doc.data()['timestamp'],
        })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user keys: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStampImage(String imagePath) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('画像の読み込みエラー: $error');
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeysDisplay(List<Map<String, dynamic>> keys) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'スタンプページ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.asset('images/otya.png'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '獲得したスタンプ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${keys.length} 個',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final item = keys[index];
                final timestamp = item['timestamp'] as Timestamp?;
                final dateStr = timestamp != null
                    ? '${timestamp.toDate().year}/${timestamp.toDate().month}/${timestamp.toDate().day}'
                    : '日付なし';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: _buildStampImage(item['key']),
                    title: Text(item['name'] ?? '名称不明のスタンプ'),
                    subtitle: Text('獲得日: $dateStr'),
                    trailing: Text(
                      '# ${index + 1}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_userKeys != null && _userKeys!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'スタンプギャラリー',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: keys.length,
                    itemBuilder: (context, index) {
                      final item = keys[index];
                      return _buildStampImage(item['key']);
                    },
                  ),
                ],
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
        title: const Text("スタンプページ"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _userKeys == null || _userKeys!.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/otya.png'),
                const SizedBox(height: 16),
                const Text('まだスタンプがありません'),
                const Text('QRコードをスキャンしてスタンプを集めましょう！'),
              ],
            ),
          )
              : _buildKeysDisplay(_userKeys!),
        ),
      ),
    );
  }
}