import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/dashboardtitles.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
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
    final width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width < 700;
    final bool isTablet = width >= 700 && width < 1080;

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          padding: EdgeInsets.all(isMobile ? 14 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Dashboard',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Manage announcements, gallery content, memory requests, and server controls.',
                style: TextStyle(color: Colors.white70, height: 1.35),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 10),
          padding: EdgeInsets.all(isMobile ? 14 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _dmFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discord DM Broadcast',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Send one message to multiple users by Discord ID. Use commas, spaces, or new lines between IDs.',
                  style: TextStyle(color: Colors.white70, height: 1.35),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Each DM automatically includes sender name, UUID, sender Discord ID, send time (UTC), and server: FriendSMP75.',
                  style: TextStyle(color: Colors.white60, height: 1.3),
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
                    hintText: 'e.g. 123456789012345678, 234567890123456789',
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
                  onPressed: _isSendingDm ? null : _sendDmToMultiple,
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
                  label: Text(_isSendingDm ? 'Sending...' : 'Send to Multiple'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1E7AA7),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: isMobile
              ? 1
              : isTablet
              ? 2
              : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile
              ? 1.95
              : isTablet
              ? 1.35
              : 1.4,
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            DashboardTiles(
              title: 'Announcement',
              color: const Color(0xFF5B3FD6),
              icon: Icons.campaign_rounded,
              actionLabel: 'Manage',
              subText: 'Create and publish server updates for players.',
              onTap: () {
                context.push('/staff/announcements');
              },
            ),
            DashboardTiles(
              title: 'Gallery',
              color: const Color(0xFF1F7BD9),
              icon: Icons.photo_library_rounded,
              actionLabel: 'Upload',
              onTap: () {
                context.push('/staff/gallery');
              },
              subText: 'Upload new gallery photos for public display.',
            ),
            DashboardTiles(
              title: 'Approve Gallery Request',
              color: const Color(0xFF228B63),
              icon: Icons.fact_check_rounded,
              actionLabel: 'Review',
              onTap: () {
                context.push('/staff/gallery-requests');
              },
              subText: 'Review and approve members\' memory submissions.',
            ),
            DashboardTiles(
              title: 'Server access',
              color: Colors.redAccent,
              icon: Icons.verified_user_outlined,
              actionLabel: 'Server Access',
              onTap: () {
                context.push('/staff/server-access');
              },
              subText: 'Start, restart, and stop server operations.',
            ),
          ],
        ),
      ],
    );
  }
}
