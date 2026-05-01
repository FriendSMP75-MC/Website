import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/data/supabase_config.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class StaffTicketsPage extends StatefulWidget {
  const StaffTicketsPage({super.key});

  @override
  State<StaffTicketsPage> createState() => _StaffTicketsPageState();
}

class _StaffTicketsPageState extends State<StaffTicketsPage> {
  List<Map<String, dynamic>> _tickets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If not logged in, skip loading and show login required UI
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _tickets = [];
      });
    }
  }

  Future<void> _loadTickets() async {
    final result = await BackendData.getTickets();
    if (!mounted) return;
    setState(() {
      _tickets = result ?? [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 760;

    final user = SupabaseConfig.client.auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppbarPage(backArrow: true),
        endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
        body: const Column(
          children: [
            Expanded(
              child: Center(
                child: Text('Login required to access staff tickets.'),
              ),
            ),
            MyFooter(),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppbarPage(backArrow: true),
      endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF091323), Color(0xFF102037), Color(0xFF091323)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 20,
                  16,
                  isMobile ? 12 : 20,
                  0,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 14 : 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staff Tickets',
                            style: TextStyle(
                              fontSize: isMobile ? 28 : 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This view lists entries from the public.tickets table.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          if (_loading)
                            const Center(child: CircularProgressIndicator())
                          else if (_tickets.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18.0),
                              child: Center(child: Text('No tickets found.')),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _tickets.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, idx) {
                                final t = _tickets[idx];
                                final title =
                                    t['title']?.toString() ?? 'Untitled';
                                final discord =
                                    t['discord_id']?.toString() ?? '';
                                final channel =
                                    t['channel_id']?.toString() ?? '';
                                final status = t['status']?.toString() ?? '';
                                return ListTile(
                                  title: Text(title),
                                  subtitle: Text(
                                    'Discord: $discord • Channel: $channel',
                                  ),
                                  trailing: Text(
                                    status,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
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
