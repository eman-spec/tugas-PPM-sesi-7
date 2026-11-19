import 'package:flutter/material.dart';

/// Mapping kategori jadwal perawatan ke ikon dan warna aksen.
class KategoriJadwalStyle {
  final String label;
  final IconData icon;
  final Color color;

  const KategoriJadwalStyle({
    required this.label,
    required this.icon,
    required this.color,
  });

  static KategoriJadwalStyle of(String kategori) {
    switch (kategori) {
      case 'Makan':
        return const KategoriJadwalStyle(
          label: 'Makan',
          icon: Icons.restaurant_rounded,
          color: Color(0xFFFF8A4C),
        );
      case 'Klinik':
        return const KategoriJadwalStyle(
          label: 'Klinik',
          icon: Icons.local_hospital_rounded,
          color: Color(0xFFE05252),
        );
      case 'Grooming':
        return const KategoriJadwalStyle(
          label: 'Grooming',
          icon: Icons.content_cut_rounded,
          color: Color(0xFF7C5DBF),
        );
      default:
        return const KategoriJadwalStyle(
          label: 'Lainnya',
          icon: Icons.event_rounded,
          color: Color(0xFF2A9D8F),
        );
    }
  }
}

/// Mapping kategori tips hewan ke ikon dan warna aksen.
class KategoriTipsStyle {
  final String label;
  final IconData icon;
  final Color color;

  const KategoriTipsStyle({
    required this.label,
    required this.icon,
    required this.color,
  });

  static KategoriTipsStyle of(String kategori) {
    switch (kategori) {
      case 'Vaksin':
        return const KategoriTipsStyle(
          label: 'Vaksin',
          icon: Icons.vaccines_rounded,
          color: Color(0xFF2A9D8F),
        );
      case 'Makanan':
        return const KategoriTipsStyle(
          label: 'Makanan',
          icon: Icons.fastfood_rounded,
          color: Color(0xFFFF8A4C),
        );
      case 'Kesehatan':
        return const KategoriTipsStyle(
          label: 'Kesehatan',
          icon: Icons.health_and_safety_rounded,
          color: Color(0xFF5278C8),
        );
      default:
        return const KategoriTipsStyle(
          label: 'Lainnya',
          icon: Icons.info_rounded,
          color: Color(0xFF888888),
        );
    }
  }
}
