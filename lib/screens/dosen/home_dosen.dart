import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/time_utils.dart';
import '../../models/matkul_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/sesi_service.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/live_clock.dart';
import 'live_dashboard_screen.dart';

class HomeDosen extends StatefulWidget {
  const HomeDosen({super.key});

  @override
  State<HomeDosen> createState() => _HomeDosenState();
}

class _HomeDosenState extends State<HomeDosen> {
  final _service = SesiService();
  String? _sibukId;

  Future<void> _logout() async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (ya == true && mounted) await context.read<AuthProvider>().logout();
  }

  Future<int?> _pilihDurasi(String nama) {
    return showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        int pilih = 5;
        return StatefulBuilder(
          builder: (ctx, setS) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mulai sesi – $nama',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('QR akan aktif selama:',
                      style: TextStyle(color: AppColors.textSec)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final m in [5, 10, 15, 30])
                        ChoiceChip(
                          label: Text('$m menit'),
                          selected: pilih == m,
                          onSelected: (_) => setS(() => pilih = m),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, pilih),
                    child: const Text('Mulai Sesi'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _mulai(MatkulModel m) async {
    setState(() => _sibukId = m.id);
    try {
      String? sesiId;
      final aktif = await _service.cariSesiAktif(m.id);
      if (aktif != null) {
        sesiId = aktif.id; // lanjutkan sesi yang masih berjalan
      } else {
        if (!mounted) return;
        final durasi = await _pilihDurasi(m.nama);
        if (durasi == null) return;
        sesiId = await _service.buatSesi(m.id, durasiMenit: durasi);
      }
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              LiveDashboardScreen(sesiId: sesiId!, matkulNama: m.nama),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Gagal membuat sesi. Periksa koneksi internet.')));
      }
    } finally {
      if (mounted) setState(() => _sibukId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Dosen'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Keluar',
              onPressed: _logout),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('${Fmt.sapaan(DateTime.now())},',
              style: const TextStyle(color: AppColors.textSec, fontSize: 16)),
          Text(user.nama,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20)),
            child: const LiveClock(color: Colors.white, fontSize: 44),
          ),
          const SizedBox(height: 24),
          const Text('Mata kuliah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          StreamBuilder<List<MatkulModel>>(
            stream: _service.getMatkulDosen(user.uid),
            builder: (context, snap) {
              if (snap.hasError) {
                return const EmptyState(
                    icon: Icons.error_outline,
                    text: 'Gagal memuat mata kuliah.');
              }
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return const EmptyState(
                    icon: Icons.menu_book_outlined,
                    text: 'Belum ada mata kuliah untuk akun ini.');
              }
              return Column(
                children: [
                  for (final m in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Panel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.nama,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('${m.mahasiswaIds.length} mahasiswa',
                                style: const TextStyle(
                                    color: AppColors.textSec)),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed:
                                  _sibukId == null ? () => _mulai(m) : null,
                              icon: _sibukId == m.id
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Icon(Icons.play_arrow),
                              label: const Text('Mulai / Lanjutkan Sesi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
