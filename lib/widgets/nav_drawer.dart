import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:server_site/data/supabase_config.dart';

SupabaseClient get supabase => Supabase.instance.client;

class NavDrawer extends StatelessWidget {
  final String currentPage;
  final BuildContext parentContext;

  const NavDrawer({
    super.key,
    required this.currentPage,
    required this.parentContext,
  });

  void _navigateSafely(BuildContext context, String route) {
    Navigator.pop(parentContext);
    Future.delayed(const Duration(milliseconds: 180), () {
      if (parentContext.mounted) {
        context.go(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    final username = SupabaseConfig.getUserName(user);

    final pages = <({String label, String route, IconData icon})>[
      (label: 'Home', route: '/', icon: Icons.home_rounded),
      (label: 'About', route: '/about', icon: Icons.info_outline_rounded),
      (label: 'Status', route: '/status', icon: Icons.monitor_heart_rounded),
      (label: 'Gallery', route: '/gallery', icon: Icons.photo_library_outlined),
      (
        label: 'Announcements',
        route: '/announcements',
        icon: Icons.campaign_outlined,
      ),
      (label: 'Support us', route: '/support', icon: Icons.favorite_outline),
      (label: 'Vote', route: '/votes', icon: Icons.how_to_vote_rounded),
    ];

    return PointerInterceptor(
      child: Drawer(
        backgroundColor: const Color(0xFF0B1320),
        child: Column(
          children: [
            Container(
              height: 128,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
              alignment: Alignment.bottomLeft,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF16355A), Color(0xFF0E223C)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Navigation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current: $currentPage',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: pages.map((page) {
                  final bool selected = currentPage == page.label;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      tileColor: Colors.white.withValues(alpha: 0.06),
                      selected: selected,
                      selectedTileColor: const Color(0xFF1E7AA7),
                      leading: Icon(page.icon, color: Colors.white),
                      title: Text(
                        page.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        if (selected) {
                          Navigator.pop(parentContext);
                        } else {
                          _navigateSafely(context, page.route);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                children: [
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        tileColor: Colors.white.withValues(alpha: 0.06),
                        selected: currentPage == 'Dashboard',
                        selectedTileColor: const Color(0xFF1E7AA7),
                        leading: const Icon(
                          Icons.dashboard_customize_rounded,
                          color: Colors.white,
                        ),
                        title: const Text(
                          'Dashboard',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          _navigateSafely(context, '/dashboard');
                        },
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1E7AA7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (user == null) {
                          await SupabaseConfig.loginWithDiscord();
                        } else {
                          await SupabaseConfig.logout();
                        }
                      },
                      icon: Icon(user == null ? Icons.login : Icons.logout),
                      label: Text(
                        user == null
                            ? 'Login with Discord'
                            : 'Logout • $username',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
