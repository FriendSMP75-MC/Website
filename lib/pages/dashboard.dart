import 'package:flutter/material.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:server_site/data/supabase_config.dart';
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
  bool? _isOwner;

  @override
  void initState() {
    super.initState();
    // Subscribe to auth state changes and refresh owner flag
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
      if (mounted) _loadOwner();
    });
    _loadOwner();
  }

  Future<void> _loadOwner() async {
    final ownerId = await BackendData.getOwnerAuthID();
    final user = SupabaseConfig.client.auth.currentUser;
    final currentUuid = SupabaseConfig.getSupabaseUUID(user);
    if (!mounted) return;
    setState(() {
      _isOwner = (ownerId != null && ownerId == currentUuid);
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
    final authUUID = SupabaseConfig.getSupabaseUUID(user);

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
            child: Divider(height: 1, thickness: 1, color: Colors.grey),
          ),
        ),
      ),

      endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
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
                    child: SelectableText(
                      'Auth ID: $authUUID',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),

            /// Owner-only add users by auth id
            Builder(
              builder: (context) {
                if (_isOwner == null) {
                  return const SizedBox.shrink();
                }
                if (_isOwner == true) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Hello'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
