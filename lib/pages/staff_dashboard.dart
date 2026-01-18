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
            child: Text('Staff Dashboard', style: TextStyle(fontSize: 20)),
          ),

          // Expanded instead of SizedBox with infinity
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 50,
              mainAxisSpacing: 8,
              padding: const EdgeInsets.all(8),
              children: [
                Container(
                  color: Colors.grey,
                  child: Column(
                    children: [
                      const Center(
                        child: Text('Announcements', style: TextStyle(fontSize: 15)),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Click the below button to make announcement'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text('To announcement', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.grey,
                  child: Column(
                    children: [
                      const Center(
                        child: Text('Gallery', style: TextStyle(fontSize: 15)),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Click the below button to add an image to Gallery'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text('To Gallery', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.grey,
                  child: Column(
                    children: [
                      const Center(
                        child: Text('Events', style: TextStyle(fontSize: 15)),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Click the below button to add an event'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text('To Events', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                // You can keep adding more containers here as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}