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
    final bool hasBody = body.trim().isNotEmpty;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppbarPage(customTitle: 'Announcements', backArrow: true),
      endDrawer: NavDrawer(
        currentPage: 'Announcements',
        parentContext: context,
      ),
      body: hasBody
          ? LayoutBuilder(
              builder: (context, constraints) {
                // Determine layout based on width
                bool isMobile = constraints.maxWidth < 600;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
                      child: Center(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24, // Increased size for title
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12.0 : 40.0,
                          vertical: 10.0,
                        ),
                        child: Center(
                          child: Container(
                            // Safe width calculation to prevent layout crashes
                            width: isMobile ? screenWidth : (screenWidth > 1000 ? 800 : screenWidth - 100),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1.5, color: Colors.white24),
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                              color: Colors.white.withOpacity(0.05),
                            ),
                            // Using Markdown inside Expanded without shrinkWrap 
                            // allows the internal scrollview to work correctly.
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Markdown(
                                data: body,
                                selectable: true,
                                shrinkWrap: false, // Critical: Set to false inside Expanded
                                padding: const EdgeInsets.all(20),
                                styleSheet: MarkdownStyleSheet(
                                  h1: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  h3: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
                                  p: const TextStyle(fontSize: 16, height: 1.5),
                                  listBullet: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.error_outline, color: Colors.red, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Announcement content unavailable.\nPlease use the Announcements page to access announcements.',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}