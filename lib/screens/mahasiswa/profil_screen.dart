import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_widgets.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Future<void> _logout(BuildContext context) async {
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
    if (ya == true && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  Widget _baris(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(k, style: const TextStyle(color: AppColors.textSec)),
            const Spacer(),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final inisial =
        user.nama.trim().isEmpty ? '?' : user.nama.trim()[0].toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text('Profil',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary,
            child: Text(inisial,
                style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 24),
        Panel(
          child: Column(
            children: [
              _baris('Nama', user.nama),
              const Divider(height: 1),
              _baris('NIM / NIDN', user.nimNidn),
              const Divider(height: 1),
              _baris('Peran', user.role == 'dosen' ? 'Dosen' : 'Mahasiswa'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout),
          label: const Text('Keluar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}
