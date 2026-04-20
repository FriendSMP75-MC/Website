import 'package:flutter/material.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:server_site/widgets/nav_drawer.dart';

class StaffDmBroadcastPage extends StatefulWidget {
  const StaffDmBroadcastPage({super.key});

  @override
  State<StaffDmBroadcastPage> createState() => _StaffDmBroadcastPageState();
}

class _StaffDmBroadcastPageState extends State<StaffDmBroadcastPage> {
  final _dmFormKey = GlobalKey<FormState>();
  final TextEditingController _discordIdsController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSendingDm = false;

  @override
  void dispose() {
    _discordIdsController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  List<String> _extractDiscordIds(String raw) {
    final parts = raw.split(RegExp(r'[\s,;]+'));
    final seen = <String>{};
    final result = <String>[];

    for (final item in parts) {
      final id = item.trim();
      if (id.isEmpty) continue;
      final valid = RegExp(r'^\d{17,20}$').hasMatch(id);
      if (!valid) continue;
      if (seen.add(id)) {
        result.add(id);
      }
    }
    return result;
  }

  Future<void> _sendDmToMultiple() async {
    final valid = _dmFormKey.currentState?.validate() ?? false;
    if (!valid || _isSendingDm) {
      return;
    }

    final user = SupabaseConfig.client.auth.currentUser;
    final senderUuid = SupabaseConfig.getSupabaseUUID(user);
    final senderName = SupabaseConfig.getUserName(user);
    final senderDiscordId = SupabaseConfig.getDiscordId(user);

    final recipients = _extractDiscordIds(_discordIdsController.text);
    final message = _messageController.text.trim();

    setState(() => _isSendingDm = true);
    final result = await BackendData.sendDirectMessageToMany(
      recipientDiscordIds: recipients,
      message: message,
      senderUuid: senderUuid,
      senderName: senderName,
      senderDiscordId: senderDiscordId,
      serverName: 'FriendSMP75',
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSendingDm = false);

    if (result.sentCount > 0) {
      _messageController.clear();
    }

    final successText =
        'Sent to ${result.sentCount}/${recipients.length} users';
    final failedCount = result.failedIds.length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failedCount == 0
              ? '$successText successfully.'
              : '$successText. Failed: $failedCount.',
        ),
        backgroundColor: failedCount == 0
            ? const Color(0xFF1E7AA7)
            : const Color(0xFFFFB347),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 760;

    return Scaffold(
      appBar: AppbarPage(backArrow: true),
      endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
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
              constraints: const BoxConstraints(maxWidth: 920),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 20,
                  16,
                  isMobile ? 12 : 20,
                  0,
                ),
                child: Column(
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
                        children: const [
                          Text(
                            'DM Announcer',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Send one announcement to multiple users by Discord ID.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Form(
                        key: _dmFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Use commas, spaces, or new lines between IDs.',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Each DM includes sender name, UUID, sender Discord ID, send time (UTC), and server: FriendSMP75.',
                              style: TextStyle(color: Colors.white60),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _discordIdsController,
                              minLines: 2,
                              maxLines: 4,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Discord IDs',
                                hintText:
                                    'e.g. 123456789012345678, 234567890123456789',
                                filled: true,
                                fillColor: Colors.black.withValues(alpha: 0.18),
                              ),
                              validator: (value) {
                                final raw = value?.trim() ?? '';
                                if (raw.isEmpty) {
                                  return 'Enter at least one Discord ID';
                                }
                                final ids = _extractDiscordIds(raw);
                                if (ids.isEmpty) {
                                  return 'No valid Discord IDs found';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _messageController,
                              minLines: 3,
                              maxLines: 6,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                alignLabelWithHint: true,
                                labelText: 'Message',
                                hintText: 'Type your direct message',
                                filled: true,
                                fillColor: Colors.black.withValues(alpha: 0.18),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) {
                                  return 'Please enter a message';
                                }
                                if (text.length < 2) {
                                  return 'Message is too short';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _isSendingDm
                                  ? null
                                  : _sendDmToMultiple,
                              icon: _isSendingDm
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: Text(
                                _isSendingDm
                                    ? 'Sending...'
                                    : 'Send to Multiple',
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1E7AA7),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
