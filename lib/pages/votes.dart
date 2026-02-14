import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class VotePage extends StatelessWidget {
  const VotePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: NavDrawer(currentPage: 'Vote', parentContext: context),
      body: SingleChildScrollView(
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
                    child: Text(
                      'Voting Sites',
                      style: TextStyle(
                        fontSize: screenWidth > 600 ? 48 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Flex(
                      direction: screenWidth > 1100
                          ? Axis.horizontal
                          : Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: VoteButtons(
                            siteName: 'Minecraft IP List',
                            votingUrls:
                                'https://www.minecraftiplist.com/server/FriendSMP75-39197',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: VoteButtons(
                            siteName: 'PlanetMinecraft',
                            votingUrls:
                                'https://www.planetminecraft.com/server/friendsmp75/vote/',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Flex(
                      direction: screenWidth > 1100
                          ? Axis.horizontal
                          : Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: VoteButtons(
                            siteName: 'Minecraft List',
                            votingUrls: 'https://minecraftlist.org/vote/34029',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: VoteButtons(
                            siteName: 'MC Rank',
                            votingUrls: 'https://mcrank.com/server/friendsmp75',
                          ),
                        ),
                      ],
                    ),
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

class VoteButtons extends StatelessWidget {
  final String siteName;
  final String votingUrls;
  const VoteButtons({
    super.key,
    required this.siteName,
    required this.votingUrls,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth > 600 ? 500 : screenWidth * 0.85;

    return SizedBox(
      width: buttonWidth,
      height: screenWidth > 600 ? 180 : 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          Uri url = Uri.parse(votingUrls);
          try {
            if (await canLaunchUrl(url)) {
              launchUrl(url, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            debugPrint('Cannot launch voting site url');
          }
        },
        child: Text(
          siteName,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: screenWidth > 600 ? 30 : 22),
        ),
      ),
    );
  }
}
