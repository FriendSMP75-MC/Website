import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MyFooter extends StatelessWidget {
  const MyFooter({super.key});

  Future<void> _launchUrl(BuildContext context, String link) async {
    final Uri url = Uri.parse(link);

    try {
      final bool launched;

      if (url.scheme == 'mailto') {
        launched = kIsWeb
            ? await launchUrl(url, webOnlyWindowName: '_self')
            : await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        launched = await launchUrl(url, mode: LaunchMode.platformDefault);
      }

      if (!launched) {
        if (url.scheme == 'mailto') {
          await Clipboard.setData(ClipboardData(text: url.path));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Could not open mail app. Email copied: ${url.path}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.purpleAccent[100],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        debugPrint('Could not launch $link');
      }
    } catch (e) {
      if (url.scheme == 'mailto') {
        await Clipboard.setData(ClipboardData(text: url.path));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Could not open mail app. Email copied: ${url.path}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.purpleAccent[100],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the screen is narrow (Mobile/Small Tablet)
    final bool isSmallScreen = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 80, // Horizontal space between blocks
            runSpacing: 40, // Vertical space when wrapped
            alignment: isSmallScreen
                ? WrapAlignment.center
                : WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              // Non affiliated info
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: isSmallScreen
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FriendSMP75',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We are not affiliated with Minecraft or Mojang AB.',
                      textAlign: isSmallScreen
                          ? TextAlign.center
                          : TextAlign.start,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Connections
              Column(
                crossAxisAlignment: isSmallScreen
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONNECT WITH US',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SocialLink(
                    icon: Icons.play_arrow_rounded,
                    label: 'YouTube',
                    color: Colors.red,
                    onTap: () =>
                        _launchUrl(context, 'https://www.youtube.com/@FriendSMP75'),
                  ),
                  _SocialLink(
                    icon: Icons.discord,
                    label: 'Discord',
                    color: Colors.indigoAccent,
                    onTap: () =>
                        _launchUrl(context, 'https://discord.com/invite/K8ucVvjfge'),
                  ),
                  _SocialLink(
                    icon: Icons.email,
                    label: 'Email',
                    color: Colors.green,
                    onTap: () =>
                        _launchUrl(context, 'mailto:friendsmp75@outlook.com'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialLink({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
