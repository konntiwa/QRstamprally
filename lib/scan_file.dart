import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:test5/main.dart';
import 'package:test5/stamp.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({Key? key}) : super(key: key);

  // 検出処理を別メソッドとして切り出し(claude)
  void _handleDetection(BuildContext context, BarcodeCapture capture) async {
    final String? barcode = capture.barcodes.first.rawValue;

    await ScaffoldMessenger
        .of(context)
        .showSnackBar(
      const SnackBar(
        content: Text("読み込み完了!!"),
        duration: Duration(seconds: 1),
      ),
    )
        .closed;

     if (context.mounted) {
      print("バーコード is ...$barcode");
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StampPage())
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QRコードをスキャン')),
      body: MobileScanner(
        onDetect: (capture) {
          // 別メソッドを呼び出し
          _handleDetection(context, capture);
        },
      ),
    );
  }
}