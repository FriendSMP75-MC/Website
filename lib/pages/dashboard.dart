import 'package:flutter/material.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/nav_drawer.dart';
import 'dart:async';

SupabaseClient get supabase => Supabase.instance.client;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  StreamSubscription<AuthState>? _authSub;
  bool? _isOwner;

  @override
  void initState() {
    super.initState();
    // Subscribe to auth state changes and refresh owner flag
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
      if (mounted) _loadOwner();
    });
    _loadOwner();
  }

  Future<void> _loadOwner() async {
    final ownerId = await BackendData.getOwnerAuthID();
    final user = SupabaseConfig.client.auth.currentUser;
    final currentUuid = SupabaseConfig.getSupabaseUUID(user);
    if (!mounted) return;
    setState(() {
      _isOwner = (ownerId != null && ownerId == currentUuid);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  /// Key for TextFormField (UUID) and controller
  final _uuidKey = GlobalKey<FormState>();
  final TextEditingController _uuidController = TextEditingController();

  // Key and Controller for TextFormField (nickName)
  final _nickNameKey = GlobalKey<FormState>();
  final TextEditingController _nickNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    final username = SupabaseConfig.getUserName(user);
    final authUUID = SupabaseConfig.getSupabaseUUID(user);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Image.network(
                  'https://i.ibb.co/4nkHpYDw/servercurrent.jpg',
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
              const Flexible(
                child: Text('FriendSMP75', overflow: TextOverflow.visible),
              ),
            ],
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(
            width: double.infinity,
            child: Divider(height: 1, thickness: 1, color: Colors.grey),
          ),
        ),
      ),

      endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Welcome $username',
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SelectableText(
                      'UUID ID: $authUUID',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),

            /// Owner-only add users by auth id
            Builder(
              builder: (context) {
                if (_isOwner == null) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (_isOwner == true) {
                  return Column(
                    children: [

                      // UUID TextField
                      Row(
                        children: [
                          Form(
                            key: _uuidKey,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                          
                              child: TextFormField(
                                controller: _uuidController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter UUID',
                                  hintText: "Enter provided UUID",
                                ),

                                //No empty text field and no wrong uuid
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter UUID';
                                  }
                                  if (value.length < 35) {
                                    return 'Enter valid UUID';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),

                          // NickName TextField
                          Form(
                            key: _nickNameKey,
                            child: Padding(
                            padding: EdgeInsetsGeometry.all(8.0),
                            child: TextFormField(
                              controller: _nickNameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "NickName",
                                hintText: "Enter Nickname of the staff member",
                              ),
                              
                              // No empty field
                              validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Nickname';
                                  }
                                  return null;
                                },
                            ),
                            ),
                          ),

                        ],
                      ),

                      // Validate data on button press
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_uuidKey.currentState!.validate() && _nickNameKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Adding user to the list'),
                              ),
                            );
                            _uuidController.clear();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
