import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:test5/main.dart';
import 'package:test5/stamp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController controller = MobileScannerController();
  bool hasScanned = false;

  Future<Map<String, dynamic>?> _validateQRCode(String scannedCode) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('qr_to_key')
          .where('QRcode', isEqualTo: scannedCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('有効なQRコードです: $scannedCode');
        return querySnapshot.docs.first.data();
      } else {
        print('無効なQRコードです: $scannedCode');
        return null;
      }
    } catch (e) {
      print('QRコード検証中にエラーが発生: $e');
      return null;
    }
  }

  Future<bool> _isKeyExists(String key) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ユーザーが認証されていません');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('keys')
          .where('key', isEqualTo: key)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('key存在チェック中にエラーが発生: $e');
      throw e;
    }
  }

  Future<void> _copyKeyToUser(Map<String, dynamic> qrData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ユーザーが認証されていません');

      final exists = await _isKeyExists(qrData['key']);
      if (exists) {
        throw Exception('このスタンプは既に獲得済みです');
      }

      final userKeysRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('keys');

      await userKeysRef.add({
        'key': qrData['key'],
        'name': qrData['name'], // 名前の情報を追加
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('keyとnameをユーザーのコレクションにコピーしました');
    } catch (e) {
      print('keyとnameのコピー中にエラーが発生: $e');
      throw e;
    }
  }

  Future<void> _handleDetection(BuildContext context, BarcodeCapture capture) async {
    if (hasScanned) return;

    setState(() {
      hasScanned = true;
    });

    try {
      await controller.stop();

      final String? barcode = capture.barcodes.first.rawValue;

      if (barcode == null) {
        throw Exception('QRコードを読み取れませんでした');
      }

      print("バーコード is ...$barcode");

      final qrData = await _validateQRCode(barcode);
      final isValid = qrData != null;

      if (context.mounted) {
        if (isValid) {
          try {
            await _copyKeyToUser(qrData);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("「${qrData['name']}」のスタンプを獲得しました！"),
                  backgroundColor: Colors.blueAccent,
                  duration: const Duration(milliseconds: 600)
              ),
            );

            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StampPage())
            );
          } catch (e) {
            String errorMessage = "エラーが発生しました。";
            if (e.toString().contains('既に獲得済み')) {
              errorMessage = "このスタンプは既に獲得済みです。";
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.orange,
                  duration: const Duration(milliseconds: 600)
              ),
            );

            setState(() {
              hasScanned = false;
            });
            await controller.start();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("無効なQRコードです。"),
                backgroundColor: Colors.red,
                duration: Duration(milliseconds: 600)
            ),
          );

          setState(() {
            hasScanned = false;
          });
          await controller.start();
        }
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("エラーが発生しました。もう一度スキャンしてください。"),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          hasScanned = false;
        });
        await controller.start();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QRコードをスキャン')),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) => _handleDetection(context, capture),
      ),
    );
  }
}