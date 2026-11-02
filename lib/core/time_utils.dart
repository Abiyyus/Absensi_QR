import 'package:intl/intl.dart';

/// Stream yang mengeluarkan waktu sekarang tepat di setiap pergantian detik.
Stream<DateTime> tiapDetik() async* {
  while (true) {
    final now = DateTime.now();
    yield now;
    await Future.delayed(Duration(milliseconds: 1005 - now.millisecond));
  }
}

class Fmt {
  static final DateFormat jam = DateFormat('HH:mm:ss');
  static final DateFormat jamMenit = DateFormat('HH:mm');
  static final DateFormat tanggal = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  static final DateFormat tanggalSingkat = DateFormat('d MMM yyyy', 'id_ID');

  static String _dua(int n) => n.toString().padLeft(2, '0');

  /// 04:32 atau 01:04:32 jika lebih dari satu jam.
  static String countdown(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '${_dua(h)}:${_dua(m)}:${_dua(s)}' : '${_dua(m)}:${_dua(s)}';
  }

  static String sapaan(DateTime now) {
    final h = now.hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}
