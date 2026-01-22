import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';

class StaffGallary extends StatefulWidget {
  const StaffGallary({super.key});

  @override
  State<StaffGallary> createState() => _StaffGallaryState();
}

class _StaffGallaryState extends State<StaffGallary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(backArrow: true),
      body: Column(
        
      ),
    );
  }
}
