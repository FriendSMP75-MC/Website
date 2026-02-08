import 'dart:async';
import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui;

SupabaseClient get supabase => Supabase.instance.client;

class Status extends StatefulWidget {
  const Status({super.key});

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  StreamSubscription<AuthState>? _authSub;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();

    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
    });

    // Register both iframes
    _registerIframe(
      'small-status',
      'https://friendsmp75.instatus.com/embed-status/fc41389b/dark-md',
    );

    _registerIframe('Detailed-status', 'https://friendsmp75.instatus.com/');
  }

  void _registerIframe(
    String viewType,
    String src, {
    String width = '100%',
    String height = '100%',
  }) {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.sandbox.value = 'allow-scripts allow-same-origin';
      iframe.src = src;
      iframe.style.border = 'none';
      iframe.style.width = width;
      iframe.style.height = height;
      
      // Fixes scrolling issues: allows the user to scroll even when hovering over the iframe
      iframe.style.pointerEvents = 'auto'; 
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
    double width;
    if (MediaQuery.widthOf(context) < 600) {
      width = MediaQuery.widthOf(context) - 50;
    } else {
      width = MediaQuery.widthOf(context) - 200;
    }

    return Scaffold(
      appBar: AppbarPage(),
      // Track drawer state to remove iframe
      onEndDrawerChanged: (isOpened) {
        setState(() {
          _isDrawerOpen = isOpened;
        });
      },
      endDrawer: NavDrawer(currentPage: 'Status', parentContext: context),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Small Status ---
            Center(
              child: SizedBox(
                width: width,
                height: 61,
                // If drawer is open, we destroy the iframe and show text
                child: _isDrawerOpen 
                  ? const Center(child: Text('Close menu to see status', style: TextStyle(color: Colors.grey)))
                  : HtmlElementView(
                      key: UniqueKey(), // Forces a clean mount/unmount
                      viewType: 'small-status',
                    ),
              ),
            ),
            
            const SizedBox(height: 20),

            // --- Detailed Status ---
            Center(
              child: SizedBox(
                width: width,
                height: 500,
                // Using a Ternary operator here is the only way to unblock the Navbar
                child: _isDrawerOpen
                  ? const Center(child: Text('Navigation Menu Open', style: TextStyle(color: Colors.grey)))
                  : ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: HtmlElementView(
                        key: UniqueKey(),
                        viewType: 'Detailed-status',
                      ),
                    ),
              ),
            ),

            // Footer
            const SizedBox(height: 100),
            const MyFooter(),
          ],
        ),
      ),
    );
  }
}