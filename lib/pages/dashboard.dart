import 'package:flutter/material.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/pages/dashboards/staff_dashboard.dart';
import 'package:server_site/pages/dashboards/member_dashboard.dart';
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
  bool _showMemberViewForStaff = false;

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
    return staffList.any((listUser) => listUser['staff_uid'] == uuid);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _uuidController.dispose();
    _nickNameController.dispose();
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
    final bool isMobile = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
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
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 20,
                  18,
                  isMobile ? 12 : 20,
                  0,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A3656), Color(0xFF16506F)],
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome $username',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SelectableText(
                                  'UUID: $authUUID',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Text(
                                'Welcome $username',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              SelectableText(
                                'UUID: $authUUID',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DashboardStatChip(
                          icon: Icons.admin_panel_settings_rounded,
                          label: 'Role',
                          value: _isOwner == true ? 'Owner' : 'Member',
                        ),
                        _DashboardStatChip(
                          icon: Icons.groups_rounded,
                          label: 'Staff Count',
                          value: '${users.length}',
                        ),
                      ],
                    ),

                    /// Owner-only add users by auth id
                    Builder(
                      builder: (context) {
                        if (_isOwner == null) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (_isOwner == true) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 14),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(8, 6, 8, 2),
                                    child: Text(
                                      'Owner Controls',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                    child: Text(
                                      'Add or remove staff UUID access records.',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ),
                                // UUID TextField
                                Form(
                                  key: _uuidKey,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),

                                    child: TextFormField(
                                      controller: _uuidController,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: 'Enter UUID',
                                        hintText: 'Enter provided UUID',
                                        filled: true,
                                        fillColor: Colors.black.withValues(
                                          alpha: 0.18,
                                        ),
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _nickNameController,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: 'NickName',
                                        hintText:
                                            'Enter nickname of the staff member',
                                        filled: true,
                                        fillColor: Colors.black.withValues(
                                          alpha: 0.18,
                                        ),
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
                                FilledButton.icon(
                                  onPressed: () async {
                                    if (_uuidKey.currentState!.validate() &&
                                        _nickNameKey.currentState!.validate()) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(Icons.info),
                                              SizedBox(width: 8),
                                              Text(
                                                'Data sent to backend!',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: const Color(
                                            0xFF1E7AA7,
                                          ),
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
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E7AA7),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add'),
                                ),

                                // List Added uuid users
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              height: 220,

                                              //listing added uuid
                                              child: ListView.builder(
                                                itemCount: users.length,
                                                itemBuilder: (context, index) {
                                                  final user = users[index];

                                                  return ListTile(
                                                    leading: const Icon(
                                                      Icons.person,
                                                    ),
                                                    title: Text(
                                                      user['staff_display_name'] ??
                                                          'Unknown',
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
                                                          if (!context
                                                              .mounted) {
                                                            return;
                                                          }

                                                          //show deleted snack bar
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Icon(
                                                                    Icons.info,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Text(
                                                                    'Staff UUID deleted successfully!',
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              backgroundColor:
                                                                  const Color(
                                                                    0xFF1E7AA7,
                                                                  ),
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                            ),
                                                          );
                                                          //fetch updated staff list
                                                          _fetchStaffUUID();
                                                        } catch (e) {
                                                          if (!context
                                                              .mounted) {
                                                            return;
                                                          }

                                                          //show snackbar if found any error
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.error,
                                                                    color: Colors
                                                                        .red,
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

                                                      icon: Icon(
                                                        Icons.delete_forever,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                      const Divider(thickness: 2),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // staff only - Main dashboard
                    FutureBuilder<bool>(
                      future: isStaff(authUUID),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        if (snapshot.data == true) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _DashboardTab(
                                        selected: !_showMemberViewForStaff,
                                        label: 'Staff Dashboard',
                                        onTap: () {
                                          setState(() {
                                            _showMemberViewForStaff = false;
                                          });
                                        },
                                      ),
                                      _DashboardTab(
                                        selected: _showMemberViewForStaff,
                                        label: 'Member Dashboard',
                                        onTap: () {
                                          setState(() {
                                            _showMemberViewForStaff = true;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _showMemberViewForStaff
                                  ? const MemberDashboard()
                                  : const StaffDashboard(),
                            ],
                          );
                        }
                        return const MemberDashboard();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _DashboardTab({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: selected
            ? const LinearGradient(
                colors: [Color(0xFF2783C0), Color(0xFF2D9FD1)],
              )
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
}

class _DashboardStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DashboardStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
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
