import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/riwayat_provider.dart';
import 'screens/dosen/home_dosen.dart';
import 'screens/login_screen.dart';
import 'screens/mahasiswa/home_mahasiswa.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => RiwayatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi QR Live',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

/// Menentukan layar utama berdasarkan status login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    switch (auth.status) {
      case AuthStatus.memuat:
        return const SplashScreen();
      case AuthStatus.keluar:
        return const LoginScreen();
      case AuthStatus.masuk:
        final user = auth.user!;
        return user.role == 'dosen'
            ? const HomeDosen()
            : const HomeMahasiswa();
    }
  }
}
