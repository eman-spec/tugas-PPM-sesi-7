import '../../domain/models/jadwal_perawatan.dart';
import '../services/pawtime_service.dart';

/// Repository untuk mengelola data jadwal perawatan hewan.
/// Menerima [PawtimeService] untuk mengambil data sumber.
class JadwalRepository {
  final PawtimeService _service;

  JadwalRepository(this._service);

  /// Mengambil daftar semua jadwal perawatan.
  Future<List<JadwalPerawatan>> getJadwal() async {
    return await _service.fetchJadwal();
  }
}
