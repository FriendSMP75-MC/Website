import 'package:flutter/material.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Staff Dashboard")),
      body: Column(
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Staff Dashboard',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // GridView fills remaining space
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16, // ✅ smaller spacing so items fit
              mainAxisSpacing: 16,
              padding: const EdgeInsets.all(8),
              children: [
                Container(
                  color: Colors.grey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // ✅ center content
                    children: [
                      const Text(
                        'Announcement',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('hi'),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.green,
                  child: const Center(child: Text('Gallery')),
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
      ),
    );
  }
}