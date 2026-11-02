import 'matkul_model.dart';

class RiwayatEntry {
  final int pertemuanKe;
  final DateTime mulai;
  final bool hadir;
  final DateTime? waktuHadir;

  const RiwayatEntry({
    required this.pertemuanKe,
    required this.mulai,
    required this.hadir,
    this.waktuHadir,
  });
}

class MatkulStat {
  final MatkulModel matkul;
  final List<RiwayatEntry> entries;

  const MatkulStat({required this.matkul, required this.entries});

  int get total => entries.length;
  int get hadir => entries.where((e) => e.hadir).length;
  double get persen => total == 0 ? 0 : hadir / total;
}
