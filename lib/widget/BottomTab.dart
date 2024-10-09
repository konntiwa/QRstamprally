import 'package:flutter/material.dart';
import 'package:test5/Settings.dart';
import 'package:test5/debug.dart';
import 'package:test5/main.dart';
import 'package:test5/scan_file.dart';

class BottomTabPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BottomTabPageState();
  }
}

class _BottomTabPageState extends State<BottomTabPage> {

  int _currentIndex = 0;
  final _pageWidgets = [
    SettingPage(),
    ScanPage(),
    DebugPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ぷりくがぷりくが'),
      ),
      body: _pageWidgets.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label:'設定'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_album), label:'スキャン'),
          BottomNavigationBarItem(icon: Icon(Icons.abc_rounded),label:'debug')
        ],
        currentIndex: _currentIndex,
        fixedColor: Colors.blueAccent,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  void _onItemTapped(int index) => setState(() => _currentIndex = index );
}
