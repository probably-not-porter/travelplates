// lib/widgets/cupertino_list_item.dart - TEMPORARY FULL REVERT
import 'package:flutter/cupertino.dart';

class CupertinoListItem extends StatelessWidget {
  final Widget title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CupertinoListItem({
    super.key,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // This is the most basic structure possible.
    // It removes the Container, Column, and specific decoration/color.
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: title),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}