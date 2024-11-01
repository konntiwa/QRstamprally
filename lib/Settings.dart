import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test5/auth.dart';
import 'package:test5/register.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key, required this.title});

  final String title;

  @override
  State<SettingPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SettingPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  var db = FirebaseFirestore.instance;
  String firebasedata = "";
  List<String> texts = [];
  void firetest() async{
    await db.collection("users").get().then((event) {
      for (var doc in event.docs) {
        print("${doc.id} => ${doc.data()}");
        setState(() {
          texts.add('${doc.data()}'.toString());
          firebasedata += '${doc.data()}';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(context) =>LoginPage()));
          }, child: Text("ログインページ")),
          ElevatedButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(context)=>SignUpPage()));
          }, child: Text("登録ページ")),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: firetest,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}