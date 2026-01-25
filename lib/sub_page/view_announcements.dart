import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/nav_drawer.dart';

class ViewAnnouncement extends StatelessWidget {
  final String title;
  final String body;

  const ViewAnnouncement({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(customTitle: 'Announcements', backArrow: true),
      endDrawer: NavDrawer(
        currentPage: 'Announcemnets',
        parentContext: context,
      ),
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(child: Markdown(data: body)),
        ],
      ),
    );
  }
}
