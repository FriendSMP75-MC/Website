import 'package:flutter/material.dart';

class DashboardTiles extends StatelessWidget {
  final String title;
  final Color color;
  final String subText;
  final VoidCallback onTap;

  const DashboardTiles({
    required this.title,
    required this.color,
    required this.onTap,
    required this.subText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Text(subText)),
                  SizedBox(height: 3),
                  // Button appearence
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Click to proceed!',
                        style: TextStyle(backgroundColor: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}