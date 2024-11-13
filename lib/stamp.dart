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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.lightBlue, width: 2),
        color: Colors.lightBlueAccent.withOpacity(0.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          width: 30, // アイコンのサイズを小さく設定
          height: 30, // アイコンのサイズを小さく設定
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
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

  String _formatTimestamp(Timestamp timestamp) {
    // TimestampからDateTimeに変換し、文字列にフォーマット
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _showStampDetail(Map<String, dynamic> stamp) {
    // スタンプの詳細情報を表示するダイアログを表示する
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(stamp['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStampImage(stamp['key']),
              const SizedBox(height: 16),
              Text('押された日時: ${_formatTimestamp(stamp['timestamp'])}'),
              const SizedBox(height: 8),
              // 詳細情報を追加することも可能
              Text('スタンプ名: ${stamp['name']}'),
              // 他に詳細を表示する場所
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      },
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
              'スタンプギャラリー',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3x3 grid
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final item = keys[index];
                return _buildStampImage(item['key']);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              '押された日時',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 8),
            // スタンプギャラリーの下に日時を表示
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: keys.map((item) {
                final timestamp = item['timestamp'];
                final formattedDate = _formatTimestamp(timestamp);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () => _showStampDetail(item),
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            _buildStampImage(item['key']), // アイコンとしてスタンプ画像を表示
                            const SizedBox(width: 8), // アイコンとテキストの間隔
                            Expanded(
                              child: Text(
                                'スタンプ: ${item['name']} - 押された日時: $formattedDate',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis, // 長いテキストが切れるように
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
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
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_userKeys == null || _userKeys!.isEmpty)
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
