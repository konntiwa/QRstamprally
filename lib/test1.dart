import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class test1Page extends StatefulWidget {
  const test1Page({Key? key}) : super(key: key);

  @override
  State<test1Page> createState() => _QRKeyDisplayPageState();
}

class _QRKeyDisplayPageState extends State<test1Page> {
  List<Map<String, dynamic>>? _qrKeyData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQRKeyData();
  }

  Future<void> _loadQRKeyData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('qr_to_key').get();
      setState(() {
        _qrKeyData = querySnapshot.docs.map((doc) => doc.data()).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching QR to Key data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
            Image.asset('images/otya.png'),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _qrKeyData == null || _qrKeyData!.isEmpty
              ? const Center(child: Text('データが見つかりません'))
              : _buildQRKeyDisplay(_qrKeyData!),
        ),
      ),
    );
  }
}