import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart' as markdown;

class Staffannouncements extends StatefulWidget {
  const Staffannouncements({super.key});

  @override
  State<Staffannouncements> createState() => _StaffannouncementsState();
}

class _StaffannouncementsState extends State<Staffannouncements> {
  final announcementTitle = GlobalKey<FormState>();
  final TextEditingController _announcementTitleController =
      TextEditingController();

  final announcementBody = GlobalKey<FormState>();
  final TextEditingController _announcementBodyContoller =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _announcementTitleController.addListener(() => setState(() {}));
    _announcementBodyContoller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _announcementTitleController.dispose();
    _announcementBodyContoller.dispose();
    super.dispose();
  }

  Future<void> _submitAnnouncement() async {
    final messenger = ScaffoldMessenger.of(context);

    if (!announcementTitle.currentState!.validate() ||
        !announcementBody.currentState!.validate()) {
      return;
    }

    try {
      await BackendData.newAnnouncement(
        _announcementTitleController.text.trim(),
        _announcementBodyContoller.text,
      );

      _announcementBodyContoller.clear();
      _announcementTitleController.clear();

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline),
              SizedBox(width: 8),
              Text('Announcement published'),
            ],
          ),
          backgroundColor: Color(0xFF1E7AA7),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: $e')),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 760;
    final title = _announcementTitleController.text.trim();
    final body = _announcementBodyContoller.text.trim();

    return Scaffold(
      appBar: AppbarPage(backArrow: true),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF091323), Color(0xFF102037), Color(0xFF091323)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 20,
                  16,
                  isMobile ? 12 : 20,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A3656), Color(0xFF16506F)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Announcement Manager',
                            style: TextStyle(
                              fontSize: isMobile ? 30 : 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Write and preview updates before publishing to players.',
                            style: TextStyle(
                              color: Colors.blueGrey[100],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF66D3F2),
                              ),
                              SizedBox(width: 8),
                              Text('Fill in both fields to publish.'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Form(
                            key: announcementTitle,
                            child: TextFormField(
                              controller: _announcementTitleController,
                              decoration: InputDecoration(
                                labelText: 'Announcement Title',
                                hintText: 'Give this update a strong headline',
                                filled: true,
                                fillColor: Colors.black.withValues(alpha: 0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required';
                                }
                                if (value.length < 5) {
                                  return 'Title is too short';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Form(
                            key: announcementBody,
                            child: TextFormField(
                              minLines: 7,
                              maxLines: 12,
                              keyboardType: TextInputType.multiline,
                              controller: _announcementBodyContoller,
                              decoration: InputDecoration(
                                labelText: 'Announcement Body',
                                hintText: 'Use markdown for formatting',
                                filled: true,
                                fillColor: Colors.black.withValues(alpha: 0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required';
                                }
                                if (value.length < 15) {
                                  return 'Body is too short';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _submitAnnouncement,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1E7AA7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.campaign_outlined),
                              label: const Text('Publish Announcement'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Live Preview',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white12),
                              color: Colors.black.withValues(alpha: 0.2),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    12,
                                    12,
                                    6,
                                  ),
                                  child: Text(
                                    title.isEmpty
                                        ? 'Announcement title preview'
                                        : title,
                                    style: TextStyle(
                                      fontSize: isMobile ? 22 : 28,
                                      color: const Color(0xFF66D3F2),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: isMobile ? 210 : 250,
                                  child: markdown.Markdown(
                                    data: body.isNotEmpty
                                        ? body
                                        : '*No announcement body yet*',
                                    selectable: true,
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(12),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    10,
                                    12,
                                    10,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Colors.white12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'By ${SupabaseConfig.getDisplayName(BackendData.user)}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const Spacer(),
                                      FilledButton.tonalIcon(
                                        onPressed: title.isEmpty
                                            ? null
                                            : () {
                                                context.push(
                                                  '/announcement/${Uri.encodeComponent(title)}',
                                                  extra: {'body': body},
                                                );
                                              },
                                        icon: const Icon(
                                          Icons.open_in_new_rounded,
                                          size: 16,
                                        ),
                                        label: const Text('Preview Route'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
