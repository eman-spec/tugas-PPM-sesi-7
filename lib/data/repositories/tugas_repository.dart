import 'package:flutter/foundation.dart';
import '../../domain/models/tugas_perawatan.dart';
import '../services/pawtime_service.dart';

/// Repository untuk mengelola tugas checklist perawatan hewan di memori.
/// Meng-extend [ChangeNotifier] agar perubahan data (centang tugas) dapat disimak secara realtime.
class TugasRepository extends ChangeNotifier {
  final PawtimeService _service;
  List<TugasPerawatan> _tugas = [];

  TugasRepository(this._service);

  /// Mengambil daftar semua tugas yang tersimpan di memori.
  List<TugasPerawatan> get semuaTugas => List.unmodifiable(_tugas);

  /// Mengambil daftar tugas yang belum diselesaikan.
  List<TugasPerawatan> get belumSelesai =>
      _tugas.where((t) => !t.isDone).toList();

  /// Mengambil daftar tugas yang sudah diselesaikan.
  List<TugasPerawatan> get selesai => _tugas.where((t) => t.isDone).toList();

  /// Menghitung jumlah tugas yang belum diselesaikan (untuk badge counter).
  int get jumlahBelumSelesai => belumSelesai.length;

  /// Memuat data tugas dari service ke dalam memori.
  Future<void> load() async {
    _tugas = await _service.fetchTugas();
    notifyListeners();
  }

  /// Mengubah status penyelesaian tugas berdasarkan [id] menggunakan copyWith.
  void toggle(int id) {
    final index = _tugas.indexWhere((t) => t.id == id);
    if (index != -1) {
      final item = _tugas[index];
      _tugas[index] = item.copyWith(isDone: !item.isDone);
      notifyListeners();
    }
  }
}
