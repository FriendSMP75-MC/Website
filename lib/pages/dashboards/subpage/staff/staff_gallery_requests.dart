import 'dart:async';
import 'package:flutter/material.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

class StaffGalleryRequestsPage extends StatefulWidget {
  const StaffGalleryRequestsPage({super.key});

  @override
  State<StaffGalleryRequestsPage> createState() =>
      _StaffGalleryRequestsPageState();
}

class _StaffGalleryRequestsPageState extends State<StaffGalleryRequestsPage> {
  StreamSubscription<AuthState>? _authSub;

  final List<Map<String, String>> _demoRequests = [];

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

  void _handleRequestAction({required bool approved, required String title}) {
    final message = approved
        ? 'Approved request: $title'
        : 'Rejected request: $title';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );

    setState(() {
      _demoRequests.removeWhere((request) => request['title'] == title);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppbarPage(backArrow: true,),
        endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
        body: Column(
          children: const [
            Expanded(
              child: Center(
                child: Text(
                  'Login required to access gallery request approvals.',
                ),
              ),
            ),
            MyFooter(),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppbarPage(backArrow: true,),
      endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                const Text(
                  'Approve Gallery Requests',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Review pending memory submissions and approve or reject them.',
                ),
                const SizedBox(height: 14),
                if (_demoRequests.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No pending gallery requests right now.'),
                    ),
                  )
                else
                  ..._demoRequests.map((request) {
                    final title = request['title'] ?? 'Untitled request';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('Player: ${request['player'] ?? 'Unknown'}'),
                            Text('Submitted: ${request['date'] ?? '-'}'),
                            const SizedBox(height: 6),
                            Text(request['note'] ?? ''),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _handleRequestAction(
                                    approved: true,
                                    title: title,
                                  ),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _handleRequestAction(
                                    approved: false,
                                    title: title,
                                  ),
                                  icon: const Icon(Icons.close),
                                  label: const Text('Reject'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
          const MyFooter(),
        ],
      ),
    );
  }
}
