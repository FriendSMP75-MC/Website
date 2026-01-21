import 'package:flutter/material.dart';
import 'package:server_site/widgets/appbar.dart';

class Staffannouncements extends StatefulWidget {
  const Staffannouncements({super.key});

  @override
  State<Staffannouncements> createState() => _StaffannouncementsState();
}

class _StaffannouncementsState extends State<Staffannouncements> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(backArrow: true),
      body: Text(
        'HGello'
      ),
    );
  }
}
