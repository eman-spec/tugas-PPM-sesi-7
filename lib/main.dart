import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'config/dependencies.dart';

/// Titik masuk (entry point) aplikasi Pawtime.
/// Membungkus PawtimeApp dengan MultiProvider yang didefinisikan pada dependencies.dart.
void main() {
  runApp(
    MultiProvider(
      providers: appDependencies,
      child: const PawtimeApp(),
    ),
  );
}
