import 'package:flutter/material.dart';

/// Avatar lingkaran berisi emoji hewan sesuai nama peliharaan.
/// Warna latar pastel berbeda per hewan, adaptif light/dark mode via colorScheme.
class HewanAvatar extends StatelessWidget {
  final String namaHewan;
  final double radius;

  const HewanAvatar({
    super.key,
    required this.namaHewan,
    this.radius = 26,
  });

  String get _emoji {
    final lower = namaHewan.toLowerCase();
    if (lower.contains('mochi')) return '🐱';
    if (lower.contains('bruno')) return '🐶';
    if (lower.contains('cloud')) return '🐰';
    return '🐾';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lower = namaHewan.toLowerCase();

    // Warna pastel lembut berbeda per hewan, otomatis menyesuaikan dark/light
    final Color bg;
    if (lower.contains('mochi')) {
      // Kucing Mochi → oranye muda (error/pink dari seed merah muda)
      bg = cs.errorContainer;
    } else if (lower.contains('bruno')) {
      // Anjing Bruno → biru muda (tertiary teal yang lebih dingin)
      bg = cs.tertiaryContainer;
    } else if (lower.contains('cloud')) {
      // Kelinci Cloud → hijau muda (secondary container)
      bg = cs.secondaryContainer;
    } else {
      bg = cs.surfaceContainerHigh;
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        _emoji,
        style: TextStyle(fontSize: radius * 0.9),
      ),
    );
  }
}
