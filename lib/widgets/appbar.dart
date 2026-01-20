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
      title: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Image.network(
                'https://i.ibb.co/4nkHpYDw/servercurrent.jpg',
                height: 40,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),
            Flexible(
              child: Text(
                customTitle ?? 'FriendSMP75',
                overflow: TextOverflow.visible,
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
          child: Divider(height: 1, thickness: 1, color: Colors.grey),
        ),
      ),
    );
  }
}
