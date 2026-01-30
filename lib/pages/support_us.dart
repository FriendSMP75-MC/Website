import "package:flutter/material.dart";
import 'package:flutter_adsterra/flutter_adsterra.dart' as ad;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportUsPage extends StatelessWidget {
  const SupportUsPage({super.key});

  final String url =
      'https://www.effectivegatecpm.com/fdyxudzb52?key=c6b07a3f738ebead7c217a43e9b3c89a';

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

          // Bullet points centered under the title
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              bulletItem('Allow us to maintain cost for hosting'),
              bulletItem('Buy (or) Pay for plugins'),
              bulletItem('Provide support instantly'),
            ],
          ),

          ElevatedButton(
            onPressed: () async {
              final Uri adurl = Uri.parse(url);
              if (!await launchUrl(
                adurl,
                mode: LaunchMode.externalApplication,
              )) {
                throw ('Unable to launch url!');
              }
            },
            child: Text(
              'Click to support us!',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),

          Expanded(
            child: Markdown(
              data:
                  'Please remember **AD showen** on the page redirect are not set by us \n if you found ads disturbing please report to us on discord to filter it out',
              styleSheet: MarkdownStyleSheet(textAlign: WrapAlignment.center),
            ),
          ),
          SizedBox(
            width: 728,
            height: 90,
            child: ad.BannerAd728x90(adKey: '68bc87d2433b2f2a4f12af59a1379b9d'),
          ),

          SizedBox(
            width: 100,
            child: ad.SocialBarAd(scriptUrl: 'https://pl28605137.effectivegatecpm.com/77/8b/8c/778b8c911754911ff68964e9a6f72e06.js')),


          SizedBox(
            width: 300,
            height: 250,
            child: ad.NativeBannerAd(
              scriptUrl:
                  'https://pl28605019.effectivegatecpm.com/07b3366e08460cfc7ba1d4b71d138632/invoke.js',
            ),
          ),

          ad.PopunderAd(
            scriptUrl:
                'https://pl28596510.effectivegatecpm.com/6e/a5/ab/6ea5ab45b5ba791550e1267dc350c274.js',
          ),
        ],
      ),
    );
  }
}

// Custom bullet item widget
Widget bulletItem(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center, // center row horizontally
      children: [
        const Text("➤ ", style: TextStyle(color: Colors.green, fontSize: 18)),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            overflow: TextOverflow.fade,
          ),
        ),
      ],
    ),
  );
}
