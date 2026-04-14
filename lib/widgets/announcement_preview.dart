import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart' as markdown;

class AnnouncementPreview extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementPreview({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final title =
        announcement['announcement_title']?.toString() ?? 'Announcement';
    final body = announcement['announcement_body']?.toString() ?? '';
    final author = announcement['author']?.toString() ?? 'Unknown';
    final date = announcement['created_at'] != null
        ? DateFormat(
            'dd MMM yyyy',
          ).format(DateTime.parse(announcement['created_at']))
        : 'Unknown date';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF66D3F2),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        color: Colors.black.withValues(alpha: 0.14),
                        child: markdown.Markdown(
                          data: body,
                          selectable: true,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'By $author • $date',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.push(
                      '/announcement/${Uri.encodeComponent(title)}',
                      extra: {'body': body},
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Read'),
                ),
              ],
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
    final title =
        announcement['announcement_title']?.toString() ?? 'Announcement';
    final body = announcement['announcement_body']?.toString() ?? '';
    final author = announcement['author']?.toString() ?? 'Unknown';
    final date = announcement['created_at'] != null
        ? DateFormat(
            'dd MMM yyyy',
          ).format(DateTime.parse(announcement['created_at']))
        : 'Unknown date';

    final bool isMobile = MediaQuery.sizeOf(context).width < 700;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF66D3F2),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: isMobile ? 180 : 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      color: Colors.black.withValues(alpha: 0.14),
                      child: markdown.Markdown(
                        data: body,
                        selectable: true,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'By $author • $date',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.push(
                      '/announcement/${Uri.encodeComponent(title)}',
                      extra: {'body': body},
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Read More'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
