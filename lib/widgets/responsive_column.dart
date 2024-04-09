import 'package:flutter/material.dart';

class ResponsiveColumn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool showLabel;
  final VoidCallback onPressed;

  ResponsiveColumn({
    required this.icon,
    required this.color,
    required this.label,
    required this.showLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double iconSize = MediaQuery.of(context).size.width > 600 ? 60.0 : 40.0;
    double labelSize = MediaQuery.of(context).size.width > 600 ? 18.0 : 14.0;

    return Column(
      children: [
        IconButton(
          splashRadius: 40,
          onPressed: onPressed,
          color: color,
          iconSize: iconSize,
          icon: Icon(icon),
        ),
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              label,
              style: TextStyle(fontSize: labelSize),
            ),
          ),
      ],
    );
  }
}