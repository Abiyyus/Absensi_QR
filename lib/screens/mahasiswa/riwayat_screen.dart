import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/time_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/riwayat_provider.dart';
import '../../widgets/custom_widgets.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final rw = context.watch<RiwayatProvider>();

    return RefreshIndicator(
      onRefresh: () => rw.muat(user.uid),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text('Riwayat Kehadiran',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (rw.loading && rw.data.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rw.error != null && rw.data.isEmpty)
            EmptyState(icon: Icons.wifi_off, text: rw.error!)
          else if (rw.data.isEmpty)
            const EmptyState(
                icon: Icons.history, text: 'Belum ada riwayat kehadiran.')
          else
            for (final s in rw.data)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(s.matkul.nama,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          s.total == 0
                              ? 'Belum ada pertemuan'
                              : 'Hadir ${s.hadir} dari ${s.total} pertemuan',
                          style: const TextStyle(
                              color: AppColors.textSec, fontSize: 13)),
                      childrenPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      children: [
                        for (final e in s.entries.reversed)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  e.hadir
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: e.hadir
                                      ? AppColors.success
                                      : AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Pertemuan ${e.pertemuanKe}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                          Fmt.tanggalSingkat
                                              .format(e.mulai),
                                          style: const TextStyle(
                                              color: AppColors.textSec,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(
                                  e.hadir && e.waktuHadir != null
                                      ? Fmt.jam.format(e.waktuHadir!)
                                      : 'Tidak hadir',
                                  style: TextStyle(
                                    color: e.hadir
                                        ? AppColors.textSec
                                        : AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
