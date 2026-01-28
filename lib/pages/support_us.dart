import 'package:flutter/material.dart';
import 'package:server_site/widgets/ad.dart';

class SupportUsPage extends StatelessWidget {
  const SupportUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAd();
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Support Us")),
      body: const Center(
        child: Text("Thanks for supporting us!"),
      ),
    );
  }
}