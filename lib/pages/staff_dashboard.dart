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
            style: TextStyle(fontSize: 20),
          ),
        ),

        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 50,
            mainAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            children: [
              Container(
                color: Colors.red,
                child: Center(child: Text('hello1 a')),
              ),
              Container(
                color: Colors.green,
                child: Center(child: Text('hello2')),
              ),
              Container(
                color: Colors.blue,
                child: Center(child: Text('hello3')),
              ),
              Container(
                color: Colors.orange,
                child: Center(child: Text('Reports')),
              ),
              Container(
                color: Colors.purple,
                child: Center(child: Text('Settings')),
              ),
              Container(
                color: Colors.teal,
                child: Center(child: Text('Logout')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
