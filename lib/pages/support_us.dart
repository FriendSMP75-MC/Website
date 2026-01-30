import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/nav_drawer.dart';

class SupportUsPage extends StatefulWidget {
  const SupportUsPage({super.key});

  @override
  State<SupportUsPage> createState() => _SupportUsPageState();
}

class _SupportUsPageState extends State<SupportUsPage> {
  bool showAd = false;

  @override
  void initState() {
    super.initState();

    // Register iframe view factory for HilltopAds zone
    ui_web.platformViewRegistry.registerViewFactory('hilltop-video-zone', (
      int viewId,
    ) {
      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.src =
          'https://shiny-fortune.com/dDm/F.zUdAG-NOwWZ/GzUb/Ketm/9huqZYUOl/kmPaT/YQ3NWLjXAF51NhDHIat/N/jzce2FMLDNkjJoEMGwD'; // 👈 your zone embed URL
      iframe.style.border = 'none';
      iframe.style.width = '100%';
      iframe.style.height = '300px'; // explicit height
      iframe.allow = "autoplay"; // allow video playback
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: NavDrawer(currentPage: 'Support us', parentContext: context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Why support us?',
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                "➤ Allow us to maintain cost for hosting",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "➤ Buy (or) Pay for plugins",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "➤ Provide support instantly",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showAd = true; // show iframe only after click
              });
            },
            child: const Text(
              'Watch Video Ad to Support Us!',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          const SizedBox(height: 20),
          if (showAd)
            SizedBox(
              height: 300,
              child: HtmlElementView(viewType: 'hilltop-video-zone'),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: Markdown(
              data:
                  'Please remember **ads shown** on the page redirect are not set by us.\nIf you find ads disturbing, please report to us on Discord so we can filter them out.',
              styleSheet: MarkdownStyleSheet(textAlign: WrapAlignment.center),
            ),
          ),
        ],
      ),
    );
  }
}
