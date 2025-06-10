// filepath: /home/nash/Documents/AutoFix-Car/autofix_car/lib/widgets/history_item.dart
import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final VoidCallback onTap;

  const HistoryItem({
    Key? key,
    required this.number,
    required this.title,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(number.toString())),
      title: Text(title),
      subtitle: Text(description),
      onTap: onTap,
    );
  }
}