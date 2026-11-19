import 'package:flutter/foundation.dart';
import '../../data/repositories/tips_repository.dart';
import '../../domain/models/tips_hewan.dart';

/// ViewModel untuk layar Tips & Kesehatan Hewan.
/// Mengambil data panduan dari [TipsRepository].
class TipsViewModel extends ChangeNotifier {
  final TipsRepository _tipsRepo;

  bool _isLoading = false;
  String? _error;
  List<TipsHewan> _tips = [];

  TipsViewModel(this._tipsRepo);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TipsHewan> get tips => List.unmodifiable(_tips);

  /// Memuat daftar tips dan panduan kesehatan dari repository
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tips = await _tipsRepo.getTips();
    } catch (e) {
      _error = 'Gagal memuat tips kesehatan hewan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
