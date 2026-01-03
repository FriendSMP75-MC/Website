import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:server_site/supabase_config.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'dart:async';

SupabaseClient get supabase => Supabase.instance.client;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    // Subscribe to auth state changes
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    final username = SupabaseConfig.getUserName(user);
    

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Image.network(
                  'https://i.ibb.co/4nkHpYDw/servercurrent.jpg',
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
              const Flexible(
                child: Text('FriendSMP75', overflow: TextOverflow.visible),
              ),
            ],
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(
            width: double.infinity,
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey,
            ),
          ),
        ),
      ),

      endDrawer: NavDrawer(
        currentPage: 'Dashboard',
        parentContext: context,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Welcome $username',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Discord ID: ${user?.userMetadata?['id'] ?? 'Not logged in'}',
                        textAlign: TextAlign.end,
                        ),
                    ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}