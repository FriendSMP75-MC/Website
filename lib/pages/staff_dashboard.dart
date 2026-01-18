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
          child: Text(
            'Staff Dashboard',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            padding: const EdgeInsets.all(8),
            children: [
              // Example with multiple elements
              Container(
                color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('hello1', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Click Me'),
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.star, color: Colors.white, size: 30),
                  ],
                ),
              ),
              Container(
                color: Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('hello2'),
                    SizedBox(height: 8),
                    Icon(Icons.photo, color: Colors.white),
                  ],
                ),
              ),
              Container(
                color: Colors.blue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('hello3'),
                    SizedBox(height: 8),
                    Icon(Icons.info, color: Colors.white),
                  ],
                ),
              ),
              Container(
                color: Colors.orange,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Reports'),
                    SizedBox(height: 8),
                    Icon(Icons.bar_chart, color: Colors.white),
                  ],
                ),
              ),
              Container(
                color: Colors.purple,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Settings'),
                    SizedBox(height: 8),
                    Icon(Icons.settings, color: Colors.white),
                  ],
                ),
              ),
              Container(
                color: Colors.teal,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Logout'),
                    SizedBox(height: 8),
                    Icon(Icons.logout, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}