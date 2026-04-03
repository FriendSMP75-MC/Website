import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart' as markdown;

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
      child: Column(
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
                    child: markdown.Markdown(
                      physics: NeverScrollableScrollPhysics(),
                      data: body,
                      selectable: true,
                      shrinkWrap: true,
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
                elevation: 0,
                backgroundColor: Colors.blueAccent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
              ),
              onPressed: () {
                context.push(
                  '/announcement/${Uri.encodeComponent(title)}',
                  extra: {'body': body},
                );
              },
              child: Text('Read more!', style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}

class LatestAnnouncementPreview extends StatelessWidget {
  final Map<String, dynamic> announcement;
  const LatestAnnouncementPreview({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final title = announcement['announcement_title'];
    final body = announcement['announcement_body'];
    final author = announcement['author'];
    final date = announcement['created_at'] != null
        ? DateFormat(
            'dd MMMM yyyy',
          ).format(DateTime.parse(announcement['created_at']))
        : 'no date';

    return LayoutBuilder(
      builder: (context, constraints) {
        double padding = 0;
        double sizedBoxWidth = 0;
        double sizedBoxHeight = 0;

        if (constraints.maxWidth < 600) {
          padding = 8.0;
          sizedBoxWidth = MediaQuery.widthOf(context);
          sizedBoxHeight = 300;
        } else {
          padding = 10.0;
          sizedBoxWidth = MediaQuery.widthOf(context) - 200;
          sizedBoxHeight = 300;
        }

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
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
                  height: sizedBoxHeight,
                  width: sizedBoxWidth,
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
                        child: markdown.Markdown(
                          physics: NeverScrollableScrollPhysics(),
                          data: body,
                          selectable: true,
                          shrinkWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: sizedBoxWidth,
                color: Colors.blueAccent,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.blueAccent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    context.push(
                      '/announcement/${Uri.encodeComponent(title)}',
                      extra: {'body': body},
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
                  width: sizedBoxWidth,
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
          ),
        );
      },
    );
  }
}
