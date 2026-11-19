import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/jadwal_repository.dart';
import '../../data/repositories/tips_repository.dart';
import '../../data/repositories/tugas_repository.dart';
import '../checklist/checklist_screen.dart';
import '../checklist/checklist_view_model.dart';
import '../home/home_screen.dart';
import '../home/home_view_model.dart';
import '../jadwal/jadwal_screen.dart';
import '../jadwal/jadwal_view_model.dart';
import '../tips/tips_screen.dart';
import '../tips/tips_view_model.dart';

/// Shell utama: NavigationBar 4 tab (ikon outlined/filled), IndexedStack, Badge realtime.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  late final HomeViewModel _homeViewModel;
  late final JadwalViewModel _jadwalViewModel;
  late final ChecklistViewModel _checklistViewModel;
  late final TipsViewModel _tipsViewModel;

  @override
  void initState() {
    super.initState();
    final jadwalRepo = context.read<JadwalRepository>();
    final tugasRepo = context.read<TugasRepository>();
    final tipsRepo = context.read<TipsRepository>();

    _homeViewModel = HomeViewModel(jadwalRepo: jadwalRepo, tugasRepo: tugasRepo);
    _jadwalViewModel = JadwalViewModel(jadwalRepo);
    _checklistViewModel = ChecklistViewModel(tugasRepo);
    _tipsViewModel = TipsViewModel(tipsRepo);

    _homeViewModel.load();
    _jadwalViewModel.load();
    _checklistViewModel.load();
    _tipsViewModel.load();
  }

  @override
  void dispose() {
    _homeViewModel.dispose();
    _jadwalViewModel.dispose();
    _checklistViewModel.dispose();
    _tipsViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tugasRepo = context.read<TugasRepository>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(viewModel: _homeViewModel),
          JadwalScreen(viewModel: _jadwalViewModel),
          ChecklistScreen(viewModel: _checklistViewModel),
          TipsScreen(viewModel: _tipsViewModel),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: tugasRepo,
        builder: (context, _) {
          final count = tugasRepo.jumlahBelumSelesai;

          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              const NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'Jadwal',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.checklist_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.checklist_rounded),
                ),
                label: 'Checklist',
              ),
              const NavigationDestination(
                icon: Icon(Icons.lightbulb_outline_rounded),
                selectedIcon: Icon(Icons.lightbulb_rounded),
                label: 'Tips',
              ),
            ],
          );
        },
      ),
    );
  }
}
