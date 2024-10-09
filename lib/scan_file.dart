import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:test5/main.dart';

//QRコードを2回短時間でカメラ起動するとエラーが起きるのは仕様っぽい
// QRコードをスキャンする画面を表示するウィジェット
class ScanPage extends StatelessWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 画面全体を構成するScaffoldウィジェット
    return Scaffold(
      // 画面上部のAppBarに「QRコードをスキャン」というタイトルを表示
      appBar: AppBar(title: const Text('QRコードをスキャン')),
      body: MobileScanner(
        // MobileScannerはカメラを使用してQRコードやバーコードをスキャンするウィジェット
        // fit: BoxFit.contain,  // カメラのビューが画面にフィットするように調整する（必要に応じて有効化）

        // QRコードやバーコードが検出されたときに呼ばれるコールバック
        onDetect: (capture) {
          // 検出されたバーコードのリスト
          final List<Barcode> barcodes = capture.barcodes;
          //スキャン完了後に完了表示。その後ページ遷移
          const snackBar = SnackBar(
            content:Text("読み込み完了!!"),
            duration:Duration(seconds:3),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          const Text("show snack bar");

          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyApp())
          );

          // 必要に応じて画像も取得できるが、ここではコメントアウト
          // final Uint8List? image = capture.image;

          // 検出されたすべてのバーコードを処理
          for (final barcode in barcodes) {
            // 各バーコードの生データ(rawValue)をデバッグ用に出力
            debugPrint('スキャン完了! バーコード... ${barcode.rawValue}');

          }
        },
      ),
    );
  }
}
