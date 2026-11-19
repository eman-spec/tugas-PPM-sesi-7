import 'package:flutter_test/flutter_test.dart';
import 'package:pawtime/data/repositories/tips_repository.dart';
import 'package:pawtime/data/services/pawtime_service.dart';
import 'package:pawtime/domain/models/tips_hewan.dart';
import 'package:pawtime/ui/tips/tips_view_model.dart';

/// Fake repository tanpa delay jaringan untuk pengujian TipsViewModel
class FakeTipsRepository extends TipsRepository {
  final bool shouldThrow;
  final List<TipsHewan> dummyTips;

  FakeTipsRepository({
    this.shouldThrow = false,
    this.dummyTips = const [],
  }) : super(PawtimeService());

  @override
  Future<List<TipsHewan>> getTips() async {
    if (shouldThrow) {
      throw Exception('Koneksi internet bermasalah');
    }
    return dummyTips;
  }
}

void main() {
  group('TipsViewModel Test', () {
    test('(a) State awal: isLoading false, error null, dan daftar tips kosong', () {
      final fakeRepo = FakeTipsRepository();
      final viewModel = TipsViewModel(fakeRepo);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.tips, isEmpty);
    });

    test(
        '(b) Setelah load() sukses: data terisi, isLoading false, dan error null',
        () async {
      final sampleTips = [
        const TipsHewan(
          id: 1,
          judul: 'Tips Vaksinasi',
          isi: 'Lakukan vaksinasi tahunan secara berkala.',
          kategori: 'Vaksin',
        ),
        const TipsHewan(
          id: 2,
          judul: 'Hindari Bawang',
          isi: 'Bawang beracun bagi anjing dan kucing.',
          kategori: 'Makanan',
        ),
      ];

      final fakeRepo = FakeTipsRepository(dummyTips: sampleTips);
      final viewModel = TipsViewModel(fakeRepo);

      await viewModel.load();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.tips.length, 2);
      expect(viewModel.tips.first.judul, 'Tips Vaksinasi');
      expect(viewModel.tips.last.kategori, 'Makanan');
    });

    test('(c) Saat repository melempar exception: error terisi dan isLoading false',
        () async {
      final fakeRepo = FakeTipsRepository(shouldThrow: true);
      final viewModel = TipsViewModel(fakeRepo);

      await viewModel.load();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('Koneksi internet bermasalah'));
      expect(viewModel.tips, isEmpty);
    });
  });
}
