import 'package:flutter/foundation.dart';
import '../../data/repositories/jadwal_repository.dart';
import '../../data/repositories/tugas_repository.dart';
import '../../domain/models/jadwal_perawatan.dart';
import '../../domain/models/tugas_perawatan.dart';

/// ViewModel untuk layar Beranda.
/// Menggabungkan data jadwal hari ini dan tugas belum selesai.
/// Meng-observe [TugasRepository] secara langsung agar selalu sinkron ketika data tugas berubah.
class HomeViewModel extends ChangeNotifier {
  final JadwalRepository jadwalRepo;
  final TugasRepository tugasRepo;

  bool _isLoading = false;
  String? _error;
  List<JadwalPerawatan> _jadwalHariIni = [];

  HomeViewModel({
    required this.jadwalRepo,
    required this.tugasRepo,
  }) {
    // Dengarkan perubahan pada TugasRepository
    tugasRepo.addListener(_onTugasChanged);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<JadwalPerawatan> get jadwalHariIni => _jadwalHariIni;
  List<TugasPerawatan> get tugasBelumSelesai => tugasRepo.belumSelesai;
  String get hariIni => _getNamaHariIni();

  /// Callback ketika TugasRepository berubah
  void _onTugasChanged() {
    notifyListeners();
  }

  /// Menentukan nama hari ini dalam Bahasa Indonesia
  String _getNamaHariIni() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return 'Senin';
    }
  }

  /// Memuat data jadwal dan memastikan data tugas sudah dimuat
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final semuaJadwal = await jadwalRepo.getJadwal();
      final hari = _getNamaHariIni();
      _jadwalHariIni = semuaJadwal
          .where((j) => j.hari.toLowerCase() == hari.toLowerCase())
          .toList();

      if (tugasRepo.semuaTugas.isEmpty) {
        await tugasRepo.load();
      }
    } catch (e) {
      _error = 'Gagal memuat ringkasan beranda: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengubah status penyelesaian tugas langsung dari Beranda
  void toggleTugas(int id) {
    tugasRepo.toggle(id);
  }

  @override
  void dispose() {
    // Lepas listener saat ViewModel di-dispose untuk mencegah memory leak
    tugasRepo.removeListener(_onTugasChanged);
    super.dispose();
  }
}
