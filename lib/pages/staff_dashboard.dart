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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Staff Dashboard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 100,
          child: GridView.count(
            crossAxisCount: 7,
            children: [
              Container(color: Colors.red, child: Text('hello1')),
              Container(color: Colors.red, child: Text('hello2')),
              Container(color: Colors.red, child: Text('hello3')),
            ],
          ),
        ),
      ],
    );
  }
}