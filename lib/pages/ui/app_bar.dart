import 'package:flutter/material.dart';
import 'package:ac_smart/models/colors.dart';

class ACSmartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ACSmartAppBar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xff043565),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
