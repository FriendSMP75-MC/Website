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

        SizedBox(
          height: double.infinity,
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 50,
            mainAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            children: [
              Container(
                width: 400,
                color: Colors.grey,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Announcements',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(8.0),
                      child: Text(
                        'Click the below button to make announcement',
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.blue,
                      child: Text(
                        'To announcment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Announcements
              Container(
                color: Colors.grey,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Announcements',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(8.0),
                      child: Text(
                        'Click the below button to make announcement',
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.blue,
                      child: Text(
                        'To announcment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Gallary [Will be available soon]
              Container(
                color: Colors.grey,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Gallary',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(8.0),
                      child: Text(
                        'Click the below button to add an image to Gallery',
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.blue,
                      child: Text(
                        'To Gallary',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Status update [Instatus API]
              Container(
                color: Colors.grey,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Announcements',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(8.0),
                      child: Text(
                        'Click the below button to make announcement',
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.blue,
                      child: Text(
                        'To announcment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Place holder
              Container(
                color: Colors.grey,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Announcements',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(8.0),
                      child: Text(
                        'Click the below button to make announcement',
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.blue,
                      child: Text(
                        'To announcment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Place holder
              Container(
                color: Colors.grey,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Announcements',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(8.0),
                      child: Text(
                        'Click the below button to make announcement',
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.blue,
                      child: Text(
                        'To announcment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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
