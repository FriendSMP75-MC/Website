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
        // Optional: Title or header
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Staff Dashboard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // ✅ Wrap GridView in a SizedBox or Expanded
        SizedBox(
          height: 400, // Adjust height as needed
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3,
            padding: const EdgeInsets.all(8),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: List.generate(5, (index) {
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}