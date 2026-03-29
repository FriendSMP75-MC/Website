import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/widgets/announcement_preview.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

SupabaseClient get supabase => Supabase.instance.client;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription<AuthState>? _authSub;
  List<dynamic> announcements = [];
  Map<String, dynamic> announcement = {};

  @override
  void initState() {
    super.initState();
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
    });
    _getAnnouncement();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void copyIP() {
    Clipboard.setData(ClipboardData(text: 'friendsmp75.mcgg.nl'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.blue),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text('Copied to clipboard!'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getAnnouncement() async {
    final result = await BackendData.getAnnouncements();
    if (result != null && result.isNotEmpty) {
      setState(() {
        announcements = result.reversed.toList();
        announcement = announcements[0] as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    SupabaseConfig.getUserName(user);

    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: NavDrawer(currentPage: 'Home', parentContext: context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // IP AND DISCORD
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    
                    TextButton.icon(
                      onPressed: () => copyIP(),
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: const Text(
                        'IP: FriendSMP75.mcgg.nl',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: const ButtonStyle(
                        overlayColor: WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                      ),
                    ),
                    Center(
                      child: InkWell(
                        onTap: () => copyIP(),
                        child: const Text(
                          'Click to copy',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.discord, color: Colors.indigoAccent),
                          InkWell(
                            onTap: () => copyIP(),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text('Discord server'),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: InkWell(
                          onTap: () async {
                            final Uri url = Uri.parse(
                              'https://discord.gg/K8ucVvjfge',
                            );
                            if (!await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            )) {
                              throw 'unable to open link';
                            }
                          },
                          child: const Text(
                            'Click to join!',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Show recent announcement
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Recent Announcement',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            if (announcement.isNotEmpty)
              LatestAnnouncementPreview(announcement: announcement)
            else
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),

            // Navigate to Announcment page
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                context.push('/announcements');
              },
              label: Text(
                'Read older announcements',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(Icons.arrow_right_alt_sharp),
              iconAlignment: IconAlignment.end,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                iconColor: WidgetStatePropertyAll(Colors.white),
              ),
            ),

            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('FAQs', style: TextStyle(fontSize: 20)),
            ),
            const Faq(
              question: 'How to claim land',
              answer:
                  'To protect your builds, use a Golden Shovel to mark out a rectangle. Right-click the ground to set the first corner, then move to the opposite corner and right-click again to finalize the claim',
            ),
            const Faq(
              question: 'How to reset password',
              answer:
                  'If you are already loggind into server you can use /changepass to change your password. If you are not loggined please contact us in ticket to assist you',
            ),
            const Faq(
              question: 'How old is the server',
              answer: 'FriendSMP75 was founded on 2020, during COVID - 19',
            ),

            // --- FOOTER ---
            const SizedBox(height: 50),
            const MyFooter(),
          ],
        ),
      ),
    );
  }
}

class Faq extends StatelessWidget {
  final String question;
  final String answer;
  const Faq({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: Colors.white10,
      collapsedBackgroundColor: Colors.white10,
      title: Text(question),
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(answer)),
      ],
    );
  }
}
