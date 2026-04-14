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
    final bool isSmallScreen = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101B30), Color(0xFF0A1220)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Wrap(
            spacing: 24,
            runSpacing: 18,
            alignment: isSmallScreen
                ? WrapAlignment.center
                : WrapAlignment.spaceBetween,
            children: [
              Container(
                width: isSmallScreen ? double.infinity : 540,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.terrain_rounded, color: Color(0xFF43D3E2)),
                        SizedBox(width: 10),
                        Text(
                          'FriendSMP75',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A peaceful, community-first Minecraft server where collaboration matters more than competition.',
                      style: TextStyle(
                        color: Colors.blueGrey[100],
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'We are not affiliated with Minecraft or Mojang AB.',
                      style: TextStyle(
                        color: Colors.blueGrey[300],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: isSmallScreen ? double.infinity : 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CONNECT',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SocialLink(
                      icon: Icons.play_arrow_rounded,
                      label: 'YouTube',
                      color: Colors.red,
                      onTap: () => _launchUrl(
                        context,
                        'https://www.youtube.com/@FriendSMP75',
                      ),
                    ),
                    _SocialLink(
                      icon: Icons.discord,
                      label: 'Discord',
                      color: Colors.indigoAccent,
                      onTap: () => _launchUrl(
                        context,
                        'https://discord.com/invite/K8ucVvjfge',
                      ),
                    ),
                    _SocialLink(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      color: Colors.greenAccent,
                      onTap: () =>
                          _launchUrl(context, 'mailto:friendsmp75@outlook.com'),
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
