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
      final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
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
    double width = MediaQuery.widthOf(context) < 600 
        ? MediaQuery.widthOf(context) - 50 
        : MediaQuery.widthOf(context) - 200;

    return Scaffold(
      appBar: AppbarPage(),
     // Warping with pointer interceptor to keep end drawer on top layer
      endDrawer: PointerInterceptor(
        child: NavDrawer(currentPage: 'Status', parentContext: context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Small status - Widget
            Center(
              child: SizedBox(
                width: width,
                height: 61,
                child: PointerInterceptor(
                  child: HtmlElementView(viewType: 'small-status'),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Detailed status - Whole page
            Center(
              child: SizedBox(
                width: width,
                height: 500,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: PointerInterceptor(
                    child: HtmlElementView(viewType: 'Detailed-status'),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
            const MyFooter(),
          ],
        ),
      ),
    );
  }
}