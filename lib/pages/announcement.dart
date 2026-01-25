import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart' as markdown;
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/sub_page/view_announcements.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:intl/intl.dart';

class ListAnnouncements extends StatefulWidget {
  const ListAnnouncements({super.key});

  @override
  State<ListAnnouncements> createState() => _ListAnnouncementsState();
}

class _ListAnnouncementsState extends State<ListAnnouncements> {
  List<dynamic> announcements = [];

  @override
  void initState() {
    super.initState();
    _getAnnouncementList();
  }

  Future<void> _getAnnouncementList() async {
    final result = await BackendData.getAnnouncements();
    if (result != null) {
      setState(() {
        announcements = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: NavDrawer(
        currentPage: 'Announcements',
        parentContext: context,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement =
                    announcements[index] as Map<String, dynamic>;
                return AnnouncementPreview(announcement: announcement);
              },
            );
          } else {
            return Column();
          }
        },
      ),
    );
  }
}

class AnnouncementPreview extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementPreview({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final title = announcement['announcement_title'];
    final date = announcement['created_at'] != null
        ? DateFormat(
            'dd MMMM yyyy',
          ).format(DateTime.parse(announcement['created_at']))
        : 'No date?';
    final body = announcement['announcement_body'];
    final author = announcement['author'];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    color: Colors.white10,
                  ),
                  child: SizedBox(
                    height: 400,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.blue.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: OverflowBox(
                            maxHeight: 400,
                            child: markdown.Markdown(
                              physics: NeverScrollableScrollPhysics(),
                              data: body,
                              selectable: true,
                              shrinkWrap: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: Colors.blueAccent,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ViewAnnouncement(title: title, body: body),
                        ),
                      );
                    },
                    child: Text(
                      'Read more!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                // Author details
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    color: const Color.fromARGB(130, 195, 17, 17),
                  ),
                  child: SizedBox(
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text('Authored By'), Text(author)],
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [Text('Created on'), Text(date)],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column();
          }
        },
      ),
    );
  }
}
