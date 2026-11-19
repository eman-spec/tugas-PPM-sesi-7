import 'package:flutter/material.dart';
import '../../domain/models/tugas_perawatan.dart';
import '../core/content_width.dart';
import '../core/empty_view.dart';
import '../core/error_view.dart';
import '../core/hewan_avatar.dart';
import '../core/loading_view.dart';
import '../core/theme_controller.dart';
import 'checklist_view_model.dart';

/// Halaman Checklist Tugas — header progres, Dismissible geser kiri = selesai,
/// animasi perpindahan item, SnackBar + Batalkan.
class ChecklistScreen extends StatelessWidget {
  final ChecklistViewModel viewModel;

  const ChecklistScreen({super.key, required this.viewModel});

  void _showSnackBarSelesai(BuildContext context, int id) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tugas selesai 🎉'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(12),
        action: SnackBarAction(
          label: 'Batalkan',
          onPressed: () => viewModel.toggle(id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist Tugas'),
        actions: const [ThemeToggleButton()],
      ),
      body: ContentWidth(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            if (viewModel.isLoading) {
              return const LoadingView(
                  pesan: 'Memuat checklist tugas...');
            }
            if (viewModel.error != null) {
              return ErrorView(
                  pesan: viewModel.error!, onRetry: viewModel.load);
            }

            final belumSelesaiList = viewModel.belumSelesai;
            final selesaiList = viewModel.selesai;
            final total =
                belumSelesaiList.length + selesaiList.length;

            if (total == 0) {
              return RefreshIndicator(
                onRefresh: viewModel.load,
                child: ListView(children: [
                  SizedBox(
                    height: 500,
                    child: const EmptyView(
                      icon: Icons.checklist_rtl_rounded,
                      judul: 'Tidak Ada Tugas',
                      deskripsi:
                          'Belum ada tugas perawatan tercatat.',
                    ),
                  ),
                ]),
              );
            }

            return RefreshIndicator(
              onRefresh: viewModel.load,
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  // ── Header progres ─────────────────────────────────
                  _buildProgressHeader(
                      context, selesaiList.length, total),
                  const SizedBox(height: 20),

                  // ── Belum Selesai ──────────────────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Belum Selesai',
                    count: belumSelesaiList.length,
                    icon: Icons.radio_button_unchecked_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: belumSelesaiList.isEmpty
                        ? _buildBelumSelesaiSemua(context)
                        : Column(
                            key: ValueKey(
                                'belum-${belumSelesaiList.length}'),
                            children: belumSelesaiList.map((t) =>
                                _buildDismissibleItem(context, t)).toList(),
                          ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── Selesai ────────────────────────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Selesai',
                    count: selesaiList.length,
                    icon: Icons.check_circle_outline_rounded,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 10),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: selesaiList.isEmpty
                        ? _buildBelumAdaSelesai(context)
                        : Column(
                            children: selesaiList
                                .map((t) => _buildTugasCard(
                                    context, t,
                                    isDone: true))
                                .toList(),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Dismissible item (geser kiri = selesai) ─────────────────────────────────

  Widget _buildDismissibleItem(
      BuildContext context, TugasPerawatan item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey('dismiss-${item.id}'),
        direction: DismissDirection.endToStart,
        background: const SizedBox.shrink(),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade500,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selesai',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 26),
              SizedBox(width: 4),
            ],
          ),
        ),
        onDismissed: (_) {
          viewModel.toggle(item.id);
          _showSnackBarSelesai(context, item.id);
        },
        child: _buildTugasCard(context, item, isDone: false),
      ),
    );
  }

  Widget _buildProgressHeader(
      BuildContext context, int selesai, int total) {
    final theme = Theme.of(context);
    final progress = total > 0 ? selesai / total : 0.0;

    return Card(
      color: theme.colorScheme.primaryContainer
          .withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist_rounded,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  '$selesai dari $total tugas selesai',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${(progress * 100).round()}%',
                    key: ValueKey(selesai),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.onSurface
                    .withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '← Geser item ke kiri untuk menandai selesai',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Container(
            key: ValueKey(count),
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTugasCard(
    BuildContext context,
    TugasPerawatan item, {
    required bool isDone,
  }) {
    final theme = Theme.of(context);
    return Card(
      color: isDone
          ? theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.5)
          : theme.colorScheme.surfaceContainerHighest,
      child: CheckboxListTile(
        value: item.isDone,
        onChanged: (checked) {
          viewModel.toggle(item.id);
          if (checked == true) {
            _showSnackBarSelesai(context, item.id);
          }
        },
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: theme.colorScheme.primary,
        secondary: HewanAvatar(namaHewan: item.namaHewan, radius: 20),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontWeight:
                isDone ? FontWeight.normal : FontWeight.w500,
            fontSize: 14,
            decoration: isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: isDone
                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                : theme.colorScheme.onSurface,
          ),
          child: Text(item.judul),
        ),
        subtitle: Text(
          item.namaHewan,
          style: TextStyle(
            fontSize: 12,
            color: isDone
                ? theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.6)
                : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildBelumSelesaiSemua(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.celebration_rounded,
              color: Colors.green[600], size: 22),
          const SizedBox(width: 10),
          Text(
            'Semua beres! 🎉',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBelumAdaSelesai(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Belum ada tugas yang dicentang.',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
