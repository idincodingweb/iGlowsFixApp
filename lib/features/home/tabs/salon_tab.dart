import 'package:flutter/material.dart';
import '../../articles/articles_screen.dart';

/// Tab "Articles" — sebelumnya berisi Salon Maps, kini diganti
/// menjadi list artikel kesehatan, kecantikan, diet, dll.
class SalonTab extends StatelessWidget {
  const SalonTab({super.key});

  @override
  Widget build(BuildContext context) => const ArticlesScreen();
}
