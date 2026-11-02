import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/live_clock.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nim = TextEditingController();
  final _pass = TextEditingController();
  bool _lihat = false;

  @override
  void dispose() {
    _nim.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    // Jika berhasil, AuthGate otomatis pindah ke beranda.
    await context.read<AuthProvider>().login(_nim.text.trim(), _pass.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.qr_code_scanner,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 28),
                const Text('Masuk ke akun',
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Gunakan NIM (mahasiswa) atau NIDN (dosen).',
                    style:
                        TextStyle(color: AppColors.textSec, fontSize: 16)),
                const SizedBox(height: 20),
                const LiveClock(
                    color: AppColors.textSec, fontSize: 22, showDate: false),
                const SizedBox(height: 28),
                const Text('NIM / NIDN',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nim,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                const Text('Password',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pass,
                  obscureText: !_lihat,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(_lihat
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _lihat = !_lihat),
                    ),
                  ),
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(auth.error!,
                        style: const TextStyle(color: AppColors.error)),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _login,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
