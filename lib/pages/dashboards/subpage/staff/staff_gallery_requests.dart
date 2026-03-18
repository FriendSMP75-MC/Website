import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

class StaffGalleryRequestsPage extends StatefulWidget {
  const StaffGalleryRequestsPage({super.key});

  @override
  State<StaffGalleryRequestsPage> createState() =>
      _StaffGalleryRequestsPageState();
}

class _StaffGalleryRequestsPageState extends State<StaffGalleryRequestsPage> {
  StreamSubscription<AuthState>? _authSub;

  List<Map<String, dynamic>> _requests = [];
  bool _isLoadingRequests = false;
  bool _isUpdatingRequest = false;
  bool _isDeletingRequest = false;
  String? _loadError;
  String _selectedStatusSort = 'all';
  String _selectedDateSort = 'newest';

  String _readString(
    Map<String, dynamic> request,
    List<String> possibleKeys,
    String fallback,
  ) {
    for (final key in possibleKeys) {
      final value = request[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  String _formatDateTimeForCard(String rawValue) {
    if (rawValue.trim().isEmpty || rawValue == '-') {
      return '-';
    }

    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) {
      return rawValue;
    }

    return DateFormat('hh:mm a, dd MMMM yyyy').format(parsed.toLocal());
  }

  String _formatDateForCard(String rawValue) {
    if (rawValue.trim().isEmpty || rawValue == '-') {
      return '-';
    }

    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) {
      return rawValue;
    }

    return DateFormat('dd MMMM yyyy').format(parsed.toLocal());
  }

  String _readRequestId(Map<String, dynamic> request) {
    return _readString(request, const ['id', 'request_id', 'memory_id'], '-');
  }

  String _readRequestStatus(Map<String, dynamic> request) {
    final raw = _readString(
      request,
      const ['status', 'request_status'],
      'pending',
    );
    return raw.toLowerCase();
  }

  String _statusLabel(String status) {
    if (status.isEmpty) {
      return 'Pending';
    }
    return '${status[0].toUpperCase()}${status.substring(1)}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF1B8A5A);
      case 'rejected':
        return const Color(0xFFB23A3A);
      default:
        return const Color(0xFF9A6A00);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.verified_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  int _countByStatus(String target) {
    return _requests.where((request) {
      return _readRequestStatus(request) == target;
    }).length;
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            _statusLabel(status),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountPill({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: $count',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A3A),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF3A4A63)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9DB3D1)),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(
              color: Color(0xFFE3EBF8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTrigger({
    required IconData icon,
    required String label,
    double width = 170,
  }) {
    return Container(
      width: width,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2736),
        border: Border.all(color: const Color(0xFF3A4A63)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB7CAE5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFE3EBF8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusSortLabel(String value) {
    switch (value) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'All';
    }
  }

  String _dateSortLabel(String value) {
    switch (value) {
      case 'oldest':
        return 'Oldest';
      default:
        return 'Newest';
    }
  }

  DateTime _requestSortDate(Map<String, dynamic> request) {
    final submittedRaw = _readString(request, const [
      'created_at',
      'submitted_at',
      'date',
    ], '');
    final parsed = DateTime.tryParse(submittedRaw);
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  List<Map<String, dynamic>> _visibleRequests() {
    final filtered = _selectedStatusSort == 'all'
        ? List<Map<String, dynamic>>.from(_requests)
        : _requests.where((request) {
            final status = _readRequestStatus(request);
            return status == _selectedStatusSort;
          }).toList();

    filtered.sort((a, b) {
      final aDate = _requestSortDate(a);
      final bDate = _requestSortDate(b);
      if (_selectedDateSort == 'oldest') {
        return aDate.compareTo(bDate);
      }
      return bDate.compareTo(aDate);
    });

    return filtered;
  }

  String? _extractUrlString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    if (value is Map) {
      const nestedKeys = [
        'public_url',
        'publicUrl',
        'url',
        'signed_url',
        'signedUrl',
        'src',
        'path',
      ];
      for (final key in nestedKeys) {
        final nestedValue = value[key];
        if (nestedValue is String && nestedValue.trim().isNotEmpty) {
          return nestedValue.trim();
        }
      }
    }

    return null;
  }

  bool _isAbsoluteUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String? _buildStoragePublicUrl(String? rawPath) {
    if (rawPath == null || rawPath.trim().isEmpty) {
      return null;
    }

    final normalizedPath =
        rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
    if (normalizedPath.isEmpty) {
      return null;
    }

    return SupabaseConfig.client.storage
        .from('members_memories_request')
        .getPublicUrl(normalizedPath);
  }

  String? _resolveImageUrl(Map<String, dynamic> request) {
    const urlKeys = [
      'public_url',
      'publicUrl',
      'image_public_url',
      'signed_url',
      'signedUrl',
      'image_url',
      'imageUrl',
      'url',
      'file_url',
      'photo_url',
    ];

    for (final key in urlKeys) {
      final resolved = _extractUrlString(request[key]);
      if (resolved != null && _isAbsoluteUrl(resolved)) {
        return resolved;
      }
    }

    final storagePath = _extractUrlString(request['storage_path']) ??
        _extractUrlString(request['image_location']) ??
        _extractUrlString(request['path']) ??
        _extractUrlString(request['image']) ??
        _extractUrlString(request['photo']) ??
        _extractUrlString(request['file']);

    final storagePublicUrl = _buildStoragePublicUrl(storagePath);
    if (storagePublicUrl != null) {
      return storagePublicUrl;
    }

    return null;
  }

  Widget _buildRequestPreview(Map<String, dynamic> request) {
    final imageUrl = _resolveImageUrl(request);
    if (imageUrl == null) {
      return Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.photo_library_outlined),
      );
    }

    return GestureDetector(
      onTap: () => _showFullImagePreview(imageUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 170,
                  width: double.infinity,
                  color: const Color(0xFFF2F2F2),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                );
              },
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(160),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_full, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Full image',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImagePreview(String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 780),
            color: Colors.black,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Center(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                            size: 64,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Close',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadRequests() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _requests = [];
        _loadError = null;
        _isLoadingRequests = false;
      });
      return;
    }

    setState(() {
      _isLoadingRequests = true;
      _loadError = null;
    });

    final result = await BackendData.getStaffMemoryRequests();

    if (!mounted) return;
    if (result == null) {
      setState(() {
        _isLoadingRequests = false;
        _loadError = 'Failed to load memory requests.';
      });
      return;
    }

    setState(() {
      _requests = result;
      _isLoadingRequests = false;
      _loadError = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        _loadRequests();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _handleRequestAction({
    required bool approved,
    required Map<String, dynamic> request,
  }) async {
    if (_isUpdatingRequest) return;

    final title = _readString(request, const [
      'title',
      'memory_title',
      'name',
    ], 'Untitled request');

    setState(() => _isUpdatingRequest = true);
    final ok = await BackendData.updateMemoryRequestStatus(
      request: request,
      approved: approved,
    );

    if (!mounted) return;
    setState(() => _isUpdatingRequest = false);

    if (ok) {
      final message = approved
          ? 'Approved request: $title'
          : 'Rejected request: $title';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );

      setState(() {
        final targetStatus = approved ? 'approved' : 'rejected';
        for (int i = 0; i < _requests.length; i++) {
          final item = _requests[i];
          final itemId = item['id'] ?? item['request_id'];
          final requestId = request['id'] ?? request['request_id'];

          bool isMatch = false;
          if (itemId != null && requestId != null) {
            isMatch = itemId.toString() == requestId.toString();
          } else {
            final requestTitle = _readString(item, const [
              'title',
              'memory_title',
              'name',
            ], '');
            isMatch = requestTitle == title;
          }

          if (isMatch) {
            _requests[i] = Map<String, dynamic>.from(item)
              ..['status'] = targetStatus
              ..['request_status'] = targetStatus;
            break;
          }
        }
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to update request status on backend.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleDeleteRequest(Map<String, dynamic> request) async {
    if (_isDeletingRequest) return;

    final requestId = _readRequestId(request);
    final title = _readString(request, const [
      'title',
      'memory_title',
      'name',
    ], 'Untitled request');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Request'),
          content: Text('Delete request #$requestId ($title)?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    setState(() => _isDeletingRequest = true);
    final ok = await BackendData.deleteMemoryRequest(request: request);

    if (!mounted) return;
    setState(() => _isDeletingRequest = false);

    if (ok) {
      setState(() {
        _requests.removeWhere((item) {
          final itemId = item['id'] ?? item['request_id'];
          if (itemId == null) {
            return false;
          }
          return itemId.toString() == requestId;
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted request #$requestId'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to delete request on backend.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    final visibleRequests = _visibleRequests();
    final isCompact = MediaQuery.of(context).size.width < 700;

    if (user == null) {
      return Scaffold(
        appBar: AppbarPage(backArrow: true),
        endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
        body: Column(
          children: const [
            Expanded(
              child: Center(
                child: Text(
                  'Login required to access gallery request approvals.',
                ),
              ),
            ),
            MyFooter(),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppbarPage(backArrow: true),
      endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isCompact ? 14 : 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF183B63), Color(0xFF255B92)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gallery Request Review',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Review memory submissions, preview images, and update request status.',
                        style: TextStyle(color: Colors.white, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCountPill(
                            label: 'Pending',
                            count: _countByStatus('pending'),
                            color: const Color(0xFFFFD166),
                            icon: Icons.hourglass_top_rounded,
                          ),
                          _buildCountPill(
                            label: 'Approved',
                            count: _countByStatus('approved'),
                            color: const Color(0xFF7DFFB2),
                            icon: Icons.verified_rounded,
                          ),
                          _buildCountPill(
                            label: 'Rejected',
                            count: _countByStatus('rejected'),
                            color: const Color(0xFFFFA2A2),
                            icon: Icons.cancel_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: isCompact
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PopupMenuButton<String>(
                        initialValue: _selectedStatusSort,
                        constraints: const BoxConstraints(
                          minWidth: 180,
                          maxWidth: 180,
                        ),
                        onSelected: (value) {
                          setState(() {
                            _selectedStatusSort = value;
                          });
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'all',
                            child: Text('All requests'),
                          ),
                          PopupMenuItem(value: 'pending', child: Text('Pending')),
                          PopupMenuItem(value: 'approved', child: Text('Approved')),
                          PopupMenuItem(value: 'rejected', child: Text('Rejected')),
                        ],
                        child: _buildMenuTrigger(
                          icon: Icons.filter_list,
                          label:
                              'Status: ${_statusSortLabel(_selectedStatusSort)}',
                          width: 180,
                        ),
                      ),
                      PopupMenuButton<String>(
                        initialValue: _selectedDateSort,
                        constraints: const BoxConstraints(
                          minWidth: 180,
                          maxWidth: 180,
                        ),
                        onSelected: (value) {
                          setState(() {
                            _selectedDateSort = value;
                          });
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'newest', child: Text('Newest')),
                          PopupMenuItem(value: 'oldest', child: Text('Oldest')),
                        ],
                        child: _buildMenuTrigger(
                          icon: Icons.sort,
                          label: 'Date: ${_dateSortLabel(_selectedDateSort)}',
                          width: 180,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (_isLoadingRequests)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_loadError != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_loadError!),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _loadRequests,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (visibleRequests.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _selectedStatusSort == 'all'
                            ? 'No gallery requests right now.'
                            : 'No ${_statusSortLabel(_selectedStatusSort).toLowerCase()} requests right now.',
                      ),
                    ),
                  )
                else
                  ...visibleRequests.map((request) {
                    final title = _readString(request, const [
                      'title',
                      'memory_title',
                      'name',
                    ], 'Untitled request');
                    final player = _readString(request, const [
                      'player',
                      'display_name',
                      'author',
                      'username',
                    ], 'Unknown');
                    final requestId = _readRequestId(request);
                    final submittedRaw = _readString(request, const [
                      'created_at',
                      'submitted_at',
                      'date',
                    ], '-');
                    final takenRaw = _readString(request, const [
                      'time_taken',
                      'taken_date',
                      'date_taken',
                    ], '-');
                    final submitted = _formatDateTimeForCard(submittedRaw);
                    final taken = _formatDateForCard(takenRaw);
                    final status = _readRequestStatus(request);
                    final note = _readString(request, const [
                      'note',
                      'description',
                      'caption',
                    ], '');
                    final canTakeAction =
                        status == 'pending' && !_isUpdatingRequest;
                    final canDelete =
                        status != 'pending' && !_isDeletingRequest;

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                _buildStatusBadge(status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111B29),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF2F3E56)),
                              ),
                              child: DefaultTextStyle(
                                style: const TextStyle(
                                  color: Color(0xFFD9E6FA),
                                  fontSize: 15,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _buildMetaChip(
                                          icon: Icons.tag_rounded,
                                          label: 'ID',
                                          value: requestId,
                                        ),
                                        _buildMetaChip(
                                          icon: Icons.person_rounded,
                                          label: 'Player',
                                          value: player,
                                        ),
                                        _buildMetaChip(
                                          icon: Icons.event_rounded,
                                          label: 'Taken',
                                          value: taken,
                                        ),
                                        _buildMetaChip(
                                          icon: Icons.schedule_rounded,
                                          label: 'Submitted',
                                          value: submitted,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildRequestPreview(request),
                            if (note.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111B29),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF2F3E56),
                                  ),
                                ),
                                child: Text(
                                  note,
                                  style: const TextStyle(
                                    color: Color(0xFFD9E6FA),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            if (canTakeAction)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _handleRequestAction(
                                        approved: true,
                                        request: request,
                                      ),
                                      icon: const Icon(Icons.check),
                                      label: Text(
                                        _isUpdatingRequest
                                            ? 'Working...'
                                            : 'Approve',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1B8A5A),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _handleRequestAction(
                                        approved: false,
                                        request: request,
                                      ),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Reject'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1D2A3A),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF3A4A63),
                                      ),
                                    ),
                                    child: Text(
                                      'Reviewed: ${_statusLabel(status)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFDCE7F7),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  OutlinedButton.icon(
                                    onPressed: canDelete
                                        ? () => _handleDeleteRequest(request)
                                        : null,
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: canDelete
                                          ? Colors.red.shade300
                                          : Colors.grey,
                                    ),
                                    label: Text(
                                      _isDeletingRequest
                                          ? 'Deleting...'
                                          : 'Delete',
                                      style: TextStyle(
                                        color: canDelete
                                            ? Colors.red.shade300
                                            : Colors.grey,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: canDelete
                                            ? Colors.red.shade300
                                            : Colors.grey,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
          const MyFooter(),
        ],
      ),
    );
  }
}
