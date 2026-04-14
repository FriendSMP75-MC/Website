import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class VotePage extends StatelessWidget {
  const VotePage({super.key});

  static const _sites = [
    (
      name: 'Xyrios',
      url: 'https://xyrios.com/minecraft/servers/355',
      icon: Icons.verified_rounded,
      color: Color(0xFF58C5A2),
    ),
    (
      name: 'PlanetMinecraft',
      url: 'https://www.planetminecraft.com/server/friendsmp75/vote/',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF7D68FF),
    ),
    (
      name: 'Minecraft List',
      url: 'https://minecraftlist.org/vote/34029',
      icon: Icons.hub_rounded,
      color: Color(0xFF23A37B),
    ),
    (
      name: 'MC Rank',
      url: 'https://mcrank.com/server/friendsmp75',
      icon: Icons.trending_up_rounded,
      color: Color(0xFFFF8A4B),
    ),
    (
      name: 'Minecraft IP List',
      url: 'https://www.minecraftiplist.com/server/FriendSMP75-39197',
      icon: Icons.public_rounded,
      color: Color(0xFF2F89FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 760;

    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: NavDrawer(currentPage: 'Vote', parentContext: context),
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
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 14 : 22,
                      22,
                      isMobile ? 14 : 22,
                      10,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 16 : 22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF21395A), Color(0xFF1C4A6F)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vote For FriendSMP75',
                            style: TextStyle(
                              fontSize: isMobile ? 30 : 44,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Voting helps more players discover the server and keeps the community growing.',
                            style: TextStyle(
                              color: Colors.blueGrey[100],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 14 : 22,
                      8,
                      isMobile ? 14 : 22,
                      14,
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _sites.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: isMobile ? 2.15 : 2.2,
                      ),
                      itemBuilder: (context, index) {
                        final site = _sites[index];
                        return VoteButtons(
                          siteName: site.name,
                          votingUrls: site.url,
                          icon: site.icon,
                          color: site.color,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const MyFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VoteButtons extends StatelessWidget {
  final String siteName;
  final String votingUrls;
  final IconData icon;
  final Color color;

  const VoteButtons({
    super.key,
    required this.siteName,
    required this.votingUrls,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final url = Uri.parse(votingUrls);
          try {
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          } catch (_) {}
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  siteName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.open_in_new_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
