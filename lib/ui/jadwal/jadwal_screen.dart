import 'package:flutter/material.dart';
import '../../domain/models/jadwal_perawatan.dart';
import '../core/content_width.dart';
import '../core/empty_view.dart';
import '../core/error_view.dart';
import '../core/hewan_avatar.dart';
import '../core/kategori_style.dart';
import '../core/loading_view.dart';
import '../core/theme_controller.dart';
import 'jadwal_view_model.dart';

/// Halaman Jadwal — SegmentedButton filter, jadwal dikelompokkan per hari dimulai
/// dari hari ini, diurutkan per jam, jadwal lewat tampil pudar.
class JadwalScreen extends StatelessWidget {
  final JadwalViewModel viewModel;

  const JadwalScreen({super.key, required this.viewModel});

  static const List<String> _allDays = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  static int _jamToMinutes(String jam) {
    final parts = jam.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 +
        (int.tryParse(parts[1]) ?? 0);
  }

  static bool _sudahLewat(String jam) {
    final now = DateTime.now();
    final parts = jam.split(':');
    if (parts.length != 2) return false;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return false;
    final waktu = DateTime(now.year, now.month, now.day, h, m);
    return waktu.isBefore(now);
  }

  static String _getHariIni() {
    return _allDays[DateTime.now().weekday - 1];
  }

  /// Urutan hari dimulai dari hari ini lalu memutar (Kamis, Jum'at, ..., Rabu).
  static List<String> _daysFromToday() {
    final todayIdx = DateTime.now().weekday - 1;
    return [
      ..._allDays.sublist(todayIdx),
      ..._allDays.sublist(0, todayIdx),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Perawatan'),
        actions: const [ThemeToggleButton()],
      ),
      body: ContentWidth(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            if (viewModel.isLoading) {
              return const LoadingView(
                  pesan: 'Memuat jadwal perawatan...');
            }
            if (viewModel.error != null) {
              return ErrorView(
                  pesan: viewModel.error!, onRetry: viewModel.load);
            }

            final gaya =
                KategoriJadwalStyle.of(viewModel.kategoriTerpilih);
            final jadwalList = viewModel.jadwalTersaring;

            return Column(
              children: [
                // ── SegmentedButton filter ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (s) => s.contains(WidgetState.selected)
                              ? gaya.color.withValues(alpha: 0.15)
                              : null,
                        ),
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (s) => s.contains(WidgetState.selected)
                              ? gaya.color
                              : null,
                        ),
                        iconColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (s) => s.contains(WidgetState.selected)
                              ? gaya.color
                              : null,
                        ),
                        side: WidgetStateProperty.resolveWith<
                            BorderSide?>(
                          (s) => s.contains(WidgetState.selected)
                              ? BorderSide(color: gaya.color)
                              : null,
                        ),
                      ),
                      segments: const [
                        ButtonSegment(
                          value: 'Makan',
                          label: Text('Makan'),
                          icon: Icon(Icons.restaurant_rounded),
                        ),
                        ButtonSegment(
                          value: 'Klinik',
                          label: Text('Klinik'),
                          icon: Icon(Icons.local_hospital_rounded),
                        ),
                        ButtonSegment(
                          value: 'Grooming',
                          label: Text('Grooming'),
                          icon: Icon(Icons.content_cut_rounded),
                        ),
                      ],
                      selected: {viewModel.kategoriTerpilih},
                      onSelectionChanged: (sel) =>
                          viewModel.setKategori(sel.first),
                    ),
                  ),
                ),

                // ── Info header kategori ───────────────────────────────
                if (jadwalList.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildKategoriHeader(
                        context, gaya, jadwalList.length),
                  ),

                const SizedBox(height: 4),

                // ── Daftar beranimasi ──────────────────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildGroupedList(
                      context,
                      jadwalList,
                      key: ValueKey(viewModel.kategoriTerpilih),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKategoriHeader(
    BuildContext context,
    KategoriJadwalStyle gaya,
    int count,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: gaya.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(gaya.icon, size: 16, color: gaya.color),
          const SizedBox(width: 8),
          Text(
            '${gaya.label} · $count jadwal ditemukan',
            style: theme.textTheme.labelMedium?.copyWith(
              color: gaya.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    List<JadwalPerawatan> jadwalList, {
    Key? key,
  }) {
    final hariIni = _getHariIni();

    if (jadwalList.isEmpty) {
      return SizedBox(
        key: key,
        height: 400,
        child: EmptyView(
          icon: Icons.calendar_today_rounded,
          judul:
              'Belum Ada Jadwal ${viewModel.kategoriTerpilih}',
          deskripsi: 'Tidak ada jadwal untuk kategori ini.',
        ),
      );
    }

    // Kelompokkan per hari
    final Map<String, List<JadwalPerawatan>> grouped = {};
    for (final item in jadwalList) {
      grouped.putIfAbsent(item.hari, () => []).add(item);
    }

    // Urutkan hari dari hari ini dan sort per jam
    final sortedDays =
        _daysFromToday().where((h) => grouped.containsKey(h)).toList();
    for (final hari in sortedDays) {
      grouped[hari]!.sort(
          (a, b) => _jamToMinutes(a.jam).compareTo(_jamToMinutes(b.jam)));
    }

    return RefreshIndicator(
      onRefresh: viewModel.load,
      child: ListView(
        key: key,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          for (final hari in sortedDays) ...[
            _buildDayHeader(context, hari, hariIni),
            const SizedBox(height: 8),
            ...grouped[hari]!.map(
              (item) => _buildJadwalCard(context, item, hari == hariIni),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildDayHeader(
      BuildContext context, String hari, String hariIni) {
    final theme = Theme.of(context);
    final isToday = hari == hariIni;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Row(
        children: [
          Text(
            hari,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isToday
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Hari ini',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJadwalCard(
    BuildContext context,
    JadwalPerawatan item,
    bool isHariIni,
  ) {
    final theme = Theme.of(context);
    final gaya = KategoriJadwalStyle.of(item.kategori);
    final lewat = isHariIni && _sudahLewat(item.jam);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: lewat ? 0.45 : 1.0,
        child: Card(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Strip warna kategori di kiri
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: gaya.color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        14, 14, 14, 14),
                    child: Row(
                      children: [
                        HewanAvatar(namaHewan: item.namaHewan),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                item.kegiatan,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.namaHewan,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4),
                              decoration: BoxDecoration(
                                color: gaya.color
                                    .withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(20),
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
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: Colors.green)
                                : Icon(gaya.icon,
                                    color: gaya.color, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
