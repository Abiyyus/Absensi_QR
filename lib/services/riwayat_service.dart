import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/matkul_model.dart';
import '../models/sesi_model.dart';
import '../models/riwayat_model.dart';

class RiwayatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Rekap kehadiran mahasiswa per mata kuliah, dihitung dari data sesi.
  Future<List<MatkulStat>> muat(String uid) async {
    final mk = await _db
        .collection('matkul')
        .where('mahasiswaIds', arrayContains: uid)
        .get();

    final now = DateTime.now();

    return Future.wait(mk.docs.map((d) async {
      final matkul = MatkulModel.fromMap(d.data(), d.id);
      final sesiSnap = await _db
          .collection('sesi')
          .where('matkulId', isEqualTo: d.id)
          .get();

      final sesiList = sesiSnap.docs
          .map((s) => SesiModel.fromMap(s.data(), s.id))
          .where((s) => !s.mulai.isAfter(now))
          .toList()
        ..sort((a, b) => a.pertemuanKe.compareTo(b.pertemuanKe));

      final entries = await Future.wait(sesiList.map((s) async {
        final k = await _db
            .collection('sesi')
            .doc(s.id)
            .collection('kehadiran')
            .doc(uid)
            .get();
        final waktu = (k.data()?['waktu'] as Timestamp?)?.toDate();
        return RiwayatEntry(
          pertemuanKe: s.pertemuanKe,
          mulai: s.mulai,
          hadir: k.exists,
          waktuHadir: k.exists ? (waktu ?? now) : null,
        );
      }));

      return MatkulStat(matkul: matkul, entries: entries);
    }));
  }
}
