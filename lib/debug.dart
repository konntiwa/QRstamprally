import 'package:flutter/material.dart';
import 'package:test5/scan_file.dart';
import 'package:test5/stamp.dart';

class DebugPage extends StatelessWidget {
const DebugPage({Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Debug Page'),
),
body: Stack(
// Stackを使って複数のウィジェットを重ねて配置します。
children: <Widget>[
Center(
// Centerは1つの子ウィジェットを中央に配置します。
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: <Widget>[
const Text(
'これはデバッグ用のページです',
style: TextStyle(fontSize: 18),
),
const SizedBox(height: 20),
const ElevatedButton(
onPressed: null,
child: Text('ボタン1'),
),


const SizedBox(height: 10),
ElevatedButton(
onPressed:(){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>const StampPage()));
},
child: const Text('スタンプラリーページへ'),
),


const SizedBox(height: 10),
const ElevatedButton(
onPressed: null,
child: Text('ボタン3'),
),


],
),
),
Align(
// Alignを使って画面の右下にアイテムを配置します。
alignment: Alignment.bottomRight, // 右下に配置
child: Padding(
padding: const EdgeInsets.all(16.0),
child: ElevatedButton(
onPressed:(){
  Navigator.push(context, MaterialPageRoute(builder: (context) => ScanPage()));
},
child: const Text('スキャン開始'),
),
),
),
],
),
);
}
}
