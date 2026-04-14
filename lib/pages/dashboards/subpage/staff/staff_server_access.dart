import 'dart:async';
import 'package:flutter/material.dart';
import 'package:server_site/data/backend_config.dart';
import 'package:server_site/data/supabase_config.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: disabled
            ? const []
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: FilledButton.icon(
        onPressed: disabled ? null : onPress,
        icon: Icon(icon, size: 20),
        label: Text(action, style: const TextStyle(fontSize: 15)),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withAlpha(80),
          disabledForegroundColor: Colors.white38,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
            Text('Sending $action command...'),
          ],
        ),
        backgroundColor: const Color(0xFF1E7AA7),
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
        return const Color(0xFF30C88B);
      case 'offline':
        return const Color(0xFFFF6A6A);
      default:
        return Colors.white54;
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
    final bool isMobile = MediaQuery.sizeOf(context).width < 760;

    if (user == null) {
      return Scaffold(
        appBar: AppbarPage(backArrow: true),
        endDrawer: NavDrawer(currentPage: 'Dashboard', parentContext: context),
        body: const Column(
          children: [
            Expanded(
              child: Center(
                child: Text('Login required to access server controls.'),
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
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 20,
                  16,
                  isMobile ? 12 : 20,
                  0,
                ),
                child: Column(
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
                            'Server Control Center',
                            style: TextStyle(
                              fontSize: isMobile ? 30 : 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome, $username',
                            style: TextStyle(color: Colors.blueGrey[100]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _statusColor.withAlpha(120)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Current Server Status',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              letterSpacing: 0.6,
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
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _statusColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Power Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        PowerAction(
                          action: 'Start',
                          icon: Icons.play_arrow_rounded,
                          color: const Color(0xFF30C88B),
                          disabled: _cooldown,
                          onPress: () => _handlePress('start', context),
                        ),
                        PowerAction(
                          action: 'Restart',
                          icon: Icons.refresh_rounded,
                          color: const Color(0xFFFFB347),
                          disabled: _cooldown,
                          onPress: () => _handlePress('restart', context),
                        ),
                        PowerAction(
                          action: 'Stop',
                          icon: Icons.stop_circle_rounded,
                          color: const Color(0xFFFF6A6A),
                          disabled: _cooldown,
                          onPress: () => _handlePress('stop', context),
                        ),
                      ],
                    ),
                    if (_cooldown) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Buttons locked for 5 seconds...',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
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
}
