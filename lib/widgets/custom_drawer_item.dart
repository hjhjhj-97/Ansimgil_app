import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const CustomDrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.appBarTheme.foregroundColor;
    return ListTile(
      leading: Icon(icon, color: color?.withValues(alpha: 0.7),),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
    );
  }
}
