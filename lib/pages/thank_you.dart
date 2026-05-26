import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:server_site/widgets/appbar.dart';
import 'package:server_site/widgets/footer.dart';
import 'package:server_site/widgets/nav_drawer.dart';

class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 760;

    return Scaffold(
      appBar: AppbarPage(customTitle: 'FriendSMP75 - Thank You'),
      endDrawer: NavDrawer(currentPage: 'Support us', parentContext: context),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A1423), Color(0xFF102036), Color(0xFF0A1423)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 20,
                  24,
                  isMobile ? 12 : 20,
                  0,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isMobile ? 18 : 28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2B395F), Color(0xFF214E6F)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.favorite_rounded,
                            size: 64,
                            color: Color(0xFF43D3E2),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Thank You for Donating!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 30 : 42,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Your support helps keep FriendSMP75 running and growing for the whole community.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF43D3E2),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 16,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => context.go('/support'),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Back to Support Us'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const MyFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
