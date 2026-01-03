import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:server_site/supabase_config.dart';
import 'package:server_site/home.dart';
import 'package:server_site/about.dart';
import 'package:server_site/status.dart';
import 'package:server_site/gallery.dart';

SupabaseClient get supabase => Supabase.instance.client;

class NavDrawer extends StatelessWidget {
  final String currentPage;
  final BuildContext parentContext;

  const NavDrawer({
    super.key,
    required this.currentPage,
    required this.parentContext,
  });

  Future<void> _navigateSafely(Widget page) async {
    Navigator.pop(parentContext);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!parentContext.mounted) return;
    Navigator.push(
      parentContext,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(seconds: 15),
        reverseTransitionDuration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    final displayName = SupabaseConfig.getDisplayName(user);

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            height: 66,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.purple,
            child: Text(
              'Current page: $currentPage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          // Pages list (scrollable)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text(
                    'Home',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  selected: currentPage == 'Home',
                  selectedTileColor: Colors.purpleAccent,
                  onTap: () {
                    _navigateSafely(const Home());
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text(
                    'About',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  selected: currentPage == 'About',
                  selectedTileColor: Colors.purpleAccent,
                  onTap: () {
                    if (currentPage != 'About') {
                      _navigateSafely(const About());
                    } else {
                      Navigator.pop(parentContext);
                    }
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text('Status',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)),
                  selected: currentPage == 'Status',
                  selectedTileColor: Colors.purpleAccent,
                  onTap: () {
                    _navigateSafely(const Status());
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text('Gallery',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)),
                  selected: currentPage == 'Gallery',
                  selectedTileColor: Colors.purpleAccent,
                  onTap: () {
                    _navigateSafely(const Gallery());
                  },
                ),
              ],
            ),
          ),

          // Bottom greeting + login/logout button
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (user == null) {
                      await SupabaseConfig.loginWithDiscord();
                    } else {
                      await SupabaseConfig.logout();
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user == null
                            ? "Login with Discord"
                            : "Welcome Back! \n $displayName",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
