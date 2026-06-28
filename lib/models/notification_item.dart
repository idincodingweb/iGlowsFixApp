import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Notifikasi user. Disimpan di Firestore subcollection
/// users/{uid}/notifications. `kind` menentukan ikon di UI.
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String kind; // routine | analyzer | tips | promo | welcome | streak
  final DateTime time;
  final bool unread;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.time,
    this.unread = true,
  });

  IconData get icon {
    switch (kind) {
      case 'routine':
        return Icons.nightlight_round;
      case 'analyzer':
        return Icons.auto_awesome;
      case 'tips':
        return Icons.chat_bubble_rounded;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'streak':
        return Icons.local_fire_department_rounded;
      case 'welcome':
      default:
        return Icons.favorite_rounded;
    }
  }

  static NotificationItem fromMap(String id, Map<String, dynamic> m) {
    DateTime t;
    final raw = m['createdAt'];
    if (raw is Timestamp) {
      t = raw.toDate();
    } else if (raw is DateTime) {
      t = raw;
    } else if (raw is String) {
      t = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      t = DateTime.now();
    }
    return NotificationItem(
      id: id,
      title: (m['title'] as String?) ?? '',
      body: (m['body'] as String?) ?? '',
      kind: (m['kind'] as String?) ?? 'welcome',
      time: t,
      unread: !((m['read'] as bool?) ?? false),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'kind': kind,
        'read': !unread,
        'createdAt': time,
      };
}
