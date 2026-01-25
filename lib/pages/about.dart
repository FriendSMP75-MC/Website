import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'dart:async';

SupabaseClient get supabase => Supabase.instance.client;

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
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
    SupabaseConfig.getUserName(user);

    return Scaffold(
      appBar: AppbarPage(),

      endDrawer: NavDrawer(currentPage: 'About', parentContext: context),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(8.0),child: Text('latest Announcmement'),)
          ],
        ),
      )
    );
  }
}
