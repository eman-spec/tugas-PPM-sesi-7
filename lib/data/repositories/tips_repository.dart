import '../../domain/models/tips_hewan.dart';
import '../services/pawtime_service.dart';

/// Repository untuk mengelola data tips dan panduan kesehatan hewan.
/// Menerima [PawtimeService] untuk mengambil data sumber.
class TipsRepository {
  final PawtimeService _service;

  TipsRepository(this._service);

  /// Mengambil daftar semua tips kesehatan hewan.
  Future<List<TipsHewan>> getTips() async {
    return await _service.fetchTips();
  }
}
