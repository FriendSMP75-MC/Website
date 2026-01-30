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
        script.async = false; // Load in order to prevent 'videojs undefined'
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
      div.id = 'ad-container-wrapper';
      div.style.width = '100%';
      div.style.height = '100%';
      div.style.backgroundColor = 'black';

      final video = web.document.createElement('video') as web.HTMLVideoElement;
      video.id = 'ad-video-player';
      video.className = 'video-js vjs-default-skin';
      
      // Critical browser compatibility flags
      video.muted = true; 
      video.autoplay = true;
      video.setAttribute('playsinline', 'true');
      video.setAttribute('muted', 'true'); // Redundant but necessary for some browsers
      
      video.style.width = '100%';
      video.style.height = '100%';

      div.append(video);
      _initPlayer();
      return div;
    });
  }

  void _initPlayer() {
    final jsCode = """
      (function() {
        var setupPlayer = function() {
          var element = document.getElementById('ad-video-player');
          if (element && typeof videojs !== 'undefined' && typeof google !== 'undefined') {
            try {
              var player = videojs('ad-video-player');
              player.ima({
                id: 'ad-video-player',
                adTagUrl: 'https://shiny-fortune.com/dDm/F.zUdAG-NOvWZ/GzUb/Ketm/9huqZYUOl/kmPaT/YQ3WNLjXAF5lNhDHIat/N/jZce2fMLDNkj0eMGwD'
              });

              player.on('adserror', function(data) {
                console.log('Ad Error:', data.getError());
                var wrapper = document.getElementById('ad-container-wrapper');
                if(wrapper) wrapper.innerHTML = '<div style="color:white;display:flex;justify-content:center;align-items:center;height:100%;text-align:center;padding:20px;">Ad could not load. Thank you for trying to support us!</div>';
              });

              player.muted(true);
              player.play();
            } catch (e) {
              console.error('Setup failed:', e);
            }
            return true;
          }
          return false;
        };

        // Use a persistent checker to catch the element as soon as Flutter renders it
        var interval = setInterval(function() {
          if (setupPlayer()) clearInterval(interval);
        }, 100);
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
      appBar: AppBar(title: const Text("Support Us"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text('Why support us?', style: TextStyle(fontSize: 28, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("➤ Maintain server hosting", style: TextStyle(color: Colors.white70)),
            const Text("➤ Fund premium plugins", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
              onPressed: () {
                _injectScripts();
                setState(() => showAd = true);
              },
              child: const Text('Watch Video Ad to Support Us!'),
            ),
            const SizedBox(height: 25),
            if (showAd)
              Center(
                child: Container(
                  width: 350, // Slightly smaller width for better mobile compatibility
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const HtmlElementView(viewType: 'hilltop-video-zone'),
                  ),
                ),
              ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'If the video stays black, please check if an AdBlocker is active or refresh the page.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}