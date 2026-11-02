import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants.dart';
import '../../core/time_utils.dart';
import '../../models/sesi_model.dart';
import '../../providers/sesi_provider.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/live_clock.dart';

class LiveDashboardScreen extends StatelessWidget {
  final String sesiId;
  final String matkulNama;

  const LiveDashboardScreen({
    super.key,
    required this.sesiId,
    required this.matkulNama,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SesiProvider()..listenSesi(sesiId),
      child: _LiveBody(matkulNama: matkulNama),
    );
  }
}

class _LiveBody extends StatefulWidget {
  final String matkulNama;
  const _LiveBody({required this.matkulNama});

  @override
  State<_LiveBody> createState() => _LiveBodyState();
}

class _LiveBodyState extends State<_LiveBody> {
  late final Stream<DateTime> _detik = tiapDetik();
  bool _autoAkhiri = false;

  Future<void> _akhiri() async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Akhiri sesi?'),
        content: const Text('Mahasiswa tidak bisa scan lagi setelah ini.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Akhiri',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ya != true || !mounted) return;
    await context.read<SesiProvider>().akhiriSesi();
    if (mounted) Navigator.pop(context);
  }

  /// Kartu atas: jam live, QR, dan hitung mundur (diperbarui tiap detik).
  Widget _kartuQr(SesiModel sesi) {
    return StreamBuilder<DateTime>(
      stream: _detik,
      initialData: DateTime.now(),
      builder: (context, snap) {
        final now = snap.data ?? DateTime.now();
        final sisa = sesi.selesai.difference(now);
        final berakhir = !sesi.aktif || sisa <= Duration.zero;

        if (berakhir && sesi.aktif && !_autoAkhiri) {
          _autoAkhiri = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.read<SesiProvider>().akhiriSesi();
          });
        }

        final total = sesi.durasiDetik <= 0 ? 1 : sesi.durasiDetik;
        final double frac = sisa.inSeconds <= 0 ? 0.0 : (sisa.inSeconds >= total ? 1.0 : sisa.inSeconds / total);
        final warnaSisa = berakhir
            ? AppColors.textSec
            : (sisa.inSeconds <= 60 ? AppColors.error : AppColors.warning);

        return Panel(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 18, color: AppColors.textSec),
                  const SizedBox(width: 6),
                  Text('Pukul ${Fmt.jam.format(now)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSec)),
                  const Spacer(),
                  Text('Pertemuan ${sesi.pertemuanKe}',
                      style: const TextStyle(color: AppColors.textSec)),
                ],
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: berakhir ? 0.12 : 1,
                    child: QrImageView(data: sesi.token, size: 220),
                  ),
                  if (berakhir)
                    const Text('Sesi berakhir',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                berakhir
                    ? 'QR sudah tidak berlaku'
                    : 'QR berakhir dalam ${Fmt.countdown(sisa)}',
                style: TextStyle(
                  color: warnaSisa,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: berakhir ? 0 : frac,
                  minHeight: 8,
                  backgroundColor: AppColors.bg,
                  color: warnaSisa,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mulai ${Fmt.jam.format(sesi.mulai)} • Selesai ${Fmt.jam.format(sesi.selesai)}',
                style:
                    const TextStyle(color: AppColors.textSec, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.matkulNama)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: OutlinedButton(
            onPressed: _akhiri,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              foregroundColor: AppColors.error,
            ),
            child: const Text('Akhiri Sesi'),
          ),
        ),
      ),
      body: Consumer<SesiProvider>(
        builder: (context, prov, _) {
          final sesi = prov.sesi;
          if (sesi == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final hadir = prov.kehadiran.length;
          final total = prov.totalMahasiswa;
          final belum = total - hadir < 0 ? 0 : total - hadir;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            children: [
              _kartuQr(sesi),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hadir',
                              style: TextStyle(color: Colors.white70)),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text('$hadir/$total',
                                key: ValueKey(hadir),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Panel(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Belum scan',
                              style: TextStyle(color: AppColors.textSec)),
                          Text('$belum',
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Daftar hadir',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (prov.kehadiran.isEmpty)
                const EmptyState(
                    icon: Icons.hourglass_empty,
                    text: 'Menunggu mahasiswa scan...')
              else
                for (var i = 0; i < prov.kehadiran.length; i++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: i == 0
                          ? AppColors.success.withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(prov.kehadiran[i].nama,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(prov.kehadiran[i].nim,
                                  style: const TextStyle(
                                      color: AppColors.textSec,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(Fmt.jam.format(prov.kehadiran[i].waktu),
                            style: const TextStyle(
                                color: AppColors.textSec,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
