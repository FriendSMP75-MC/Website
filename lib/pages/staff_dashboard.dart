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
      body: Column(
        children: [
          Row(
            children: [
              GridView.count(
                crossAxisCount: 2,
                children: [
                  Container(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        Text(
                          'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                        ),
                      ],
                    ),
                  ),

                  Container(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        Text(
                          'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                        ),
                      ],
                    ),
                  ),

                  Container(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        Text(
                          'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                        ),
                      ],
                    ),
                  ),

                  Container(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        Text(
                          'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                        ),
                      ],
                    ),
                  ),

                  Container(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        Text(
                          'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
