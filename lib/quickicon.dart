import 'package:flutter/material.dart';

Widget quickLinkIcon(IconData icon, String label) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        CircleAvatar(
          child: Icon(icon),
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    ),
  );
}
