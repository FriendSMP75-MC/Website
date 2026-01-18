import 'package:flutter/material.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Staff Dashboard', style: TextStyle(fontSize: 20)),
        ),

        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            padding: const EdgeInsets.all(8),
            children: [
              Container(
                color: Colors.red,
                child: const Center(child: Text('hello1')),
              ),
              Container(
                color: Colors.green,
                child: const Center(child: Text('hello2')),
              ),
              Container(
                color: Colors.blue,
                child: const Center(child: Text('hello3')),
              ),
              Container(
                color: Colors.orange,
                child: const Center(child: Text('Reports')),
              ),
              Container(
                color: Colors.purple,
                child: const Center(child: Text('Settings')),
              ),
              Container(
                color: Colors.teal,
                child: const Center(child: Text('Logout')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
