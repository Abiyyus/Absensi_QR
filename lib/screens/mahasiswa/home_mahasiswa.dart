import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/riwayat_provider.dart';
import 'beranda_tab.dart';
import 'profil_screen.dart';
import 'riwayat_screen.dart';
import 'scan_qr_screen.dart';

class HomeMahasiswa extends StatefulWidget {
  const HomeMahasiswa({super.key});

  @override
  State<HomeMahasiswa> createState() => _HomeMahasiswaState();
}

class _HomeMahasiswaState extends State<HomeMahasiswa> {
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = context.read<AuthProvider>().user;
      if (u != null) context.read<RiwayatProvider>().muat(u.uid);
    });
  }

  Future<void> _scan() async {
    final uid = context.read<AuthProvider>().user!.uid;
    final riwayat = context.read<RiwayatProvider>();
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ScanQrScreen()),
    );
    if (ok == true) riwayat.muat(uid); // segarkan rekap setelah absen
  }

  @override
  Widget build(BuildContext context) {
    const pages = [BerandaTab(), RiwayatScreen(), ProfilScreen()];

    return Scaffold(
      body: SafeArea(child: pages[_idx]),
      floatingActionButton: _idx == 0
          ? FloatingActionButton.extended(
              onPressed: _scan,
              backgroundColor: AppColors.success,
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text('Scan QR',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
