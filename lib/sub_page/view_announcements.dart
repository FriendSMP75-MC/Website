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
    final String safeTitle = title?.toString() ?? 'Announcement';
    final String safeBody = body?.toString() ?? '';
    final bool isMobile = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      appBar: AppbarPage(customTitle: 'Announcements', backArrow: true),
      endDrawer: NavDrawer(
        currentPage: 'Announcements',
        parentContext: context,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF091323), Color(0xFF0F1D33), Color(0xFF091323)],
          ),
        ),
        child: safeBody.trim().isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 56,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'This announcement has no content yet.',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 12 : 18,
                      18,
                      isMobile ? 12 : 18,
                      16,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isMobile ? 16 : 22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white24),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A3656), Color(0xFF16516F)],
                            ),
                          ),
                          child: Text(
                            safeTitle,
                            style: TextStyle(
                              fontSize: isMobile ? 25 : 34,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Markdown(
                                data: safeBody,
                                selectable: true,
                                padding: EdgeInsets.all(isMobile ? 14 : 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
