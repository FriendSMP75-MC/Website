import 'package:flutter/material.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/pages/staff_dashboard.dart';
import 'package:server_site/widgets/appbar.dart';
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
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    // Subscribe to auth state changes and refresh owner flag
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
      if (mounted) _loadOwner();
    });
    _loadOwner();
    _fetchStaffUUID();
  }

  // Get owner's uuid
  Future<void> _loadOwner() async {
    final ownerId = await BackendData.getOwnerAuthID();
    final user = SupabaseConfig.client.auth.currentUser;
    final currentUuid = SupabaseConfig.getSupabaseUUID(user);
    if (!mounted) return;
    setState(() {
      _isOwner = (ownerId != null && ownerId == currentUuid);
    });
  }

  // Get staff uuid
  Future<void> _fetchStaffUUID() async {
    final result = await BackendData.getUUID();
    if (result != null) {
      setState(() {
        users = result;
      });
    }
  }

  // Check staff list
  Future<bool> isStaff(String uuid) async {
    final staffList = users;
    return staffList.any((listUser) => listUser['staff_uid']==uuid);
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
      appBar: AppbarPage(),

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
                              if (value.length != 36) {
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

                      // Validate data on button press
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_uuidKey.currentState!.validate() &&
                              _nickNameKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.info),
                                    SizedBox(width: 8),
                                    Text(
                                      'Data sent to backend!',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.purpleAccent[100],
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            // send data to backend
                            await BackendData.sendUUID(
                              _uuidController.text.trim(),
                              _nickNameController.text.trim(),
                            );

                            //clear text of the text box
                            _uuidController.clear();
                            _nickNameController.clear();

                            // fetch updated staff list
                            await _fetchStaffUUID();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),

                      // List Added uuid users
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Staff UUIDs:",
                              style: TextStyle(fontSize: 18),
                            ),
                            users.isEmpty
                                ? const Text(
                                    "No staff added yet.",
                                  ) // if no UUID is added
                                : SizedBox(
                                    height: 100,

                                    //listing added uuid
                                    child: ListView.builder(
                                      itemCount: users.length,
                                      itemBuilder: (context, index) {
                                        final user = users[index];

                                        return ListTile(
                                          leading: const Icon(Icons.person),
                                          title: Text(
                                            user['staff_display_name'] ??
                                                '${Icon(Icons.warning)} Unknown',
                                          ),
                                          subtitle: Text(
                                            user['staff_uid'] ??
                                                'No uuid found? strange',
                                          ),
                                          trailing: IconButton(
                                            onPressed: () async {
                                              try {
                                                // delete staff uuid
                                                await BackendData.deleteUUID(
                                                  user['staff_uid'],
                                                );
                                                if (!context.mounted) return;

                                                //show deleted snack bar
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(Icons.info),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'Staff UUID deleted successfully!',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    backgroundColor: Colors
                                                        .purpleAccent[100],
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                                //fetch updated staff list
                                                _fetchStaffUUID();
                                              } catch (e) {

                                                if (!context.mounted) return;

                                                //show snackbar if found any error
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.error,
                                                          color: Colors.red,
                                                        ),
                                                        Text(
                                                          'Found error when deleting staff uuid!: $e',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                            },

                                            icon: Icon(Icons.delete_forever),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                            Divider(thickness: 3),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // staff only - Main dashboard
            FutureBuilder<bool>(
              future: isStaff(authUUID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                if (snapshot.data == true) {
                  return Expanded(child: StaffDashboard());
                }
                return Text('Hello there! \n unfortunately you don\'t have access to this page :(');
              },
            ),
          ],
        ),
      ),
    );
  }
}
