import 'dart:async';
import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:server_site/widgets/footer.dart';

SupabaseClient get supabase => Supabase.instance.client;

class GalleryImage {
  final int id;
  final String location;
  final String publicUrl;
  final String uploadUuid;
  final String uploadName;
  final DateTime createdAt;
  final DateTime imageTakenDate;
  final Map<String, dynamic> rawData;

  GalleryImage({
    required this.id,
    required this.location,
    required this.publicUrl,
    required this.uploadUuid,
    required this.uploadName,
    required this.createdAt,
    required this.imageTakenDate,
    required this.rawData,
  });

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  static DateTime _readDateTime(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final raw = json[key];
      if (raw == null) {
        continue;
      }
      final parsed = DateTime.tryParse(raw.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return DateTime.now();
  }

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'] ?? 0,
      location: _readString(json, const ['location', 'storage_path'], ''),
      publicUrl: _readString(json, const [
        'public_url',
        'image_url',
        'url',
      ], ''),
      uploadUuid: _readString(json, const [
        'upload_uuid',
        'author_uuid',
        'request_uuid',
      ], ''),
      uploadName: _readString(json, const [
        'upload_name',
        'author',
        'display_name',
      ], 'Unknown'),
      createdAt: _readDateTime(json, const ['created_at', 'submitted_at']),
      imageTakenDate: _readDateTime(json, const [
        'image_taken_date',
        'time_taken',
        'taken_date',
        'date_taken',
      ]),
      rawData: json,
    );
  }
}

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

enum GallerySection { groupPhotos, memories }

class _GalleryState extends State<Gallery> {
  StreamSubscription<AuthState>? _authSub;
  List<GalleryImage>? _galleryImages;
  bool _isLoading = true;
  String? _errorMessage;
  GallerySection _selectedSection = GallerySection.groupPhotos;

  String _readRawString(
    Map<String, dynamic> data,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  bool _isMemoryImage(GalleryImage image) {
    final typeValue = _readRawString(image.rawData, const [
      'section',
      'gallery_section',
      'image_type',
      'category',
      'source',
    ], '').toLowerCase();

    if (typeValue.contains('memory')) {
      return true;
    }
    if (typeValue.contains('group')) {
      return false;
    }

    final status = _readRawString(image.rawData, const [
      'status',
      'request_status',
    ], '').toLowerCase();
    if (status == 'approved') {
      return true;
    }

    return image.rawData.containsKey('request_uuid') ||
        image.rawData.containsKey('request_id') ||
        image.rawData.containsKey('time_taken');
  }

  bool _isApprovedMemoryImage(GalleryImage image) {
    final status = _readRawString(image.rawData, const [
      'status',
      'request_status',
    ], '').toLowerCase();

    if (_isMemoryImage(image) && status.isEmpty) {
      return true;
    }

    return _isMemoryImage(image) && status == 'approved';
  }

  List<GalleryImage> _groupPhotoImages() {
    final images = _galleryImages ?? const <GalleryImage>[];
    return images.where((image) => !_isMemoryImage(image)).toList();
  }

  List<GalleryImage> _approvedMemoryImages() {
    final images = _galleryImages ?? const <GalleryImage>[];
    return images.where(_isApprovedMemoryImage).toList();
  }

  String _dedupeKey(GalleryImage image) {
    final idPart = image.id > 0 ? image.id.toString() : 'none';
    final locationPart = image.location.trim().isNotEmpty
        ? image.location.trim()
        : 'none';
    final urlPart = image.publicUrl.trim().isNotEmpty
        ? image.publicUrl.trim()
        : 'none';
    final sourcePart = _isMemoryImage(image) ? 'memory' : 'gallery';

    return '$sourcePart|$idPart|$locationPart|$urlPart';
  }

  @override
  void initState() {
    super.initState();
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
    });
    _fetchGalleryData();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchGalleryData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await BackendData.getGalleryData();
      final approvedMemoriesResponse =
          await BackendData.getPublicApprovedImages();

      if (response == null) {
        throw Exception('Failed to fetch gallery data from backend');
      }

      final List<GalleryImage> imageList = [];
      final Set<String> seenKeys = <String>{};

      for (var item in response) {
        final image = GalleryImage.fromJson(item as Map<String, dynamic>);
        final key = _dedupeKey(image);
        if (seenKeys.add(key)) {
          imageList.add(image);
        }
      }

      if (approvedMemoriesResponse != null) {
        for (final item in approvedMemoriesResponse) {
          final normalized = Map<String, dynamic>.from(item)
            ..putIfAbsent('status', () => 'Approved')
            ..putIfAbsent('section', () => 'memories');

          final image = GalleryImage.fromJson(normalized);
          if (image.publicUrl.trim().isEmpty) {
            continue;
          }

          final key = _dedupeKey(image);
          if (seenKeys.add(key)) {
            imageList.add(image);
          }
        }
      }

      if (mounted) {
        setState(() {
          _galleryImages = imageList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error fetching gallery info: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    SupabaseConfig.getUserName(user);
    final bool isMobile = MediaQuery.sizeOf(context).width < 760;

    return Scaffold(
      appBar: AppbarPage(customTitle: 'FriendSMP75 - Gallery'),
      endDrawer: NavDrawer(currentPage: 'Gallery', parentContext: context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF091323), Color(0xFF102037), Color(0xFF091323)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 8 : 14,
            10,
            isMobile ? 8 : 14,
            0,
          ),
          child: Column(children: [Expanded(child: _buildBody())]),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Column(
        children: const [
          Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
            ),
          ),
          MyFooter(),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchGalleryData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          const MyFooter(),
        ],
      );
    }

    if (_galleryImages == null || _galleryImages!.isEmpty) {
      return Column(
        children: const [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No images found in gallery',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          MyFooter(),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchGalleryData,
      color: const Color(0xFF4A90E2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final groupPhotos = _groupPhotoImages();
          final approvedMemories = _approvedMemoryImages();
          int crossAxisCount;
          double childAspectRatio;

          if (constraints.maxWidth < 600) {
            crossAxisCount = 1;
            childAspectRatio = 0.95;
          } else if (constraints.maxWidth < 1000) {
            crossAxisCount = 2;
            childAspectRatio = 0.95;
          } else {
            crossAxisCount = 3;
            childAspectRatio = 0.95;
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A3556), Color(0xFF17516F)],
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Explore group photos and approved community memories.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildSectionSwitcher(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (_selectedSection == GallerySection.groupPhotos) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Group Photos',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: groupPhotos.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: Center(
                              child: Text('No group photos available.'),
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: childAspectRatio,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final image = groupPhotos[index];
                            return _buildGalleryItem(image);
                          }, childCount: groupPhotos.length),
                        ),
                ),
              ] else ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Memories',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  sliver: approvedMemories.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: Center(
                              child: Text(
                                'No approved memories available yet.',
                              ),
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: childAspectRatio,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final image = approvedMemories[index];
                            return _buildGalleryItem(image);
                          }, childCount: approvedMemories.length),
                        ),
                ),
              ],
              const SliverToBoxAdapter(child: MyFooter()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionSwitcher() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSectionChip(
              label: 'Group Photos',
              selected: _selectedSection == GallerySection.groupPhotos,
              onTap: () {
                setState(() {
                  _selectedSection = GallerySection.groupPhotos;
                });
              },
            ),
            _buildSectionChip(
              label: 'Memories',
              selected: _selectedSection == GallerySection.memories,
              onTap: () {
                setState(() {
                  _selectedSection = GallerySection.memories;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: selected
            ? const LinearGradient(
                colors: [Color(0xFF2783C0), Color(0xFF2D9FD1)],
              )
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryItem(GalleryImage image) {
    final bool memoryCard = _isMemoryImage(image);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showImageDialog(image),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A2740), Color(0xFF122038)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          image.publicUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFF4A90E2),
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          left: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              memoryCard ? 'MEMORY' : 'GROUP',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetaItem(
                              'Uploaded By',
                              image.uploadName,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetaItem(
                              'Posted on',
                              _formatDate(image.createdAt),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1E7AA7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _showImageDialog(image),
                          icon: const Icon(Icons.zoom_in_rounded, size: 18),
                          label: const Text('View Image'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageDialog(GalleryImage image) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF102036),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: double.infinity,
                height: constraints.maxHeight,
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            InteractiveViewer(
                              minScale: 1,
                              maxScale: 4,
                              child: Container(
                                color: const Color(0xFF0B1426),
                                alignment: Alignment.center,
                                child: Image.network(
                                  image.publicUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Padding(
                                      padding: EdgeInsets.all(48.0),
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E7AA7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          runSpacing: 10,
                          spacing: 12,
                          children: [
                            _metaBlock('Uploaded By', image.uploadName),
                            _metaBlock(
                              'Created on',
                              _formatDate(image.createdAt),
                            ),
                            _metaBlock(
                              'Taken on',
                              _formatDate(image.imageTakenDate),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _metaBlock(String label, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 220),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
