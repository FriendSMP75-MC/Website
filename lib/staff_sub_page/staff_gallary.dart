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

  // Controller for the filename text field
  final TextEditingController _fileNameController = TextEditingController();

  // Loading state to show a spinner during upload
  bool _isLoading = false;

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

  // Upload Logic
  Future<void> _handleUpload() async {
    // 1. Validations
    if (pickedFile == null || pickedFile!.bytes == null) {
      _showSnackBar("Please select an image first!", Colors.purpleAccent);
      return;
    }
    if (_fileNameController.text.trim().isEmpty) {
      _showSnackBar("Please provide a filename!", Colors.purpleAccent);
      return;
    }
    if (imageTakenDate == null) {
      _showSnackBar(
        "Please select the date the image was taken!",
        Colors.purpleAccent,
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Call Backend
    final result = await BackendData.uploadImage(
      filename: _fileNameController.text.trim(),
      imageBytes: pickedFile!.bytes!,
      takenDate: imageTakenDate!.toIso8601String(),
    );

    setState(() => _isLoading = false);

    // 3. Handle Result
    if (result != null) {
      _showSnackBar("Image successfully added to gallery!", Colors.green);
      setState(() {
        pickedFile = null;
        imageTakenDate = null;
        _fileNameController.clear();
      });
    } else {
      _showSnackBar("Upload failed. Please check backend logs.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(backArrow: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Center(
                child: Text(
                  'Manage Gallary images',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      'Provide one good image to display it in gallary page',
                    ),
                  ),
                ],
              ),
            ),
            Divider(),

            Text('Date of the Uploading image taken'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
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
                          imageTakenDate == null
                              ? "No date selected!"
                              : DateFormat(
                                  'dd-MM-yyyy',
                                ).format(imageTakenDate!),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () => _imageTakenDate(context),
                          icon: Icon(Icons.date_range),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.blueAccent),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'File name [The uploaded image will be saved in this name]',
                  ),
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
                  controller: _fileNameController,
                  decoration: InputDecoration(
                    label: Text('Filename'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                );

                if (result != null) {
                  setState(() {
                    pickedFile = result.files.first;
                    // Auto-fill filename if empty
                    if (_fileNameController.text.isEmpty) {
                      _fileNameController.text = pickedFile!.name;
                    }
                  });
                }
              },
              label: Text('Click to upload image'),
              icon: Icon(Icons.upload_file),
            ),

            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 20),

            Text(
              'Preview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  (pickedFile != null && pickedFile!.bytes != null)
                      ? Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.memory(
                                pickedFile!.bytes!,
                                width: double.infinity,
                                height: 400,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(130, 195, 17, 17),
                                borderRadius: const BorderRadius.only(
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
                                      SupabaseConfig.getDisplayName(
                                        BackendData.user,
                                      ),
                                    ),
                                    _infoItem(
                                      'Taken on',
                                      imageTakenDate == null
                                          ? "No date!"
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
                              icon: const Icon(Icons.delete, color: Colors.red),
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
                            border: Border.all(color: Colors.grey.shade300),
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

            // Final Upload Button with Loading Logic
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleUpload,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                    ),
                    child: Text('Add Image to Gallery!'),
                  ),

            const SizedBox(height: 50),
            MyFooter(),
          ],
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
