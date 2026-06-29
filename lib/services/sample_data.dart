import '../models/product.dart';
import '../models/salon.dart';

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

// Koordinat dummy area Jakarta — owner bisa ganti sesuai data real.
const sampleSalons = <Salon>[
  Salon(id: 's1', name: 'Glow Beauty Lounge', area: 'Senopati, Jakarta', distanceKm: 1.2,
    rating: 4.8, services: ['Facial','Skin','Makeup'], priceTier: '\$\$', emoji: '💆‍♀️',
    lat: -6.2297, lng: 106.8104),
  Salon(id: 's2', name: 'Pink Petal Spa', area: 'Kemang, Jakarta', distanceKm: 2.1,
    rating: 4.7, services: ['Massage','Spa','Facial'], priceTier: '\$\$', emoji: '🌸',
    lat: -6.2614, lng: 106.8136),
  Salon(id: 's3', name: 'Glow City Center', area: 'Sudirman, Jakarta', distanceKm: 2.6,
    rating: 4.6, services: ['Hair','Nails','Facial'], priceTier: '\$\$\$', emoji: '💅',
    lat: -6.2244, lng: 106.8200),
  Salon(id: 's4', name: 'Bloom Skin Clinic', area: 'Menteng, Jakarta', distanceKm: 3.4,
    rating: 4.9, services: ['Facial','Laser','Peel'], priceTier: '\$\$\$', emoji: '🌷',
    lat: -6.1957, lng: 106.8323),
  Salon(id: 's5', name: 'Soft Touch Studio', area: 'Senopati, Jakarta', distanceKm: 0.8,
    rating: 4.5, services: ['Nails','Lash'], priceTier: '\$', emoji: '💖',
    lat: -6.2305, lng: 106.8090),
];
