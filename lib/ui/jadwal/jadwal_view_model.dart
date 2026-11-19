import 'package:flutter/foundation.dart';
import '../../data/repositories/jadwal_repository.dart';
import '../../domain/models/jadwal_perawatan.dart';

/// ViewModel untuk layar Jadwal Perawatan.
/// Mengelola filter kategori ('Makan', 'Klinik', 'Grooming') dan data jadwal.
class JadwalViewModel extends ChangeNotifier {
  final JadwalRepository _jadwalRepo;

  bool _isLoading = false;
  String? _error;
  String _kategoriTerpilih = 'Makan'; // Default sesuai spesifikasi: Makan
  List<JadwalPerawatan> _semuaJadwal = [];

  JadwalViewModel(this._jadwalRepo);

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get kategoriTerpilih => _kategoriTerpilih;

  /// Daftar jadwal yang telah disaring berdasarkan kategori aktif
  List<JadwalPerawatan> get jadwalTersaring {
    return _semuaJadwal
        .where((item) =>
            item.kategori.toLowerCase() == _kategoriTerpilih.toLowerCase())
        .toList();
  }

  /// Mengubah kategori yang dipilih ('Makan', 'Klinik', atau 'Grooming')
  void setKategori(String kategori) {
    if (_kategoriTerpilih != kategori) {
      _kategoriTerpilih = kategori;
      notifyListeners();
    }
  }

  /// Memuat daftar jadwal perawatan dari repository
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _semuaJadwal = await _jadwalRepo.getJadwal();
    } catch (e) {
      _error = 'Gagal memuat jadwal perawatan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
