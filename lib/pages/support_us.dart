import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

class SupportUsPage extends StatefulWidget {
  const SupportUsPage({super.key});

  @override
  State<SupportUsPage> createState() => _SupportUsPageState();
}

class _SupportUsPageState extends State<SupportUsPage> {
  final String _smartlinkUrl =
      'https://duepose.com/fdyxudzb52?key=c6b07a3f738ebead7c217a43e9b3c89a';

  final String _adViewType = 'adsterra-native-bypass';
  final String _containerId = 'container-07b3366e08460cfc7ba1d4b71d138632';

  @override
  void initState() {
    super.initState();

    // Register the View Factory
    ui.platformViewRegistry.registerViewFactory(_adViewType, (int viewId) {
      final div = web.document.createElement('div') as web.HTMLDivElement;
      div.id = _containerId;

      div.style.setProperty('width', '100%');
      div.style.setProperty('height', '100%');
      div.style.setProperty('display', 'flex');
      div.style.setProperty('justify-content', 'center');

      final script =
          web.document.createElement('script') as web.HTMLScriptElement;
      script.src =
          'https://duepose.com/07b3366e08460cfc7ba1d4b71d138632/invoke.js';
      script.async = true;
      script.setAttribute('data-cfasync', 'false');

      div.append(script);
      return div;
    });
  }

  @override
  void dispose() {
    final element = web.document.getElementById(_containerId);
    element?.remove();
    super.dispose();
  }

  Future<void> _launchSmartlink() async {
    final Uri url = Uri.parse(_smartlinkUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for supporting the SMP!')),
        );
      }
    } catch (e) {
      debugPrint('Could not launch smartlink: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(customTitle: 'FriendSMP75 - Support us'),
      endDrawer: NavDrawer(currentPage: 'Support us', parentContext: context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // TOP AD
            Center(
              child: SizedBox(
                height: 180,
                width: 320,
                child: HtmlElementView(viewType: _adViewType),
              ),
            ),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Why support us?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Whylist(text: 'Server Hosting Costs'),
            const Whylist(text: 'Buy/Pay for plugins'),
            const Whylist(text: 'Support Developers / map makers'),
            const Whylist(text: 'Keep server alive :>'),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _launchSmartlink,
              icon: const Icon(Icons.favorite),
              label: const Text(
                'Click to Support us :)',
                style: TextStyle(fontSize: 20),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Text(
                'Note: Supporting opens a sponsor page in a new tab.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            //Footer
            SizedBox(height: 50),
            MyFooter(),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text('➤ $text', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
