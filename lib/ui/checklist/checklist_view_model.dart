import 'package:flutter/foundation.dart';
import '../../data/repositories/tugas_repository.dart';
import '../../domain/models/tugas_perawatan.dart';

/// ViewModel untuk layar Checklist Tugas Perawatan.
/// Menghubungkan View dengan [TugasRepository] dan menyajikan daftar tugas belum selesai serta selesai.
class ChecklistViewModel extends ChangeNotifier {
  final TugasRepository _tugasRepo;

  bool _isLoading = false;
  String? _error;

  ChecklistViewModel(this._tugasRepo) {
    // Berlangganan perubahan pada TugasRepository
    _tugasRepo.addListener(_onTugasChanged);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Daftar tugas yang belum diselesaikan
  List<TugasPerawatan> get belumSelesai => _tugasRepo.belumSelesai;

  /// Daftar tugas yang sudah diselesaikan
  List<TugasPerawatan> get selesai => _tugasRepo.selesai;

  void _onTugasChanged() {
    notifyListeners();
  }

  /// Memuat data tugas dari repository
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _tugasRepo.load();
    } catch (e) {
      _error = 'Gagal memuat daftar checklist: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Membalik status selesai tugas
  void toggle(int id) {
    _tugasRepo.toggle(id);
  }

  @override
  void dispose() {
    _tugasRepo.removeListener(_onTugasChanged);
    super.dispose();
  }
}
