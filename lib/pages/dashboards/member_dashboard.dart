import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:server_site/widgets/dashboardtitles.dart';
import 'package:server_site/widgets/footer.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Member\'s Dashboard',
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
                    DashboardTiles(
                      title: 'Memories upload request',
                      color: const Color(0xFF198A8E),
                      icon: Icons.auto_stories_rounded,
                      actionLabel: 'Request',
                      onTap: () {
                        context.go('/memories-request');
                      },
                      subText:
                          'Request staff member to add memory to gallery page',
                    ),
                  ],
                );
              } else {
                return GridView.count(
                  crossAxisCount: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3.6,
                  padding: const EdgeInsets.all(8),
                  children: [
                    DashboardTiles(
                      title: 'Memories upload request',
                      color: const Color(0xFF198A8E),
                      icon: Icons.auto_stories_rounded,
                      actionLabel: 'Request',
                      onTap: () {
                        context.go('/memories-request');
                      },
                      subText:
                          'Request staff member to add memory to gallery page',
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
