import 'package:flutter/material.dart';

class AppbarPage extends StatelessWidget implements PreferredSizeWidget {
  final String? customTitle;
  final bool? backArrow;
  const AppbarPage({super.key, this.customTitle, this.backArrow});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: backArrow ?? false,
      toolbarHeight: 66,
      titleSpacing: 12,
      centerTitle: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E1A2C), Color(0xFF132640)],
          ),
        ),
      ),
      title: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 38,
                height: 38,
                child: Image.network(
                  'https://i.ibb.co/4nkHpYDw/servercurrent.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                customTitle ?? 'FriendSMP75',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: SizedBox(
          width: double.infinity,
          child: Divider(height: 1, thickness: 1, color: Colors.white24),
        ),
      ),
    );
  }
}
