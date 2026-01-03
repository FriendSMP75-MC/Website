import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/nav_drawer.dart';

SupabaseClient get supabase => Supabase.instance.client;

class Status extends StatefulWidget {
  const Status({super.key});

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = supabase.auth.onAuthStateChange.listen((data) {});
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    SupabaseConfig.getUserName(user);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // server logo
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Image.network(
                  'https://i.ibb.co/4nkHpYDw/servercurrent.jpg',
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),

              // server name
              const Flexible(
                child: Text('FriendSMP75', overflow: TextOverflow.visible),
              ),
            ],
          ),
        ),

        // to open end drawer by default and for icon
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
        currentPage: 'Status',
        parentContext: context,
      ),

      body: const Center(child: Text('Welcome to the Status app!')),
    );
  }
}
