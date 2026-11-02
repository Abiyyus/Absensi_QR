import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/time_utils.dart';
import '../../models/riwayat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/riwayat_provider.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/live_clock.dart';

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final rw = context.watch<RiwayatProvider>();

    return RefreshIndicator(
      onRefresh: () => rw.muat(user.uid),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text(Fmt.sapaan(DateTime.now()),
              style: const TextStyle(color: AppColors.textSec, fontSize: 16)),
          Text(user.nama,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Jam real-time sampai detik
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20)),
            child: const LiveClock(color: Colors.white, fontSize: 44),
          ),
          const SizedBox(height: 16),

          // Ringkasan kehadiran
          Panel(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kehadiran semester ini',
                          style: TextStyle(color: AppColors.textSec)),
                      const SizedBox(height: 4),
                      Text(
                        rw.totalSesi == 0
                            ? '–'
                            : '${(rw.persenTotal * 100).round()}%',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: rw.totalSesi == 0
                              ? AppColors.textSec
                              : pctColor(rw.persenTotal),
                        ),
                      ),
                    ],
                  ),
                ),
                Text('${rw.totalHadir} dari ${rw.totalSesi}\npertemuan',
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: AppColors.textSec)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Per mata kuliah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (rw.loading && rw.data.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rw.error != null && rw.data.isEmpty)
            EmptyState(icon: Icons.wifi_off, text: rw.error!)
          else if (rw.data.isEmpty)
            const EmptyState(
                icon: Icons.menu_book_outlined,
                text: 'Belum ada mata kuliah.')
          else
            for (final s in rw.data) _MatkulCard(stat: s),
        ],
      ),
    );
  }
}

class _MatkulCard extends StatelessWidget {
  final MatkulStat stat;
  const _MatkulCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final warna = stat.total == 0 ? AppColors.textSec : pctColor(stat.persen);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(stat.matkul.nama,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Text(
                  stat.total == 0 ? '–' : '${(stat.persen * 100).round()}%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: warna),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: stat.persen,
                backgroundColor: AppColors.bg,
                color: warna,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stat.total == 0
                  ? 'Belum ada pertemuan'
                  : 'Hadir ${stat.hadir} dari ${stat.total} pertemuan',
              style: const TextStyle(color: AppColors.textSec, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
