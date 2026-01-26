import 'package:flutter/material.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/widgets/announcement_preview.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/nav_drawer.dart';

class ListAnnouncements extends StatefulWidget {
  const ListAnnouncements({super.key});

  @override
  State<ListAnnouncements> createState() => _ListAnnouncementsState();
}

class _ListAnnouncementsState extends State<ListAnnouncements> {
  List<dynamic> announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAnnouncementList();
  }

  Future<void> _getAnnouncementList() async {
    final result = await BackendData.getAnnouncements();
    if (result != null) {
      setState(() {
        announcements = result.reversed.toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: NavDrawer(
        currentPage: 'Announcements',
        parentContext: context,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              // Mobile
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return ListView.builder(
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final announcement =
                          announcements[index] as Map<String, dynamic>;
                      return AnnouncementPreview(announcement: announcement);
                    },
                  );
                } else {
                  // Desktop
                  int crossAxisCount;
                  double aspectRatio;
                  if (constraints.maxWidth < 600) {
                    // Mobile
                    crossAxisCount = 1;
                    aspectRatio = 0.9;
                  } else if (constraints.maxWidth < 1000) {
                    crossAxisCount = 1;
                    aspectRatio = 1; // Tablet or small desktop
                  } else {
                    crossAxisCount = 3;
                    aspectRatio = 0.9; // Large desktop
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      childAspectRatio: aspectRatio,
                    ),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final announcement =
                          announcements[index] as Map<String, dynamic>;
                      return AnnouncementPreview(announcement: announcement);
                    },
                  );
                }
              },
            ),
    );
  }
}
