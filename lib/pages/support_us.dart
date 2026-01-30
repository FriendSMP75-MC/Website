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

  void _injectScripts() {
    if (_scriptsLoaded) return;

    final assets = [
      {'type': 'link', 'href': 'https://vjs.zencdn.net/8.10.0/video-js.css'},
      {'type': 'script', 'src': 'https://vjs.zencdn.net/8.10.0/video.min.js'},
      {'type': 'script', 'src': '//imasdk.googleapis.com/js/sdkloader/ima3.js'},
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

    ui_web.platformViewRegistry.registerViewFactory('hilltop-video-zone', (int viewId) {
      final div = web.document.createElement('div') as web.HTMLDivElement;
      div.style.width = '100%';
      div.style.height = '100%';
      div.style.backgroundColor = 'black';

      final video = web.document.createElement('video') as web.HTMLVideoElement;
      video.id = 'ad-video-player';
      video.className = 'video-js vjs-default-skin';
      
      // Essential for modern browsers to allow autoplay
      video.muted = true; 
      video.setAttribute('playsinline', 'true');
      video.setAttribute('autoplay', 'true');
      
      video.style.width = '100%';
      video.style.height = '100%';

      div.append(video);

      // Trigger initialization logic
      _initPlayer();

      return div;
    });
  }

  void _initPlayer() {
    final jsCode = """
      (function() {
        // Use an interval to wait until Flutter actually puts the video tag in the DOM
        var checkExist = setInterval(function() {
          var element = document.getElementById('ad-video-player');
          if (element && typeof videojs !== 'undefined') {
            clearInterval(checkExist);
            try {
              var player = videojs('ad-video-player');
              player.ima({
                id: 'ad-video-player',
                adTagUrl: 'https://shiny-fortune.com/dDm/F.zUdAG-NOvWZ/GzUb/Ketm/9huqZYUOl/kmPaT/YQ3WNLjXAF5lNhDHIat/N/jZce2fMLDNkj0eMGwD'
              });

              // Handle "No Ads" (Error 1009) or other loading failures
              player.on('adserror', function(data) {
                console.log('IMA Ads Error: ', data.getError());
                element.parentElement.innerHTML = '<div style="color:white;display:flex;justify-content:center;align-items:center;height:100%;text-align:center;padding:20px;">No video available right now. Thanks for your support!</div>';
              });

              player.muted(true);
              player.play();
            } catch (e) {
              console.error('VideoJS Init Error:', e);
            }
          }
        }, 200);
      })();
    """;
    final script = web.document.createElement('script') as web.HTMLScriptElement;
    script.text = jsCode;
    web.document.body?.append(script);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(title: const Text("Support Us"), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Why support us?',
              style: TextStyle(fontSize: 30, color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("➤ Support server hosting costs", style: TextStyle(color: Colors.white70)),
            const Text("➤ Help us buy premium plugins", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 30),
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
                  decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent.withOpacity(0.5))),
                  child: const HtmlElementView(viewType: 'hilltop-video-zone'),
                ),
              ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Markdown(
                shrinkWrap: true,
                data: 'Ads are provided by third parties. Please report any inappropriate content on Discord.',
                styleSheet: MarkdownStyleSheet(
                  textAlign: WrapAlignment.center,
                  p: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}