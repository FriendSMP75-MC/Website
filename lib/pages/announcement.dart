import 'package:flutter/material.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/widgets/announcement_preview.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/nav_drawer.dart';

class ListAnnouncements extends StatefulWidget {
  const ListAnnouncements({super.key});

  @override
  State<ListAnnouncements> createState() => _ListAnnouncementsState();
}

class _ListAnnouncementsState extends State<ListAnnouncements> {
  List<dynamic> announcements = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAnnouncementList();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getAnnouncementList() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await BackendData.getAnnouncements();
      if (result == null) {
        throw Exception('Could not fetch announcements.');
      }

      if (!mounted) return;
      setState(() {
        announcements = result.reversed.toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _filteredAnnouncements() {
    final query = _searchController.text.trim().toLowerCase();
    final mapped = announcements.cast<Map<String, dynamic>>();
    if (query.isEmpty) {
      return mapped;
    }

    return mapped.where((announcement) {
      final title =
          announcement['announcement_title']?.toString().toLowerCase() ?? '';
      final body =
          announcement['announcement_body']?.toString().toLowerCase() ?? '';
      final author = announcement['author']?.toString().toLowerCase() ?? '';
      return title.contains(query) ||
          body.contains(query) ||
          author.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 800;
    final filtered = _filteredAnnouncements();

    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: NavDrawer(
        currentPage: 'Announcements',
        parentContext: context,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF091323), Color(0xFF102037), Color(0xFF091323)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 12 : 20,
                      18,
                      isMobile ? 12 : 20,
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isMobile ? 16 : 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A3656), Color(0xFF16516F)],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Server Announcements',
                                style: TextStyle(
                                  fontSize: isMobile ? 30 : 42,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Latest news, updates, and event information from the team.',
                                style: TextStyle(
                                  color: Colors.blueGrey[100],
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _HeaderPill(
                                    label: 'Total',
                                    value: '${announcements.length}',
                                    icon: Icons.campaign_rounded,
                                  ),
                                  _HeaderPill(
                                    label: 'Showing',
                                    value: '${filtered.length}',
                                    icon: Icons.filter_alt_rounded,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by title, content, or author',
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.06),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.white24,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF63CBED),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _errorMessage != null
                              ? _ErrorState(
                                  message: _errorMessage!,
                                  onRetry: _getAnnouncementList,
                                )
                              : filtered.isEmpty
                              ? const _EmptyState()
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double width = constraints.maxWidth;
                                    final int crossAxisCount = width < 760
                                        ? 1
                                        : width < 1080
                                        ? 2
                                        : 3;
                                    final double aspectRatio = width < 760
                                        ? 0.84
                                        : 0.92;

                                    return GridView.builder(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 14,
                                            mainAxisSpacing: 14,
                                            childAspectRatio: aspectRatio,
                                          ),
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) {
                                        final announcement = filtered[index];
                                        return AnnouncementPreview(
                                          announcement: announcement,
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeaderPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF84DAF5)),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search_off_rounded, size: 46, color: Colors.white54),
          SizedBox(height: 8),
          Text(
            'No announcements match your search.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
