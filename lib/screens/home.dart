import 'package:flutter/material.dart';
import 'package:mac_hunter/widgets/input_pane.dart';
import 'package:mac_hunter/widgets/local_ip_widget.dart';
import 'package:mac_hunter/widgets/output_pane.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: Text('MAC Lookup'),
        actions: [
          LocalIpWidget(),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(constraints: BoxConstraints(maxWidth: 300), child: InputPane()),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: OutputPane()),
        ],
      ),
    );
  }
}