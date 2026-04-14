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
    final bool isMobile = MediaQuery.sizeOf(context).width < 760;

    return Scaffold(
      appBar: AppbarPage(customTitle: 'FriendSMP75 - Support us'),
      endDrawer: NavDrawer(currentPage: 'Support us', parentContext: context),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A1423), Color(0xFF102036), Color(0xFF0A1423)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 20,
                  18,
                  isMobile ? 12 : 20,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 16 : 22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2B395F), Color(0xFF214E6F)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Support FriendSMP75',
                            style: TextStyle(
                              fontSize: isMobile ? 30 : 42,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your support keeps hosting running and helps us improve maps, plugins, and events.',
                            style: TextStyle(
                              color: Colors.blueGrey[100],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Container(
                        height: 190,
                        width: 340,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: HtmlElementView(viewType: _adViewType),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Why support us?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        Whylist(
                          text: 'Server hosting and infrastructure costs',
                          icon: Icons.cloud_done_rounded,
                        ),
                        Whylist(
                          text: 'Plugins, tools, and quality-of-life upgrades',
                          icon: Icons.extension_rounded,
                        ),
                        Whylist(
                          text: 'Developers and map creators',
                          icon: Icons.handyman_rounded,
                        ),
                        Whylist(
                          text: 'Keeping the server online long-term',
                          icon: Icons.favorite_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C4B),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _launchSmartlink,
                        icon: const Icon(Icons.favorite),
                        label: const Text('Support The Server'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Center(
                        child: Text(
                          'Supporting opens a sponsor page in a new tab.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const MyFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Whylist extends StatelessWidget {
  final String text;
  final IconData icon;
  const Whylist({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF43D3E2)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
