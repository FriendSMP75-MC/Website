import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart' as markdown;
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

class AnnouncementMarkdownView extends StatelessWidget {
  final String body;
  final EdgeInsetsGeometry padding;
  final String emptyMessage;

  const AnnouncementMarkdownView({
    super.key,
    required this.body,
    this.padding = EdgeInsets.zero,
    this.emptyMessage = 'No announcement body yet',
  });

  Future<void> _openLink(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final value = body.trim();

    if (value.isEmpty) {
      return Padding(
        padding: padding,
        child: Center(
          child: Text(
            emptyMessage,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: markdown.MarkdownBody(
        data: value,
        extensionSet: md.ExtensionSet.gitHubWeb,
        selectable: true,
        onTapLink: (text, href, title) => _openLink(href),
      ),
    );
  }
}
