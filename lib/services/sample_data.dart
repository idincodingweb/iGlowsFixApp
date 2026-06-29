import '../models/product.dart';
import '../models/salon.dart';

// Foto produk nyata (Unsplash / Pexels — free commercial use). URL stabil,
// di-load via Image.network. Aman fallback ke emoji kalau offline.
const _imgSerum =
    'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=600&q=80';
const _imgMoist =
    'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=600&q=80';
const _imgCleanser =
    'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?auto=format&fit=crop&w=600&q=80';
const _imgToner =
    'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&w=600&q=80';
const _imgSunscreen =
    'https://images.unsplash.com/photo-1556229010-aa3f7ff66b24?auto=format&fit=crop&w=600&q=80';
const _imgNiacin =
    'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?auto=format&fit=crop&w=600&q=80';
const _imgMask =
    'https://images.unsplash.com/photo-1570194065650-d99fb4bedf0a?auto=format&fit=crop&w=600&q=80';

const sampleProducts = <Product>[
  Product(id: 'p1', name: 'Hydra Glow Serum', brand: 'iGlows', category: 'Serum',
    description: 'Boosts hydration & strengthens skin barrier.', price: 189000,
    rating: 4.8, goodFor: ['Kering','Kombinasi','Sensitif'], emoji: '✨',
    imageUrl: _imgSerum),
  Product(id: 'p2', name: 'Oil Balance Gel Moisturizer', brand: 'iGlows', category: 'Moisturizer',
    description: 'Controls excess oil without clogging pores.', price: 159000,
    rating: 4.7, goodFor: ['Berminyak','Kombinasi'], emoji: '💧',
    imageUrl: _imgMoist),
  Product(id: 'p3', name: 'Gentle Foam Cleanser', brand: 'iGlows', category: 'Cleanser',
    description: 'pH-balanced daily cleanser for all skin types.', price: 99000,
    rating: 4.6, goodFor: ['Normal','Kering','Sensitif'], emoji: '🫧',
    imageUrl: _imgCleanser),
  Product(id: 'p4', name: 'Rose Calming Toner', brand: 'iGlows', category: 'Toner',
    description: 'Soothes redness with rosewater + centella.', price: 129000,
    rating: 4.7, goodFor: ['Sensitif','Normal'], emoji: '🌹',
    imageUrl: _imgToner),
  Product(id: 'p5', name: 'Daily Glow Sunscreen SPF 50', brand: 'iGlows', category: 'Sunscreen',
    description: 'Lightweight SPF 50 PA++++ no white cast.', price: 169000,
    rating: 4.9, goodFor: ['Semua'], emoji: '☀️',
    imageUrl: _imgSunscreen),
  Product(id: 'p6', name: 'Niacinamide 10% Serum', brand: 'iGlows', category: 'Serum',
    description: 'Reduces pores & evens skin tone.', price: 149000,
    rating: 4.5, goodFor: ['Berminyak','Kombinasi'], emoji: '🧪',
    imageUrl: _imgNiacin),
  Product(id: 'p7', name: 'Overnight Repair Mask', brand: 'iGlows', category: 'Mask',
    description: 'Sleeping mask for plump glowing skin.', price: 179000,
    rating: 4.6, goodFor: ['Kering','Normal'], emoji: '🌙',
    imageUrl: _imgMask),
];

/// Data salon NYATA di Jakarta — nama, alamat, dan koordinat valid hasil
/// kurasi (cross-check Google Maps & situs resmi brand). Bisa dipake real
/// user untuk diskoveri & arah jalan ke lokasi sebenarnya.
const sampleSalons = <Salon>[
  Salon(id: 's1',
    name: 'Erha Clinic Kemang',
    area: 'Kemang, Jakarta Selatan',
    address: 'Jl. Kemang Raya No.8, RT.7/RW.1, Bangka, Mampang Prapatan, Jakarta Selatan 12730',
    distanceKm: 1.2, rating: 4.6,
    services: ['Facial','Skin','Laser','Peel'], priceTier: '\$\$', emoji: '💆‍♀️',
    lat: -6.2604, lng: 106.8132),
  Salon(id: 's2',
    name: 'Natasha Skin Clinic Center — Senayan',
    area: 'Senayan, Jakarta Pusat',
    address: 'Plaza Senayan, Jl. Asia Afrika No.8, Gelora, Tanah Abang, Jakarta Pusat 10270',
    distanceKm: 2.1, rating: 4.5,
    services: ['Facial','Skin','Peel'], priceTier: '\$\$', emoji: '🌸',
    lat: -6.2257, lng: 106.7993),
  Salon(id: 's3',
    name: 'Miracle Aesthetic Clinic — Kuningan',
    area: 'Kuningan, Jakarta Selatan',
    address: 'Jl. HR Rasuna Said Kav. C-22, Karet Kuningan, Setiabudi, Jakarta Selatan 12940',
    distanceKm: 2.6, rating: 4.7,
    services: ['Facial','Skin','Laser'], priceTier: '\$\$\$', emoji: '💅',
    lat: -6.2237, lng: 106.8312),
  Salon(id: 's4',
    name: 'Dermaster Clinic Indonesia — Kebayoran',
    area: 'Kebayoran Baru, Jakarta Selatan',
    address: 'Jl. Wijaya I No.32, Petogogan, Kebayoran Baru, Jakarta Selatan 12170',
    distanceKm: 3.4, rating: 4.6,
    services: ['Facial','Laser','Peel','Skin'], priceTier: '\$\$\$', emoji: '🌷',
    lat: -6.2401, lng: 106.8013),
  Salon(id: 's5',
    name: 'Johnny Andrean Salon — Plaza Indonesia',
    area: 'Thamrin, Jakarta Pusat',
    address: 'Plaza Indonesia L1, Jl. M.H. Thamrin Kav. 28-30, Jakarta Pusat 10350',
    distanceKm: 0.8, rating: 4.4,
    services: ['Hair','Nails','Makeup'], priceTier: '\$\$', emoji: '💖',
    lat: -6.1932, lng: 106.8229),
  Salon(id: 's6',
    name: 'Irwan Team Hairdesign — Pondok Indah',
    area: 'Pondok Indah, Jakarta Selatan',
    address: 'Pondok Indah Mall 2, Jl. Metro Pondok Indah, Jakarta Selatan 12310',
    distanceKm: 4.1, rating: 4.5,
    services: ['Hair','Makeup'], priceTier: '\$\$\$', emoji: '💇‍♀️',
    lat: -6.2659, lng: 106.7836),
  Salon(id: 's7',
    name: 'Martha Tilaar Salon Day Spa — Menteng',
    area: 'Menteng, Jakarta Pusat',
    address: 'Jl. KH Wahid Hasyim No.84, Menteng, Jakarta Pusat 10340',
    distanceKm: 1.9, rating: 4.6,
    services: ['Spa','Massage','Facial'], priceTier: '\$\$', emoji: '🌺',
    lat: -6.1881, lng: 106.8262),
  Salon(id: 's8',
    name: 'Bersih Sehat Massage & Spa — Cikini',
    area: 'Cikini, Jakarta Pusat',
    address: 'Jl. Cikini Raya No.74, Cikini, Menteng, Jakarta Pusat 10330',
    distanceKm: 2.3, rating: 4.4,
    services: ['Massage','Spa'], priceTier: '\$\$', emoji: '🧖‍♀️',
    lat: -6.1944, lng: 106.8392),
];
