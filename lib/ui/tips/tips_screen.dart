import 'package:flutter/material.dart';
import '../../domain/models/tips_hewan.dart';
import '../core/content_width.dart';
import '../core/empty_view.dart';
import '../core/error_view.dart';
import '../core/kategori_style.dart';
import '../core/loading_view.dart';
import '../core/theme_controller.dart';
import 'tips_view_model.dart';

/// Halaman Tips & Kesehatan Hewan — FilterChip di View layer, kartu tap → bottom sheet.
class TipsScreen extends StatefulWidget {
  final TipsViewModel viewModel;

  const TipsScreen({super.key, required this.viewModel});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String? _selectedKategori; // null = "Semua"

  static const List<String> _kategoriList = [
    'Vaksin', 'Makanan', 'Kesehatan',
  ];

  List<TipsHewan> get _filteredTips {
    if (_selectedKategori == null) return widget.viewModel.tips;
    return widget.viewModel.tips
        .where((t) => t.kategori == _selectedKategori)
        .toList();
  }

  void _showDetail(BuildContext context, TipsHewan item) {
    final gaya = KategoriTipsStyle.of(item.kategori);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: gaya.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(gaya.icon, color: gaya.color, size: 40),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: gaya.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.kategori,
                  style: TextStyle(
                    color: gaya.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.judul,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.isi,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.65,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips & Kesehatan'),
        actions: const [ThemeToggleButton()],
      ),
      body: ContentWidth(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            if (widget.viewModel.isLoading) {
              return const LoadingView(
                  pesan: 'Memuat tips kesehatan hewan...');
            }
            if (widget.viewModel.error != null) {
              return ErrorView(
                pesan: widget.viewModel.error!,
                onRetry: widget.viewModel.load,
              );
            }

            final tips = _filteredTips;

            return Column(
              children: [
                // ── Filter Chips ───────────────────────────────────────
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    children: [
                      _buildFilterChip(
                        context,
                        label: 'Semua',
                        isSelected: _selectedKategori == null,
                        onTap: () =>
                            setState(() => _selectedKategori = null),
                      ),
                      const SizedBox(width: 8),
                      ..._kategoriList.map((k) {
                        final gaya = KategoriTipsStyle.of(k);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            context,
                            label: k,
                            icon: gaya.icon,
                            color: gaya.color,
                            isSelected: _selectedKategori == k,
                            onTap: () =>
                                setState(() => _selectedKategori = k),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // ── Daftar Tips ────────────────────────────────────────
                Expanded(
                  child: tips.isEmpty
                      ? EmptyView(
                          icon: Icons.lightbulb_outline_rounded,
                          judul: 'Tidak ada tips'
                              '${_selectedKategori != null ? " $_selectedKategori" : ""}',
                          deskripsi: 'Coba pilih kategori lain.',
                        )
                      : RefreshIndicator(
                          onRefresh: widget.viewModel.load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                                16, 12, 16, 32),
                            itemCount: tips.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) =>
                                _buildTipsCard(context, tips[i]),
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

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final accentColor = color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accentColor
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? accentColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 13,
                color: isSelected
                    ? accentColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context, TipsHewan item) {
    final theme = Theme.of(context);
    final gaya = KategoriTipsStyle.of(item.kategori);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showDetail(context, item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: gaya.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(gaya.icon, color: gaya.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: gaya.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.kategori,
                        style: TextStyle(
                          color: gaya.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.judul,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.isi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Baca selengkapnya',
                          style: TextStyle(
                            color: gaya.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 14, color: gaya.color),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
