import 'dart:async';
import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
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
      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.src = src;
      iframe.style.border = 'none';
      iframe.style.width = width;
      iframe.style.height = height;
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
    }else {
      width = MediaQuery.widthOf(context) - 200;
    }

    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: NavDrawer(currentPage: 'Status', parentContext: context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: width,
              height: 61,
              child: HtmlElementView(viewType: 'small-status'),
            ),
          ),
          SizedBox(height: 20),
          SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: width,
                height: 500,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: HtmlElementView(viewType: 'Detailed-status'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
