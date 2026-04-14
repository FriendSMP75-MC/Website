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
    final bool isMobile = MediaQuery.sizeOf(context).width < 800;

    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: NavDrawer(currentPage: 'About', parentContext: context),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A1423), Color(0xFF0F1D31), Color(0xFF0A1423)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 14 : 22,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF193554), Color(0xFF124568)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 26,
                            offset: Offset(0, 12),
                            color: Color(0x33000000),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About FriendSMP75',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'A friendly survival server focused on trust, creativity, and long-term community memories.',
                            style: TextStyle(
                              color: Colors.blueGrey[100],
                              fontSize: isMobile ? 14 : 16,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: SelectableText(
                        '''FriendSMP75 is a friendly Minecraft community built on trust and respect. Our goal is to offer a safe, peaceful environment where you can relax and enjoy the game without worry.

We are a community-led server, which means every player counts. We listen to feedback and make sure everyone has a voice in how the server grows.

While PvP exists in Minecraft, we are not a PvP-oriented community. We prefer supportive gameplay where players build together instead of fighting each other.''',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          height: 1.5,
                          color: Colors.blueGrey[50],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        _InfoPill(
                          icon: Icons.groups_2_rounded,
                          title: 'Community-led',
                          subtitle: 'Your voice shapes updates',
                        ),
                        _InfoPill(
                          icon: Icons.shield_moon_rounded,
                          title: 'Safe & Respectful',
                          subtitle: 'Moderated for positive play',
                        ),
                        _InfoPill(
                          icon: Icons.park_rounded,
                          title: 'Peaceful Survival',
                          subtitle: 'Build and progress together',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const MyFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoPill({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0x332FB8D2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF43D3E2)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
