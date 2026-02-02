import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:web/web.dart' as web;

class SupportUsPage extends StatefulWidget {
  const SupportUsPage({super.key});

  @override
  State<SupportUsPage> createState() => _SupportUsPageState();
}

class _SupportUsPageState extends State<SupportUsPage> {
  bool _scriptLoaded = false;

  void lightboxAD() {
    if (_scriptLoaded) return;

    final script = web.document.createElement('script') as web.HTMLScriptElement;
    script.id = 'lightbox-ad-script';
    script.src = '//dcbbwymp1bhlf.cloudfront.net/?wbbcd=1240703';
    script.setAttribute('data-cfasync', 'false');

    web.document.body?.append(script);
    _scriptLoaded = true;
  }

  @override
  void dispose() {
    // Remove the script when leaving the page
    final script = web.document.getElementById('lightbox-ad-script');
    script?.remove();
    _scriptLoaded = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(customTitle: 'FriendSMP75 - Support us'),
      endDrawer: NavDrawer(currentPage: 'Support us', parentContext: context),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: Text(
                'Why support us?',
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Whylist(text: 'Pay for paid plugins'),
            const Whylist(text: 'Maintain cost for server hosting'),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                lightboxAD();
              },
              label: const Text('Click to load ad :)'),
              icon: const Icon(Icons.support),
            ),
          ],
        ),
      ),
    );
  }
}

class Whylist extends StatelessWidget {
  final String text;
  const Whylist({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text('➤ $text', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}