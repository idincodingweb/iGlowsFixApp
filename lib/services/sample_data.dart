import '../models/product.dart';
import '../models/salon.dart';
import '../models/notification_item.dart';
import 'package:flutter/material.dart';

const sampleProducts = <Product>[
  Product(id: 'p1', name: 'Hydra Glow Serum', brand: 'iGlows', category: 'Serum',
    description: 'Boosts hydration & strengthens skin barrier.', price: 189000,
    rating: 4.8, goodFor: ['Kering','Kombinasi','Sensitif'], emoji: '✨'),
  Product(id: 'p2', name: 'Oil Balance Gel Moisturizer', brand: 'iGlows', category: 'Moisturizer',
    description: 'Controls excess oil without clogging pores.', price: 159000,
    rating: 4.7, goodFor: ['Berminyak','Kombinasi'], emoji: '💧'),
  Product(id: 'p3', name: 'Gentle Foam Cleanser', brand: 'iGlows', category: 'Cleanser',
    description: 'pH-balanced daily cleanser for all skin types.', price: 99000,
    rating: 4.6, goodFor: ['Normal','Kering','Sensitif'], emoji: '🫧'),
  Product(id: 'p4', name: 'Rose Calming Toner', brand: 'iGlows', category: 'Toner',
    description: 'Soothes redness with rosewater + centella.', price: 129000,
    rating: 4.7, goodFor: ['Sensitif','Normal'], emoji: '🌹'),
  Product(id: 'p5', name: 'Daily Glow Sunscreen SPF 50', brand: 'iGlows', category: 'Sunscreen',
    description: 'Lightweight SPF 50 PA++++ no white cast.', price: 169000,
    rating: 4.9, goodFor: ['Semua'], emoji: '☀️'),
  Product(id: 'p6', name: 'Niacinamide 10% Serum', brand: 'iGlows', category: 'Serum',
    description: 'Reduces pores & evens skin tone.', price: 149000,
    rating: 4.5, goodFor: ['Berminyak','Kombinasi'], emoji: '🧪'),
  Product(id: 'p7', name: 'Overnight Repair Mask', brand: 'iGlows', category: 'Mask',
    description: 'Sleeping mask for plump glowing skin.', price: 179000,
    rating: 4.6, goodFor: ['Kering','Normal'], emoji: '🌙'),
];

const sampleSalons = <Salon>[
  Salon(id: 's1', name: 'Glow Beauty Lounge', area: 'Beauty Street', distanceKm: 1.2,
    rating: 4.8, services: ['Facial','Skin','Makeup'], priceTier: '\$\$', emoji: '💆‍♀️'),
  Salon(id: 's2', name: 'Pink Petal Spa', area: 'Rose Avenue', distanceKm: 2.1,
    rating: 4.7, services: ['Massage','Spa','Facial'], priceTier: '\$\$', emoji: '🌸'),
  Salon(id: 's3', name: 'Glow City Center', area: 'Blossom Rd', distanceKm: 2.6,
    rating: 4.6, services: ['Hair','Nails','Facial'], priceTier: '\$\$\$', emoji: '💅'),
  Salon(id: 's4', name: 'Bloom Skin Clinic', area: 'Green Park', distanceKm: 3.4,
    rating: 4.9, services: ['Facial','Laser','Peel'], priceTier: '\$\$\$', emoji: '🌷'),
  Salon(id: 's5', name: 'Soft Touch Studio', area: 'Beauty Street', distanceKm: 0.8,
    rating: 4.5, services: ['Nails','Lash'], priceTier: '\$', emoji: '💖'),
];

final sampleNotifications = <NotificationItem>[
  NotificationItem(
    title: 'Waktunya rutinitas malam ✨',
    body: 'Yuk lanjut step skincare malam kamu biar streak tetap menyala!',
    icon: Icons.nightlight_round,
    time: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  NotificationItem(
    title: 'Hasil skin analyzer siap 🪞',
    body: 'Skor kulit kamu hari ini naik 4 poin. Lihat insight lengkapnya.',
    icon: Icons.auto_awesome,
    time: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  NotificationItem(
    title: 'Glowy punya tips baru 💬',
    body: 'Coba niacinamide 10% untuk redain pori — tanya Glowy sekarang.',
    icon: Icons.chat_bubble_rounded,
    time: DateTime.now().subtract(const Duration(hours: 8)),
    unread: false,
  ),
  NotificationItem(
    title: 'Promo Pink Petal Spa 🌸',
    body: 'Diskon 20% facial minggu ini. Booking di tab Salon.',
    icon: Icons.local_offer_outlined,
    time: DateTime.now().subtract(const Duration(days: 1)),
    unread: false,
  ),
];
