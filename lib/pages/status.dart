import 'dart:async';
import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui;
// Import the package
import 'package:pointer_interceptor/pointer_interceptor.dart';

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

    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
    });

    // Register iframes
    _registerIframe(
      'small-status',
      'https://friendsmp75.instatus.com/embed-status/fc41389b/dark-md',
    );

    _registerIframe('Detailed-status', 'https://friendsmp75.instatus.com/');
  }

  void _registerIframe(String viewType, String src) {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.sandbox.value = 'allow-scripts allow-same-origin';
      iframe.src = src;
      iframe.style.border = 'none';
      iframe.style.width = '100%';
      iframe.style.height = '100%';
      return iframe;
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.widthOf(context) < 700;
    final double width = isMobile
        ? MediaQuery.widthOf(context) - 24
        : MediaQuery.widthOf(context) - 140;

    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: PointerInterceptor(
        child: NavDrawer(currentPage: 'Status', parentContext: context),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF091323), Color(0xFF102037), Color(0xFF091323)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 20,
                  18,
                  isMobile ? 12 : 20,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 16 : 22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B3556), Color(0xFF17506F)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Server Status',
                            style: TextStyle(
                              fontSize: isMobile ? 32 : 42,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Monitor FriendSMP75 uptime and incidents in real time.',
                            style: TextStyle(
                              color: Colors.blueGrey[100],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: width,
                      height: 74,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withValues(alpha: 0.06),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: PointerInterceptor(
                        child: HtmlElementView(viewType: 'small-status'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: width,
                      height: isMobile ? 430 : 560,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withValues(alpha: 0.06),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        child: PointerInterceptor(
                          child: HtmlElementView(viewType: 'Detailed-status'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
