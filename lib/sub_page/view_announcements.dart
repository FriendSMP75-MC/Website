import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/nav_drawer.dart';

class ViewAnnouncement extends StatelessWidget {
  // Use dynamic to prevent "minified type" errors on Web/Vercel
  final dynamic title;
  final dynamic body;

  const ViewAnnouncement({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    // Safely cast to String. If null, use a fallback to prevent .trim() crashes.
    final String safeTitle = title?.toString() ?? "Announcement";
    final String safeBody = body?.toString() ?? "";
    
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppbarPage(customTitle: 'Announcements', backArrow: true),
      endDrawer: NavDrawer(
        currentPage: 'Announcements',
        parentContext: context,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;

          if (safeBody.trim().isEmpty) {
            // Show a friendly message if the announcement body is empty
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.error_outline, color: Colors.red, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'This announcement has no content.\nPlease check back later or contact the admin.',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
                child: Center(
                  child: Text(
                    safeTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
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
                      // Prevents negative width crashes on ultra-small screens
                      width: isMobile 
                          ? screenWidth * 0.95 
                          : (screenWidth > 1000 ? 800 : screenWidth - 100),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.5, color: Colors.white24),
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Markdown(
                          data: safeBody,
                          selectable: true,
                          shrinkWrap: false, // Critical for performance inside Expanded
                          padding: const EdgeInsets.all(20),
                          styleSheet: MarkdownStyleSheet(
                            h1: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            h3: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
                            p: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
                            listBullet: const TextStyle(fontSize: 16, color: Colors.white),
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
      ),
    );
  }
}