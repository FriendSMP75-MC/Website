import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_adsterra/flutter_adsterra.dart' as ad;

class SupportUsPage extends StatefulWidget {
  const SupportUsPage({super.key});

  @override
  State<SupportUsPage> createState() => _SupportUsPageState();
}

class _SupportUsPageState extends State<SupportUsPage> {
  // Ad links / scripts
  final String _smartlinkUrl =
      'https://duepose.com/fdyxudzb52?key=c6b07a3f738ebead7c217a43e9b3c89a';

  Future<void> _launchSmartlink() async {
    final Uri url = Uri.parse(_smartlinkUrl);

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for supporting the SMP!')),
      );
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
            // Native ad at the top of the screen
            SizedBox(height: 200,
              child: ad.NativeBannerAd(
                scriptUrl:
                    "https://duepose.com/07b3366e08460cfc7ba1d4b71d138632/invoke.js",
              ),
            ),
        
            // Why support us
            Center(
              child: Text(
                'Why support us?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
        
            // List of reasons
            const SizedBox(height: 20),
            const Whylist(text: 'Server Hosting Costs'),
            const Whylist(text: 'Buy/Pay for plugins'),
            const Whylist(text: 'Support Developers / map makers'),
            const Whylist(text: 'Keep server alive :>'),
            const SizedBox(height: 30),
        
            // The Main Support Button
            ElevatedButton.icon(
              // Button styles
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
        
              onPressed: _launchSmartlink, // Launch ad in new tab
              icon: const Icon(Icons.support),
              label: const Text(
                'Click to Support us :)',
                style: TextStyle(fontSize: 20),
              ),
            ),
        
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Note: Supporting opens a sponsor page in a new tab. These are not under our control.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        
            // Native ad at the bottom of the screen
            ad.NativeBannerAd(
              scriptUrl:
                  'https://duepose.com/07b3366e08460cfc7ba1d4b71d138632/invoke.js',
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text('➤ $text', style: const TextStyle(fontSize: 18)),
    );
  }
}
