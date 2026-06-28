import 'package:flutter/material.dart';

class NotificationItem {
  final String title;
  final String body;
  final IconData icon;
  final DateTime time;
  final bool unread;

  const NotificationItem({
    required this.title,
    required this.body,
    required this.icon,
    required this.time,
    this.unread = true,
  });
}
