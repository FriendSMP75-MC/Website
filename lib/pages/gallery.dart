import 'dart:async';
import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/nav_drawer.dart';

SupabaseClient get supabase => Supabase.instance.client;

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
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
      appBar: AppbarPage(customTitle: 'FriendSMP75 - Gallery'),
      endDrawer: NavDrawer(currentPage: 'Gallery', parentContext: context),

      body: const Center(child: Text('Welcome to the Gallery app!')),
    );
  }
}
