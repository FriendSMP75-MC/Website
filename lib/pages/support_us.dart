import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class SupportUsPage extends StatefulWidget {
  const SupportUsPage({super.key});

  @override
  State<SupportUsPage> createState() => _SupportUsPageState();
}

class _SupportUsPageState extends State<SupportUsPage> {
  bool showAd = false;
  bool _scriptsLoaded = false;

  /// Injects the VideoJS and Google IMA libraries into the document head
  void _injectScripts() {
    if (_scriptsLoaded) return;

    final assets = [
      {'type': 'link', 'href': 'https://vjs.zencdn.net/8.10.0/video-js.css'},
      {'type': 'script', 'src': 'https://vjs.zencdn.net/8.10.0/video.min.js'},
      {'type': 'script', 'src': 'https://imasdk.googleapis.com/js/sdkloader/ima3.js'},
      {'type': 'script', 'src': 'https://cdnjs.cloudflare.com/ajax/libs/videojs-contrib-ads/6.9.0/videojs-contrib-ads.min.js'},
      {'type': 'script', 'src': 'https://cdnjs.cloudflare.com/ajax/libs/videojs-ima/1.11.0/videojs.ima.min.js'},
    ];

    for (var asset in assets) {
      if (asset['type'] == 'link') {
        final link = web.document.createElement('link') as web.HTMLLinkElement;
        link.rel = 'stylesheet';
        link.href = asset['href']!;
        web.document.head?.append(link);
      } else {
        final script = web.document.createElement('script') as web.HTMLScriptElement;
        script.src = asset['src']!;
        script.async = true;
        web.document.head?.append(script);
      }
    }
    _scriptsLoaded = true;
  }

  @override
  void initState() {
    super.initState();

    // Register the factory for the HTML element
    ui_web.platformViewRegistry.registerViewFactory('hilltop-video-zone', (int viewId) {
      final div = web.document.createElement('div') as web.HTMLDivElement;
      div.style.width = '100%';
      div.style.height = '100%';
      div.style.backgroundColor = 'black';

      // Create the video element that Video.js will target
      final video = web.document.createElement('video') as web.HTMLVideoElement;
      video.id = 'ad-video-player';
      video.className = 'video-js vjs-default-skin';
      video.setAttribute('playsinline', '');
      video.style.width = '100%';
      video.style.height = '100%';

      div.append(video);

      // Delay to ensure the DOM element is rendered and scripts are ready
      Future.delayed(const Duration(milliseconds: 800), () {
        _initPlayer();
      });

      return div;
    });
  }

  /// Runs the JS logic to turn the video element into a VAST player
  void _initPlayer() {
    final jsCode = """
      try {
        var player = videojs('ad-video-player');
        player.ima({
          id: 'ad-video-player',
          adTagUrl: 'https://shiny-fortune.com/dDm/F.zUdAG-NOvWZ/GzUb/Ketm/9huqZYUOl/kmPaT/YQ3WNLjXAF5lNhDHIat/N/jZce2fMLDNkj0eMGwD'
        });
        player.muted(true);
        player.play();
      } catch (e) {
        console.error('Failed to initialize Ad Player:', e);
      }
    """;
    final script = web.document.createElement('script') as web.HTMLScriptElement;
    script.text = jsCode;
    web.document.body?.append(script);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Dark background matching typical dashboards
      appBar: AppBar(title: const Text("Support Us")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Why support us?',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("➤ Allow us to maintain cost for hosting", style: TextStyle(color: Colors.white)),
                Text("➤ Buy (or) Pay for plugins", style: TextStyle(color: Colors.white)),
                Text("➤ Provide support instantly", style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _injectScripts();
                setState(() {
                  showAd = true;
                });
              },
              child: const Text('Watch Video Ad to Support Us!'),
            ),
            const SizedBox(height: 20),
            if (showAd)
              Center(
                child: Container(
                  width: 400,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  child: const HtmlElementView(viewType: 'hilltop-video-zone'),
                ),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Markdown(
                shrinkWrap: true,
                data: 'Please remember **ads shown** on the page redirect are not set by us.\n'
                      'If you find ads disturbing, please report to us on Discord.',
                styleSheet: MarkdownStyleSheet(
                  textAlign: WrapAlignment.center,
                  p: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}