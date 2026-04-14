import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1080;

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          padding: EdgeInsets.all(isMobile ? 14 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Dashboard',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Manage announcements, gallery content, memory requests, and server controls.',
                style: TextStyle(color: Colors.white70, height: 1.35),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: isMobile
                ? 1
                : isTablet
                ? 2
                : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile
                ? 2.2
                : isTablet
                ? 1.55
                : 1.75,
            padding: const EdgeInsets.all(8),
            children: [
              DashboardTiles(
                title: 'Announcement',
                color: const Color(0xFF5B3FD6),
                icon: Icons.campaign_rounded,
                actionLabel: 'Manage',
                subText: 'Create and publish server updates for players.',
                onTap: () {
                  context.push('/staff/announcements');
                },
              ),
              DashboardTiles(
                title: 'Gallery',
                color: const Color(0xFF1F7BD9),
                icon: Icons.photo_library_rounded,
                actionLabel: 'Upload',
                onTap: () {
                  context.push('/staff/gallery');
                },
                subText: 'Upload new gallery photos for public display.',
              ),
              DashboardTiles(
                title: 'Approve Gallery Request',
                color: const Color(0xFF228B63),
                icon: Icons.fact_check_rounded,
                actionLabel: 'Review',
                onTap: () {
                  context.push('/staff/gallery-requests');
                },
                subText: 'Review and approve members\' memory submissions.',
              ),
              DashboardTiles(
                title: 'Server access',
                color: Colors.redAccent,
                icon: Icons.verified_user_outlined,
                actionLabel: 'Server Access',
                onTap: () {
                  context.push('/staff/server-access');
                },
                subText: 'Start, restart, and stop server operations.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const MyFooter(),
      ],
    );
  }
}
