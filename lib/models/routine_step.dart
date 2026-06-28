import 'package:flutter/material.dart';

class RoutineStep {
  final String id;
  final String name;
  final String hint;
  final IconData icon;

  const RoutineStep({
    required this.id,
    required this.name,
    required this.hint,
    required this.icon,
  });
}

const morningRoutine = <RoutineStep>[
  RoutineStep(id: 'cleanser_am', name: 'Cleanser', hint: 'Gentle face wash', icon: Icons.water_drop_outlined),
  RoutineStep(id: 'toner_am', name: 'Toner', hint: 'Hydrating toner', icon: Icons.opacity_outlined),
  RoutineStep(id: 'serum_am', name: 'Serum', hint: 'Vitamin C serum', icon: Icons.science_outlined),
  RoutineStep(id: 'moist_am', name: 'Moisturizer', hint: 'Lightweight cream', icon: Icons.bubble_chart_outlined),
  RoutineStep(id: 'spf_am', name: 'Sunscreen', hint: 'SPF 30+ daily', icon: Icons.wb_sunny_outlined),
];

const nightRoutine = <RoutineStep>[
  RoutineStep(id: 'cleanser_pm', name: 'Cleanser', hint: 'Double cleansing', icon: Icons.water_drop_outlined),
  RoutineStep(id: 'toner_pm', name: 'Toner', hint: 'Soothing toner', icon: Icons.opacity_outlined),
  RoutineStep(id: 'serum_pm', name: 'Serum', hint: 'Niacinamide / Retinol', icon: Icons.science_outlined),
  RoutineStep(id: 'moist_pm', name: 'Night Cream', hint: 'Repair cream', icon: Icons.nightlight_outlined),
];
