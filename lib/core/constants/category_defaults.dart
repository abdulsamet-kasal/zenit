import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int slaDays;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.slaDays,
  });
}

class CategoryDefaults {
  static const List<CategoryItem> categories = [
    CategoryItem(
      id: 'road_pavement',
      name: 'Yol / Kaldırım',
      icon: Icons.alt_route,
      color: Color(0xFF64748B),
      slaDays: 14,
    ),
    CategoryItem(
      id: 'lighting',
      name: 'Aydınlatma',
      icon: Icons.lightbulb_outline,
      color: Color(0xFFF59E0B),
      slaDays: 7,
    ),
    CategoryItem(
      id: 'waste_cleaning',
      name: 'Çöp / Temizlik',
      icon: Icons.delete_outline,
      color: Color(0xFF10B981),
      slaDays: 3,
    ),
    CategoryItem(
      id: 'water_sewage',
      name: 'Su / Kanalizasyon',
      icon: Icons.water_drop_outlined,
      color: Color(0xFF0284C7),
      slaDays: 5,
    ),
    CategoryItem(
      id: 'parks_green',
      name: 'Park / Yeşil Alan',
      icon: Icons.park_outlined,
      color: Color(0xFF16A34A),
      slaDays: 10,
    ),
    CategoryItem(
      id: 'traffic_signs',
      name: 'Trafik / Tabela',
      icon: Icons.traffic_outlined,
      color: Color(0xFFDC2626),
      slaDays: 7,
    ),
    CategoryItem(
      id: 'animals',
      name: 'Sokak Hayvanı',
      icon: Icons.pets_outlined,
      color: Color(0xFF8B5CF6),
      slaDays: 5,
    ),
    CategoryItem(
      id: 'other',
      name: 'Diğer',
      icon: Icons.more_horiz,
      color: Color(0xFF475569),
      slaDays: 14,
    ),
  ];

  static CategoryItem getById(String id) {
    return categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => categories.last,
    );
  }
}
