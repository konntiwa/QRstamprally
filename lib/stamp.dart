import 'package:flutter/material.dart';

import'package:flutter/material.dart';

class StampPage extends StatelessWidget {
  const StampPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),body: Center( // Wrap with Center for centering
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        children: [
          // Theme Setting
          ListTile(
            title: const Text('Dark Theme'),
            trailing: Switch(
              value: false, // Replace with actual theme state
              onChanged: (value) {
                // Handle theme change
              },
            ),
          ),
          // Notification Setting
          ListTile(
            title: const Text('Notifications'),
            trailing: Switch(
              value: true, // Replacewith actual notification state
              onChanged: (value) {
                // Handle notification change
              },
            ),
          ),
          // Language Setting
          ListTile(
            title: const Text('Language'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to language selection screen
            },
          ),
          // About Section
          ListTile(
            title: const Text('About'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to about screen
            },
          ),
        ],
      ),
    ),
    );
  }
}