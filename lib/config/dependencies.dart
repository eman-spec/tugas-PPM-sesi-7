import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/repositories/jadwal_repository.dart';
import '../data/repositories/tips_repository.dart';
import '../data/repositories/tugas_repository.dart';
import '../data/services/pawtime_service.dart';

/// Daftar dependency injection menggunakan Provider.
/// Mengatur instansiasi PawtimeService dan Repositories untuk seluruh aplikasi.
List<SingleChildWidget> get appDependencies => [
      // Service utama untuk request data
      Provider<PawtimeService>(
        create: (_) => PawtimeService(),
      ),

      // Repository untuk jadwal perawatan
      Provider<JadwalRepository>(
        create: (context) => JadwalRepository(context.read<PawtimeService>()),
      ),

      // Repository untuk tugas perawatan (ChangeNotifier untuk state reaktif)
      ChangeNotifierProvider<TugasRepository>(
        create: (context) => TugasRepository(context.read<PawtimeService>()),
      ),

      // Repository untuk tips perawatan hewan
      Provider<TipsRepository>(
        create: (context) => TipsRepository(context.read<PawtimeService>()),
      ),
    ];
