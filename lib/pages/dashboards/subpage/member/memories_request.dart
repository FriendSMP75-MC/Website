import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:server_site/data/supabase_config.dart';
import 'dart:async';

SupabaseClient get supabase => Supabase.instance.client;

class MemoriesRequest extends StatefulWidget {
  const MemoriesRequest({super.key});

  @override
  State<MemoriesRequest> createState() => _MemoriesRequestState();
}

class _MemoriesRequestState extends State<MemoriesRequest> {
  StreamSubscription<AuthState>? _authSub;
  DateTime? _memoryTakenDate;
  PlatformFile? _pickedFile;
  final TextEditingController _memoryTitleController = TextEditingController();
  bool _isSubmitting = false;
  double _uploadProgress = 0.0;
  bool _isLoadingMyRequests = false;
  String? _requestsError;
  List<Map<String, dynamic>> _myRequests = [];

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

    final localDateTime = parsed.toLocal();
    return DateFormat('hh:mm a, dd MMMM yyyy').format(localDateTime);
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
    final rawId = _readString(
      request,
      const ['id', 'request_id', 'memory_id'],
      '-',
    );
    return rawId;
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
      return const Icon(Icons.photo_library_outlined);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 56,
            height: 56,
            color: const Color(0xFFE0E0E0),
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined, size: 20),
          );
        },
      ),
    );
  }

  Future<void> _loadMyMemoryRequests() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isLoadingMyRequests = false;
        _requestsError = null;
        _myRequests = [];
      });
      return;
    }

    final memberUuid = SupabaseConfig.getSupabaseUUID(user).toString();
    setState(() {
      _isLoadingMyRequests = true;
      _requestsError = null;
    });

    final result = await BackendData.getMemberMemoryRequests(
      memberUuid: memberUuid,
    );

    if (!mounted) return;
    if (result == null) {
      setState(() {
        _isLoadingMyRequests = false;
        _requestsError = 'Failed to load your memory requests.';
      });
      return;
    }

    setState(() {
      _isLoadingMyRequests = false;
      _requestsError = null;
      _myRequests = result;
    });
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && mounted) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  void _handleTitleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickMemoryTakenDate(BuildContext context) async {
    final DateTime? takenDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _memoryTakenDate ?? DateTime.now(),
    );

    if (takenDate != null && takenDate != _memoryTakenDate) {
      setState(() {
        _memoryTakenDate = takenDate;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _submitMemoryRequest() async {
    final user = SupabaseConfig.client.auth.currentUser;
    final normalizedTitle = _memoryTitleController.text.trim();

    if (user == null) {
      _showSnackBar('Please login first.', Colors.red);
      return;
    }
    if (_pickedFile == null || _pickedFile!.bytes == null) {
      _showSnackBar('Please select an image first!', Colors.purpleAccent);
      return;
    }
    if (_memoryTakenDate == null) {
      _showSnackBar(
        'Please select the date the image was taken!',
        Colors.purpleAccent,
      );
      return;
    }
    if (normalizedTitle.isEmpty) {
      _showSnackBar('Please enter a memory title!', Colors.purpleAccent);
      return;
    }

    setState(() => _isSubmitting = true);
    setState(() => _uploadProgress = 0.0);

    final result = await BackendData.addMemoryRequest(
      imageBytes: _pickedFile!.bytes!,
      filename: _pickedFile!.name,
      uuid: SupabaseConfig.getSupabaseUUID(user).toString(),
      displayName: SupabaseConfig.getDisplayName(user),
      timeTaken: _memoryTakenDate!.toIso8601String(),
      title: normalizedTitle,
      onProgress: (progress) {
        if (!mounted) return;
        setState(() => _uploadProgress = progress.clamp(0.0, 1.0));
      },
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result != null) {
      _showSnackBar('Memory request sent successfully!', Colors.green);
      setState(() {
        _pickedFile = null;
        _memoryTakenDate = null;
        _memoryTitleController.clear();
        _uploadProgress = 0.0;
      });
      await _loadMyMemoryRequests();
    } else {
      setState(() => _uploadProgress = 0.0);
      _showSnackBar('Failed to send memory request.', Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    _memoryTitleController.addListener(_handleTitleChanged);
    _loadMyMemoryRequests();
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        _loadMyMemoryRequests();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _memoryTitleController.removeListener(_handleTitleChanged);
    _memoryTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    final username = SupabaseConfig.getUserName(user);

    return Scaffold(
      appBar: AppbarPage(customTitle: 'Memories Request', backArrow: true),
      endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
      body: SingleChildScrollView(
        child: user == null
            ? _buildAuthRequired()
            : _buildRequestScreen(username),
      ),
    );
  }

  Widget _buildAuthRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Authentication Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please log in with Discord to create and upload a memory request.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await SupabaseConfig.loginWithDiscord();
                },
                icon: const Icon(Icons.login),
                label: const Text('Login with Discord'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestScreen(String username) {
    final user = SupabaseConfig.client.auth.currentUser;

    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                children: [
                  _buildHeroCard(username),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Manage Memory Request',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blueAccent),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            'Provide one good image to display after acceptance',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  const Text('Date of the memory image taken'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          border: Border.all(color: Colors.red),
                        ),
                        width: MediaQuery.of(context).size.width > 600
                            ? 400
                            : double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            children: [
                              Text(
                                _memoryTakenDate == null
                                    ? 'No date selected!'
                                    : DateFormat(
                                        'dd-MM-yyyy',
                                      ).format(_memoryTakenDate!),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _pickMemoryTakenDate(context),
                                icon: const Icon(Icons.date_range),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blueAccent),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text('Memory title'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width > 600
                          ? 400
                          : double.infinity,
                      child: TextField(
                        controller: _memoryTitleController,
                        decoration: const InputDecoration(
                          label: Text('Enter memory title'),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _pickImage,
                    label: const Text('Click to upload image'),
                    icon: const Icon(Icons.upload_file),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    'Preview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blueAccent),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            'This preview shows how it will look after acceptance',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width > 800
                          ? 600
                          : MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: Column(
                      children: [
                        (_pickedFile != null && _pickedFile!.bytes != null)
                            ? Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: Image.memory(
                                      _pickedFile!.bytes!,
                                      width: double.infinity,
                                      height: 400,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(130, 195, 17, 17),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 10,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _infoItem(
                                            'Uploaded by',
                                            SupabaseConfig.getDisplayName(user),
                                          ),
                                          _infoItem(
                                            'Taken on',
                                            _memoryTakenDate == null
                                                ? 'No date!'
                                                : DateFormat(
                                                    'dd-MM-yyyy',
                                                  ).format(_memoryTakenDate!),
                                          ),
                                          _infoItem('Uploaded on', 'Today'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () =>
                                        setState(() => _pickedFile = null),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Clear selection',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Select image to view Preview!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _isSubmitting
                      ? SizedBox(
                          width: 260,
                          child: Column(
                            children: [
                              LinearProgressIndicator(value: _uploadProgress),
                              const SizedBox(height: 8),
                              Text(
                                'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitMemoryRequest,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(220, 50),
                          ),
                          child: const Text('Send Memory Request'),
                        ),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your submissions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingMyRequests)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_requestsError != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(child: Text(_requestsError!)),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _loadMyMemoryRequests,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_myRequests.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: const [
                            Icon(Icons.inbox_outlined),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('No memory requests submitted yet.'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _myRequests.map((request) {
                        final title = _readString(request, const [
                          'title',
                          'memory_title',
                          'name',
                        ], 'Untitled request');
                        final submittedAtRaw = _readString(request, const [
                          'created_at',
                          'submitted_at',
                          'date',
                        ], '-');
                        final takenDateRaw = _readString(request, const [
                          'time_taken',
                          'taken_date',
                          'date_taken',
                        ], '-');
                        final requestId = _readRequestId(request);
                        final submittedAt = _formatDateTimeForCard(
                          submittedAtRaw,
                        );
                        final takenDate = _formatDateForCard(takenDateRaw);
                        final status = _readString(request, const [
                          'status',
                          'request_status',
                        ], 'pending');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: _buildRequestPreview(request),
                            title: Text(title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('ID: $requestId'),
                                Text('Taken: $takenDate'),
                                Text('Submitted: $submittedAt'),
                                Text('Status: $status'),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
        const MyFooter(),
      ],
    );
  }

  Widget _buildHeroCard(String username) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF198A8E), Color(0xFF125E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Wrap(
        runSpacing: 18,
        spacing: 18,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(36),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          SizedBox(
            width: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $username',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Send a gallery memory request with a clear title and image. Staff can review it and add it to the website gallery.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
