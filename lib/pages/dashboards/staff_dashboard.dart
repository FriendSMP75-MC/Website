import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:server_site/pages/dashboards/subpage/staff/staff_announcement.dart';
import 'package:server_site/widgets/dashboardtitles.dart';
import 'package:server_site/widgets/footer.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Staff Dashboard',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return GridView.count(
                  crossAxisCount: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                  padding: const EdgeInsets.all(8),
                  children: [
                    // Announcment App
                    DashboardTiles(
                      title: 'Announcement',
                      color: const Color(0xFF5B3FD6),
                      icon: Icons.campaign_rounded,
                      actionLabel: 'Manage',
                      subText:
                          'Ready to make or manage an announcement? Lets inform players about new updates!',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    Staffannouncements(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return SlideTransition(
                                    position: Tween(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                    ),

                    // Gallery App
                    DashboardTiles(
                      title: 'Gallery',
                      color: const Color(0xFF1F7BD9),
                      icon: Icons.photo_library_rounded,
                      actionLabel: 'Upload',
                      onTap: () {
                        context.push('/staff/gallery');
                      },
                      subText: 'Ready to make or upload an Group Photo?',
                    ),

                    DashboardTiles(
                      title: 'Approve Gallery Request',
                      color: const Color(0xFF228B63),
                      icon: Icons.fact_check_rounded,
                      actionLabel: 'Review',
                      onTap: () {
                        context.push('/staff/gallery-requests');
                      },
                      subText:
                          'Review and approve members\' gallery memory requests.',
                    ),
                  ],
                );
              } else {
                return GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.75,
                  padding: const EdgeInsets.all(8),
                  children: [
                    //Announcment App
                    DashboardTiles(
                      title: 'Announcement',
                      color: const Color(0xFF5B3FD6),
                      icon: Icons.campaign_rounded,
                      actionLabel: 'Manage',
                      subText:
                          'Ready to make or manage an announcement? Lets inform players about new updates!',
                      onTap: () {
                        context.push('/staff/announcements');
                      },
                    ),

                    // Gallery App
                    DashboardTiles(
                      title: 'Gallery',
                      color: const Color(0xFF1F7BD9),
                      icon: Icons.photo_library_rounded,
                      actionLabel: 'Upload',
                      onTap: () {
                        context.push('/staff/gallery');
                      },
                      subText: 'Ready to make or upload an Group Photo?',
                    ),

                    DashboardTiles(
                      title: 'Approve Gallery Request',
                      color: const Color(0xFF228B63),
                      icon: Icons.fact_check_rounded,
                      actionLabel: 'Review',
                      onTap: () {
                        context.push('/staff/gallery-requests');
                      },
                      subText:
                          'Review and approve members\' gallery memory requests.',
                    ),
                  ],
                );
              }
            },
          ),
        ),

        // Footer
        SizedBox(height: 50),
        MyFooter(),
      ],
    );
  }
}
