import 'package:flutter/material.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

class Staffannouncements extends StatefulWidget {
  const Staffannouncements({super.key});

  @override
  State<Staffannouncements> createState() => _StaffannouncementsState();
}

class _StaffannouncementsState extends State<Staffannouncements> {
  //key and controller for announcement title
  final announcementTitle = GlobalKey<FormState>();
  final TextEditingController _announcementTitleController =
      TextEditingController();

  // key and controller for announcement body
  final announcementBody = GlobalKey<FormState>();
  final TextEditingController _announcementBodyContoller =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _announcementTitleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _announcementBodyContoller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(backArrow: true),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                'Add a new Announcemnt!',
                style: TextStyle(fontSize: 18),
              ),
            ),
            // Preview Info
            SizedBox(height: 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(Icons.info_outline, color: Colors.lightBlue),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('See the preview before adding announcement'),
                ),
              ],
            ),

            // Announcement title textfield
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

            // Announcemnet body textfield
            Form(
              key: announcementBody,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _announcementBodyContoller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter description of announcemnet',
                    labelText: 'Announcemnet Description',
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

            // Validation + adding announcement
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  // Styles
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    backgroundColor: Colors.lightBlueAccent,
                  ),

                  // Behaviour
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    if (announcementTitle.currentState!.validate() &&
                        announcementBody.currentState!.validate()) {
                      try {
                        await BackendData.newAnnouncement(
                          _announcementTitleController.text.trim(),
                          _announcementBodyContoller.text.trim(),
                        );

                        // clear text fields
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

            // Preview
            Center(
              child: Text(
                'Preview',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Divider(),

            // Mobile view
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8)
                              ),
                              color: const Color.fromARGB(255, 47, 47, 47),
                            ),
                            child: SizedBox(
                              height: 400,
                              child: Column(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                      child: Text(
                                        _announcementTitleController.text
                                            .trim(),
                                        style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Author and created at time
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            color: Colors.black45,
                          ),
                          child: Row(children: [Text('data')]),
                        ),
                      ],
                    );
                  } else {
                    // Desktop View
                    return Column();
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
