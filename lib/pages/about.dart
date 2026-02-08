import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'About FriendSMP75',
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: 'minecraft',
                    color: Colors.blueAccent,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(
                '''FriendSMP75 is a friendly Minecraft community Built on trust and respect. Our main goal To be given a safe community And a peaceful environment Where you can relax and enjoy the game without any worries.

We are a community- led server, which means every person counts. We are listening our players And establish guaranteed everyone has it a voice how the community growing up Your ideas and feedback Always welcome because we believe the server Belongs to the players.

While PVP Admittedly, we are not a PVP oriented community. We prefer a supportive and pleasant environment where individuals work together instead fighting against each other. This is a place For those who want a reliable, friendly and peaceful environment.''',
                style: TextStyle(fontSize: 30),
              ),
            ),

            // Footer
            SizedBox(height: 50),
            MyFooter(),
          ],
        ),
      ),
    );
  }
}
