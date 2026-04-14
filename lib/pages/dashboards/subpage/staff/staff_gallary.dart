import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';

class StaffGallary extends StatefulWidget {
  const StaffGallary({super.key});

  @override
  State<StaffGallary> createState() => _StaffGallaryState();
}

class _StaffGallaryState extends State<StaffGallary> {
  DateTime? imageTakenDate;
  PlatformFile? pickedFile;

  final TextEditingController _fileNameController = TextEditingController();

  bool _isLoading = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _imageTakenDate(BuildContext context) async {
    final DateTime? takenDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (takenDate != null && takenDate != imageTakenDate) {
      setState(() {
        imageTakenDate = takenDate;
      });
    }
  }

  Future<void> _handleUpload() async {
    if (pickedFile == null || pickedFile!.bytes == null) {
      _showSnackBar('Please select an image first!', Colors.purpleAccent);
      return;
    }
    if (_fileNameController.text.trim().isEmpty) {
      _showSnackBar('Please provide a filename!', Colors.purpleAccent);
      return;
    }
    if (imageTakenDate == null) {
      _showSnackBar(
        'Please select the date the image was taken!',
        Colors.purpleAccent,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0.0;
    });

    final result = await BackendData.uploadImage(
      filename: _fileNameController.text.trim(),
      imageBytes: pickedFile!.bytes!,
      takenDate: imageTakenDate!.toIso8601String(),
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _uploadProgress = progress.clamp(0.0, 1.0);
        });
      },
    );

    setState(() {
      _isLoading = false;
      _uploadProgress = 0.0;
    });

    if (result != null) {
      _showSnackBar('Image successfully added to gallery!', Colors.green);
      setState(() {
        pickedFile = null;
        imageTakenDate = null;
        _fileNameController.clear();
      });
    } else {
      _showSnackBar('Upload failed. Please check backend logs.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 760;

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
                            'Gallery Upload Manager',
                            style: TextStyle(
                              fontSize: isMobile ? 30 : 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload high-quality community photos with complete metadata.',
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
                        children: [
                          _InputCard(
                            icon: Icons.event_available_rounded,
                            title: 'Date when image was taken',
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    imageTakenDate == null
                                        ? 'No date selected'
                                        : DateFormat(
                                            'dd-MM-yyyy',
                                          ).format(imageTakenDate!),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _imageTakenDate(context),
                                  icon: const Icon(Icons.date_range_rounded),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _InputCard(
                            icon: Icons.edit_note_rounded,
                            title: 'Filename',
                            child: TextField(
                              controller: _fileNameController,
                              decoration: InputDecoration(
                                labelText: 'Image filename',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.black.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1E7AA7),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.image,
                                      allowMultiple: false,
                                    );

                                if (result != null) {
                                  setState(() {
                                    pickedFile = result.files.first;
                                    if (_fileNameController.text.isEmpty) {
                                      _fileNameController.text =
                                          pickedFile!.name;
                                    }
                                  });
                                }
                              },
                              icon: const Icon(Icons.upload_file_rounded),
                              label: const Text('Select Image'),
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
                            'Preview',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (pickedFile != null && pickedFile!.bytes != null)
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Image.memory(
                                    pickedFile!.bytes!,
                                    width: double.infinity,
                                    height: isMobile ? 250 : 400,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _infoItem(
                                          'Uploaded by',
                                          SupabaseConfig.getDisplayName(
                                            BackendData.user,
                                          ),
                                        ),
                                        _infoItem(
                                          'Taken on',
                                          imageTakenDate == null
                                              ? 'No date'
                                              : DateFormat(
                                                  'dd-MM-yyyy',
                                                ).format(imageTakenDate!),
                                        ),
                                        _infoItem('Uploaded on', 'Today'),
                                      ],
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      setState(() => pickedFile = null),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  label: const Text(
                                    'Clear selection',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            )
                          else
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Select image to view preview',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_isLoading)
                      SizedBox(
                        width: 280,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(value: _uploadProgress),
                            const SizedBox(height: 8),
                            Text(
                              'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                            ),
                          ],
                        ),
                      )
                    else
                      FilledButton.icon(
                        onPressed: _handleUpload,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1E7AA7),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(240, 50),
                        ),
                        icon: const Icon(Icons.cloud_upload_rounded),
                        label: const Text('Add Image To Gallery'),
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

  Widget _infoItem(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _InputCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF66D3F2)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
