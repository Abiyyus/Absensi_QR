import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/time_utils.dart';
import '../services/absensi_service.dart';

/// Kartu putih standar.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;

  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const EmptyState({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.textSec),
          const SizedBox(height: 12),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSec)),
        ],
      ),
    );
  }
}

/// Hasil scan: berhasil / gagal, lengkap dengan jam tercatat sampai detik.
class AbsensiResultSheet extends StatelessWidget {
  final AbsensiResult hasil;
  final VoidCallback onClose;

  const AbsensiResultSheet({
    super.key,
    required this.hasil,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final warna = hasil.sukses ? AppColors.success : AppColors.error;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: warna.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(hasil.sukses ? Icons.check : Icons.close,
                  color: warna, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              hasil.sukses ? 'Absensi Berhasil' : 'Absensi Gagal',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: warna),
            ),
            if (hasil.sukses && hasil.matkulNama != null) ...[
              const SizedBox(height: 8),
              Text(hasil.matkulNama!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 8),
            Text(hasil.pesan,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textSec, fontSize: 15)),
            if (hasil.sukses && hasil.waktu != null) ...[
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tercatat pukul ${Fmt.jam.format(hasil.waktu!)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onClose,
              child: Text(hasil.sukses ? 'Selesai' : 'Scan Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}
