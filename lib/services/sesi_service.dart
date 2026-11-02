import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sesi_model.dart';
import '../models/matkul_model.dart';
import '../models/kehadiran_model.dart';

class SesiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MatkulModel>> getMatkulDosen(String dosenId) {
    return _db
        .collection('matkul')
        .where('dosenId', isEqualTo: dosenId)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => MatkulModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<MatkulModel>> getMatkulMahasiswa(String mahasiswaId) {
    return _db
        .collection('matkul')
        .where('mahasiswaIds', arrayContains: mahasiswaId)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => MatkulModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<SesiModel?> streamSesi(String sesiId) {
    return _db.collection('sesi').doc(sesiId).snapshots().map((d) {
      final data = d.data();
      if (!d.exists || data == null) return null;
      return SesiModel.fromMap(data, d.id);
    });
  }

  Stream<List<KehadiranModel>> streamKehadiran(String sesiId) {
    return _db
        .collection('sesi')
        .doc(sesiId)
        .collection('kehadiran')
        .orderBy('waktu', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => KehadiranModel.fromMap(d.data(), d.id))
            .toList());
  }

  /// Sesi yang masih berjalan untuk matkul ini (null jika tidak ada).
  Future<SesiModel?> cariSesiAktif(String matkulId) async {
    final snap = await _db
        .collection('sesi')
        .where('matkulId', isEqualTo: matkulId)
        .where('aktif', isEqualTo: true)
        .get();
    final now = DateTime.now();
    for (final d in snap.docs) {
      final s = SesiModel.fromMap(d.data(), d.id);
      if (s.selesai.isAfter(now)) return s;
    }
    return null;
  }

  String _tokenAcak([int panjang = 20]) {
    const huruf = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';
    final r = Random.secure();
    return List.generate(panjang, (_) => huruf[r.nextInt(huruf.length)]).join();
  }

  Future<String> buatSesi(String matkulId, {int durasiMenit = 5}) async {
    final matkulDoc = await _db.collection('matkul').doc(matkulId).get();
    final mhsIds =
        List<String>.from(matkulDoc.data()?['mahasiswaIds'] ?? <String>[]);

    final jumlah = await _db
        .collection('sesi')
        .where('matkulId', isEqualTo: matkulId)
        .count()
        .get();
    final pertemuanKe = (jumlah.count ?? 0) + 1;

    final mulai = DateTime.now();
    final selesai = mulai.add(Duration(minutes: durasiMenit));

    final ref = await _db.collection('sesi').add({
      'matkulId': matkulId,
      'pertemuanKe': pertemuanKe,
      'token': _tokenAcak(),
      'mulai': Timestamp.fromDate(mulai),
      'selesai': Timestamp.fromDate(selesai),
      'aktif': true,
      'totalMahasiswa': mhsIds.length,
      'jumlahHadir': 0,
    });
    return ref.id;
  }

  Future<void> akhiriSesi(String sesiId) {
    return _db.collection('sesi').doc(sesiId).update({'aktif': false});
  }
}
