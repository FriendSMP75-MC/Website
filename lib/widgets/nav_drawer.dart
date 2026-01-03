import 'package:flutter/material.dart';
import 'package:server_site/dashboard.dart';
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
            height: 75,
            width: double.infinity,
            alignment: Alignment.center,
            color: Colors.purple,
            child: Text(
              'Current page: $currentPage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),

          // Pages list (scrollable)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  minTileHeight: 57,
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
                  minTileHeight: 57,
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
                  minTileHeight: 57,
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
                  minTileHeight: 57,
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

          //login/logout button with greeting
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user!=null)
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minTileHeight: 57,
                title: const Text('Dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                ),
                selected: currentPage=='Dashboard',
                selectedTileColor: Colors.purpleAccent,
                onTap: () {
                  _navigateSafely(const Dashboard());
                },
              ),

              SizedBox(
                width: double.infinity,
                height: 75,
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
