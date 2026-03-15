import 'dart:async';
import 'package:flutter/material.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/nav_drawer.dart';

class StaffServerAccess extends StatefulWidget {
  const StaffServerAccess({super.key});

  @override
  State<StaffServerAccess> createState() => _StaffServerAccessState();
}

class PowerAction extends StatelessWidget {
  final String action;
  final IconData icon;
  final Color color;
  final bool disabled;
  final VoidCallback onPress;
  const PowerAction({
    super.key,
    required this.action,
    required this.icon,
    required this.color,
    required this.disabled,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: disabled ? null : onPress,
      label: Text(action, style: const TextStyle(fontSize: 15)),
      icon: Icon(icon, size: 22),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withAlpha(80),
        disabledForegroundColor: Colors.white38,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: disabled ? 0 : 4,
      ),
    );
  }
}

class _StaffServerAccessState extends State<StaffServerAccess> {
  bool _cooldown = false;
  Timer? _cooldownTimer;
  Timer? _statusPollTimer;
  String _serverStatus = 'loading...';

  @override
  void initState() {
    super.initState();
    _refreshServerStatus();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshServerStatus();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _statusPollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshServerStatus() async {
    final result = await BackendData.serverStatus();
    final status = (result?['status'] as String?) ?? 'unknown';
    if (!mounted) return;
    setState(() => _serverStatus = status);
  }

  Future<void> _handlePress(String action, BuildContext context) async {
    if (_cooldown) return;
    setState(() => _cooldown = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Sending $action command...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.purpleAccent[100],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
    await BackendData.powerAction(action);
    await _refreshServerStatus();
    _cooldownTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _cooldown = false);
    });
  }

  Color get _statusColor {
    switch (_serverStatus) {
      case 'online':
        return Colors.greenAccent;
      case 'offline':
        return Colors.redAccent;
      default:
        return Colors.white38;
    }
  }

  IconData get _statusIcon {
    switch (_serverStatus) {
      case 'online':
        return Icons.check_circle_rounded;
      case 'offline':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    final username = SupabaseConfig.getUserName(user);

    if (user == null) {
      return Scaffold(
        appBar: AppbarPage(backArrow: true),
        endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
        body: const Column(children: [Text('Not Loggined in')]),
      );
    }

    return Scaffold(
      appBar: AppbarPage(),
      endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Welcome, $username',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),

            // Status Card
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _statusColor.withAlpha(80)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Server Status',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_statusIcon, color: _statusColor, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        _serverStatus,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Power Actions',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 14),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                PowerAction(
                  action: 'start',
                  icon: Icons.play_arrow_rounded,
                  color: Colors.green,
                  disabled: _cooldown,
                  onPress: () => _handlePress('start', context),
                ),
                PowerAction(
                  action: 'restart',
                  icon: Icons.refresh_outlined,
                  color: Colors.amber,
                  disabled: _cooldown,
                  onPress: () => _handlePress('restart', context),
                ),
                PowerAction(
                  action: 'stop',
                  icon: Icons.stop_circle_rounded,
                  color: Colors.red,
                  disabled: _cooldown,
                  onPress: () => _handlePress('stop', context),
                ),
              ],
            ),

            if (_cooldown) ...[
              const SizedBox(height: 16),
              const Text(
                'Buttons locked for 5 seconds...',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

