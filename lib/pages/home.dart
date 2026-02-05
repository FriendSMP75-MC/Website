import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/widgets/announcement_preview.dart';
import 'package:server_site/widgets/appbar.dart';
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
            Icon(Icons.info, color: Colors.blue),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Copied to clipboard!'),
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
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        copyIP();
                      },
                      icon: Icon(Icons.play_arrow_outlined),
                      label: const Text(
                        'IP: FriendSMP75.mcgg.nl',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        overlayColor: WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                      ),
                    ),
                    Center(
                      child: InkWell(
                        onTap: () {
                          copyIP();
                        },
                        child: Text(
                          'Click to copy',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              'https://www.bing.com/th/id/OIP.DUC4e6UJ39Hi9rl8cZtzsgHaHa?w=193&h=193&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
                              height: 24,
                              width: 24,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              copyIP();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
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
                          child: Text(
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
            SizedBox(height: 10),
            // Display latest announcement
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Recent Announcement',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),

            // Show announcement
            if (announcement.isNotEmpty)
              LatestAnnouncementPreview(announcement: announcement)
            else
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),

            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('FAQs', style: TextStyle(fontSize: 20)),
            ),
            Faq(
              question: 'How to claim land',
              answer:
                  '''To protect your builds, use a Golden Shovel to mark out a rectangular shape. Right‑click the ground at one corner, then walk to the opposite corner and right‑click again. The system will highlight the edges of your claim for a few seconds, showing the protected area. Inside this rectangle, only you can build or use containers unless you give access.
''',
            ),
            Faq(
              question: 'How to reset password',
              answer:
                  ''' If you are already loggind into server you can use /changepass <old_password> <new_password>. In case you forget your passward and can't login then create a ticket in our discord server and follow staff's instructions.
''',
            ),
            Faq(
              question: 'How old is the server',
              answer: '''FriendSMP75 was founded on 2020, during COVID - 19''',
            ),

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
      children: [Padding(padding: EdgeInsets.all(8.0), child: Text(answer))],
    );
  }
}
