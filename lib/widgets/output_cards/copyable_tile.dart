import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableTile extends StatelessWidget {
  const CopyableTile({super.key, required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Clipboard.setData(ClipboardData(text: title));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Copied "$title" to clipboard'), duration: const Duration(seconds: 1)));
      },
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.copy, size: 18, color: Colors.grey),
      mouseCursor: SystemMouseCursors.click,
    );
  }
}