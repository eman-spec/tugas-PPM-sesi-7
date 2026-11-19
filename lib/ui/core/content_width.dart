import 'package:flutter/material.dart';

/// Pembungkus responsif: membatasi lebar konten maks 600 dp dan menengahkan ke atas
/// agar tampil rapi di Chrome/tablet tanpa mengubah tampilan di HP (< 600 dp).
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
