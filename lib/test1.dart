import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// StatefulWidgetを使用して、データの動的な更新に対応
class test1Page extends StatefulWidget {
  const test1Page({Key? key}) : super(key: key);

  @override
  State<test1Page> createState() => _QRKeyDisplayPageState();
}

class _QRKeyDisplayPageState extends State<test1Page> {
  // Firestoreから取得したデータを保存するリスト
  List<Map<String, dynamic>>? _qrKeyData;
  // データ読み込み中かどうかを示すフラグ
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // ウィジェットが初期化されたときにFirestoreからデータを読み込む
    _loadQRKeyData();
  }

  // Firestoreからデータを非同期で読み込む関数
  Future<void> _loadQRKeyData() async {
    try {
      // FirebaseFirestore.instanceでFirestoreにアクセス
      // .collection('qr_to_key')で'qr_to_key'というコレクションを指定
      // .get()でデータを取得
      final querySnapshot = await FirebaseFirestore.instance.collection('qr_to_key').get();

      // setState()を使用してUIを更新
      setState(() {
        // querySnapshot.docsで取得したドキュメントの配列にアクセス
        // .map()で各ドキュメントのデータをMap形式に変換
        // .toList()でList形式に変換
        _qrKeyData = querySnapshot.docs.map((doc) => doc.data()).toList();
        _isLoading = false;
      });
    } catch (e) {
      // エラーが発生した場合はコンソールに出力
      print('Error fetching QR to Key data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 取得したデータを表示するウィジェットを構築
  Widget _buildQRKeyDisplay(List<Map<String, dynamic>> data) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QRコードとキーの一覧',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // 画像の表示（pubspec.yamlでアセットの設定が必要）
            Image.asset('images/otya.png'),

            const Divider(),
            // データをリスト表示
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                // Firestoreから取得したデータの各項目にアクセス
                final item = data[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'QRコード: ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Expanded(
                              // item['QRcode']でFirestoreのフィールドにアクセス
                              // nullの場合は'N/A'を表示
                              child: Text(item['QRcode']?.toString() ?? 'N/A'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'キー: ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Expanded(
                              // item['key']でFirestoreのフィールドにアクセス
                              child: Text(item['key']?.toString() ?? 'N/A'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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
        title: const Text('QRコードとキーの一覧'),
      ),
      // SingleChildScrollViewでスクロール可能に
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
          // データ読み込み中はローディング表示
              ? const Center(child: CircularProgressIndicator())
          // データが空の場合はメッセージを表示
              : _qrKeyData == null || _qrKeyData!.isEmpty
              ? const Center(child: Text('データが見つかりません'))
          // データがある場合は_buildQRKeyDisplay関数でUI構築
              : _buildQRKeyDisplay(_qrKeyData!),
        ),
      ),
    );
  }
}