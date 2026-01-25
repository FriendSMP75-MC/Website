import 'package:flutter/material.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/sub_page/view_announcements.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart' as markdown;

SupabaseClient get supabase => Supabase.instance.client;

class Staffannouncements extends StatefulWidget {
  const Staffannouncements({super.key});

  @override
  State<Staffannouncements> createState() => _StaffannouncementsState();
}

class _StaffannouncementsState extends State<Staffannouncements> {
  // Keys and controllers
  final announcementTitle = GlobalKey<FormState>();
  final TextEditingController _announcementTitleController =
      TextEditingController();

  final announcementBody = GlobalKey<FormState>();
  final TextEditingController _announcementBodyContoller =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _announcementTitleController.addListener(() {
      setState(() {});
    });
    _announcementBodyContoller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _announcementTitleController.dispose();
    _announcementBodyContoller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(backArrow: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Manage Announcements',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Divider(),

            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Add a new Announcement!',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.lightBlue),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('See the preview before adding announcement'),
                ),
              ],
            ),

            // AnnouncementTitle textfield
            Form(
              key: announcementTitle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _announcementTitleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Give title for announcement',
                    labelText: 'Announcement Title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (value.length < 5) {
                      return 'Text is too small';
                    }
                    return null;
                  },
                ),
              ),
            ),

            // AnnouncemnetBody textfield
            Form(
              key: announcementBody,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  minLines: 5,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  controller: _announcementBodyContoller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter description of announcement',
                    labelText: 'Announcement Description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (value.length < 15) {
                      return 'Text is too small';
                    }
                    return null;
                  },
                ),
              ),
            ),

            // Submit button
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    if (announcementTitle.currentState!.validate() &&
                        announcementBody.currentState!.validate()) {
                      try {
                        await BackendData.newAnnouncement(
                          _announcementTitleController.text.trim(),
                          _announcementBodyContoller.text,
                        );

                        _announcementBodyContoller.clear();
                        _announcementTitleController.clear();

                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.info),
                                SizedBox(width: 8),
                                Text(
                                  'Announcement Added!',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.purpleAccent[100],
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Error: $e'),
                              ],
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Add Announcement!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            Divider(),

            // Preview header
            Center(
              child: Text(
                'Preview',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Divider(),

            // Mobile view preview
            Padding(
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
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    8,
                                    8,
                                    0,
                                  ),
                                  child: Text(
                                    _announcementTitleController.text.trim(),
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
                                      data:
                                          _announcementBodyContoller
                                              .text
                                              .isNotEmpty
                                          ? _announcementBodyContoller.text
                                          : "*No announcement body yet*",
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
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => ViewAnnouncement(
                                        title:
                                            _announcementTitleController.text,
                                        body: _announcementBodyContoller.text,
                                      ),
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
                            height: 70,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Authored By'),
                                      Text(SupabaseConfig.getDisplayName(user)),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Created on'),
                                      Text("Today's Date will be displayed"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Desktop view placeholder
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
                            height: 200,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    8,
                                    8,
                                    0,
                                  ),
                                  child: Text(
                                    _announcementTitleController.text.trim(),
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
                                      data:
                                          _announcementBodyContoller
                                              .text
                                              .isNotEmpty
                                          ? _announcementBodyContoller.text
                                          : "*No announcement body yet*",
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
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => ViewAnnouncement(
                                        title:
                                            _announcementTitleController.text,
                                        body: _announcementBodyContoller.text,
                                      ),
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
                            height: 70,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Authored By'),
                                      Text(SupabaseConfig.getDisplayName(user)),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Created on'),
                                      Text("Today's Date will be displayed"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
