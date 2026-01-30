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

    // Register iframe view factory
    ui_web.platformViewRegistry.registerViewFactory('hilltop-iframe', (
      int viewId,
    ) {
      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.src =
          'https://shiny-fortune.com/dAm.FfzudTGnNIvyZ/G/Uh/ceJmL9JuBZsU/likaPFTwYq3qNIjeAr5aNiDoInt/Nej/cI2AMED/kC0wMRwJ';
      iframe.style.border = 'none';
      iframe.style.width = '100%';
      iframe.style.height = '300px'; // 👈 Explicit height
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
          // Title
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

          // Bullet points
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

          // Button to trigger video ad
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

          // Show iframe only after button click
          if (showAd)
            SizedBox(
              height: 300, // 👈 Explicit height for platform view
              child: HtmlElementView(viewType: 'hilltop-iframe'),
            ),

          const SizedBox(height: 20),

          // Disclaimer
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
