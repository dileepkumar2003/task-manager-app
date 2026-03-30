import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDark;
  final Function(bool) onThemeChange;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onThemeChange,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: widget.isDark,
            onChanged: (value) {
              widget.onThemeChange(value);
            },
          ),
          SwitchListTile(
            title: const Text("Notifications"),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }
}