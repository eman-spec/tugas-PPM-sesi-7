import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/tugas_repository.dart';
import '../../domain/models/jadwal_perawatan.dart';
import '../../domain/models/tugas_perawatan.dart';
import '../core/content_width.dart';
import '../core/empty_view.dart';
import '../core/error_view.dart';
import '../core/hewan_avatar.dart';
import '../core/kategori_style.dart';
import '../core/loading_view.dart';
import '../core/theme_controller.dart';
import 'home_view_model.dart';

/// Halaman Beranda: sapaan sesuai waktu, kartu berikutnya, ringkasan progres,
/// jadwal hari ini, dan tugas belum selesai.
class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  // ── Helpers waktu ───────────────────────────────────────────────────────────

  static DateTime? _parseJam(String jam) {
    final parts = jam.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  static bool _sudahLewat(String jam) {
    final waktu = _parseJam(jam);
    return waktu != null && waktu.isBefore(DateTime.now());
  }

  static int _jamToMinutes(String jam) {
    final parts = jam.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  static String _durasiDari(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.inHours > 0) {
      final menit = diff.inMinutes.remainder(60);
      return menit > 0
          ? 'dalam ${diff.inHours} jam $menit menit'
          : 'dalam ${diff.inHours} jam lagi';
    }
    if (diff.inMinutes > 0) return 'dalam ${diff.inMinutes} menit lagi';
    return 'sebentar lagi';
  }

  static String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi 🌅';
    if (hour < 15) return 'Selamat Siang ☀️';
    if (hour < 18) return 'Selamat Sore 🌆';
    return 'Selamat Malam 🌙';
  }

  static String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    const days = [
      '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    return '${days[now.weekday]}, ${now.day} ${months[now.month]} ${now.year}';
  }

  void _showSnackBarSelesai(BuildContext context, int id) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tugas selesai 🎉'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(12),
        action: SnackBarAction(
          label: 'Batalkan',
          onPressed: () => viewModel.toggleTugas(id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text('🐾'), SizedBox(width: 8), Text('Pawtime')],
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: ContentWidth(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            if (viewModel.isLoading) {
              return const LoadingView(pesan: 'Memuat data beranda...');
            }
            if (viewModel.error != null) {
              return ErrorView(
                  pesan: viewModel.error!, onRetry: viewModel.load);
            }

            final tugasRepo = context.read<TugasRepository>();
            final totalTugas = tugasRepo.semuaTugas.length;
            final tugasSelesai = tugasRepo.selesai.length;
            final allDone =
                tugasRepo.belumSelesai.isEmpty && totalTugas > 0;
            final progress =
                totalTugas > 0 ? tugasSelesai / totalTugas : 0.0;

            // Jadwal berikutnya (paling dekat setelah sekarang)
            final upcoming = viewModel.jadwalHariIni
                .where((j) => !_sudahLewat(j.jam))
                .toList()
              ..sort((a, b) =>
                  _jamToMinutes(a.jam).compareTo(_jamToMinutes(b.jam)));
            final berikutnya =
                upcoming.isNotEmpty ? upcoming.first : null;

            return RefreshIndicator(
              onRefresh: viewModel.load,
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _buildGreetingHeader(context),
                  const SizedBox(height: 16),
                  allDone
                      ? _buildCelebrationCard(context)
                      : _buildRingkasanCard(
                          context,
                          jadwalCount:
                              viewModel.jadwalHariIni.length,
                          tugasBelumSelesai: viewModel
                              .tugasBelumSelesai.length,
                          progress: progress,
                          tugasSelesai: tugasSelesai,
                          totalTugas: totalTugas,
                        ),
                  const SizedBox(height: 16),
                  if (viewModel.jadwalHariIni.isNotEmpty) ...[
                    _buildJadwalBerikutnyaCard(
                        context, berikutnya),
                    const SizedBox(height: 20),
                  ],
                  _buildSectionTitle(
                    context,
                    icon: Icons.today_rounded,
                    title: 'Jadwal Hari Ini',
                    subtitle: viewModel.hariIni,
                  ),
                  const SizedBox(height: 12),
                  if (viewModel.jadwalHariIni.isEmpty)
                    const EmptyView(
                      icon: Icons.event_available_rounded,
                      judul: 'Hari ini santai, tidak ada jadwal 🐾',
                      deskripsi:
                          'Nikmati waktu bersama anabul-mu!',
                    )
                  else
                    ...viewModel.jadwalHariIni.map(
                      (j) => _buildJadwalCard(
                        context,
                        j,
                        isBerikutnya:
                            berikutnya?.id == j.id,
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    context,
                    icon: Icons.pending_actions_rounded,
                    title: 'Tugas Belum Selesai',
                    badge: viewModel.tugasBelumSelesai.length,
                  ),
                  const SizedBox(height: 12),
                  if (viewModel.tugasBelumSelesai.isEmpty)
                    const SizedBox(
                      height: 160,
                      child: EmptyView(
                        icon: Icons.task_alt_rounded,
                        judul: 'Semua tugas selesai! 🎉',
                        deskripsi:
                            'Kerja bagus menjaga anabul hari ini.',
                      ),
                    )
                  else
                    ...viewModel.tugasBelumSelesai.map(
                      (t) => _buildTugasTile(context, t),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Header sapaan ───────────────────────────────────────────────────────────

  Widget _buildGreetingHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          _getFormattedDate(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ── Kartu ringkasan progres ─────────────────────────────────────────────────

  Widget _buildRingkasanCard(
    BuildContext context, {
    required int jadwalCount,
    required int tugasBelumSelesai,
    required double progress,
    required int tugasSelesai,
    required int totalTugas,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _statChip(
                icon: Icons.calendar_today_rounded,
                label: '$jadwalCount jadwal hari ini',
              ),
              _statChip(
                icon: Icons.pending_actions_rounded,
                label: '$tugasBelumSelesai belum selesai',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            totalTugas > 0
                ? '$tugasSelesai dari $totalTugas tugas selesai'
                : 'Belum ada tugas',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  // ── Kartu perayaan (semua tugas selesai) ───────────────────────────────────

  Widget _buildCelebrationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Text('🐾', style: TextStyle(fontSize: 44)),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Semua tugas selesai!\nHewanmu pasti senang 🥳',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Kartu jadwal berikutnya ─────────────────────────────────────────────────

  Widget _buildJadwalBerikutnyaCard(
      BuildContext context, JadwalPerawatan? item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (item == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Text('🌙', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Text(
              'Semua jadwal hari ini sudah lewat',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final gaya = KategoriJadwalStyle.of(item.kategori);
    final waktu = _parseJam(item.jam);
    final durasiTeks =
        waktu != null ? _durasiDari(waktu) : item.jam;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: cs.primary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.alarm_rounded,
                  size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Jadwal Berikutnya',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              HewanAvatar(namaHewan: item.namaHewan, radius: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.kegiatan,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.namaHewan,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.jam,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: gaya.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    durasiTeks,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: gaya.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(gaya.icon, size: 13, color: gaya.color),
                    const SizedBox(width: 5),
                    Text(
                      gaya.label,
                      style: TextStyle(
                        color: gaya.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section title ───────────────────────────────────────────────────────────

  Widget _buildSectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    int? badge,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 6),
          Text(
            '• $subtitle',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (badge != null && badge > 0) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$badge',
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Card jadwal ─────────────────────────────────────────────────────────────

  Widget _buildJadwalCard(
    BuildContext context,
    JadwalPerawatan item, {
    bool isBerikutnya = false,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final gaya = KategoriJadwalStyle.of(item.kategori);
    final lewat = _sudahLewat(item.jam);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: lewat ? 0.5 : 1.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isBerikutnya
                ? BorderSide(color: cs.primary, width: 2)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                HewanAvatar(namaHewan: item.namaHewan),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.kegiatan,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.namaHewan,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: gaya.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.jam,
                        style: TextStyle(
                          color: gaya.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    lewat
                        ? Icon(Icons.check_circle_rounded,
                            size: 18, color: Colors.green)
                        : Icon(gaya.icon,
                            color: gaya.color, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Tile tugas ──────────────────────────────────────────────────────────────

  Widget _buildTugasTile(BuildContext context, TugasPerawatan item) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: CheckboxListTile(
          value: item.isDone,
          onChanged: (_) {
            viewModel.toggleTugas(item.id);
            _showSnackBarSelesai(context, item.id);
          },
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: theme.colorScheme.primary,
          secondary: HewanAvatar(namaHewan: item.namaHewan, radius: 20),
          title: Text(
            item.judul,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            item.namaHewan,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
