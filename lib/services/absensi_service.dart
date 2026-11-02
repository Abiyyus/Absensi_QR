import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AbsensiResult {
  final bool sukses;
  final String pesan;
  final DateTime? waktu;
  final String? matkulNama;

  const AbsensiResult({
    required this.sukses,
    required this.pesan,
    this.waktu,
    this.matkulNama,
  });
}

class _Gagal implements Exception {
  final String pesan;
  _Gagal(this.pesan);
}

class AbsensiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AbsensiResult> prosesScanQR(String tokenQR, UserModel mhs) async {
    try {
      // 1. Cari sesi aktif dengan token ini
      final q = await _db
          .collection('sesi')
          .where('token', isEqualTo: tokenQR)
          .where('aktif', isEqualTo: true)
          .limit(1)
          .get();
      if (q.docs.isEmpty) {
        throw _Gagal('QR tidak valid atau sesi sudah berakhir.');
      }
      final sesiDoc = q.docs.first;
      final data = sesiDoc.data();

      // 2. Cek kedaluwarsa
      final selesai = (data['selesai'] as Timestamp).toDate();
      if (!DateTime.now().isBefore(selesai)) {
        throw _Gagal('QR sudah kedaluwarsa. Minta dosen menampilkan QR baru.');
      }

      // 3. Cek mahasiswa terdaftar di matkul
      final matkulId = data['matkulId'] as String;
      final matkulDoc = await _db.collection('matkul').doc(matkulId).get();
      final mk = matkulDoc.data() ?? <String, dynamic>{};
      final ids = List<String>.from(mk['mahasiswaIds'] ?? <String>[]);
      if (!ids.contains(mhs.uid)) {
        throw _Gagal('Kamu tidak terdaftar di mata kuliah ini.');
      }

      // 4. Tulis kehadiran + naikkan counter (atomik)
      final sesiRef = _db.collection('sesi').doc(sesiDoc.id);
      final kehadiranRef = sesiRef.collection('kehadiran').doc(mhs.uid);

      await _db.runTransaction((tx) async {
        final snap = await tx.get(kehadiranRef);
        if (snap.exists) throw _Gagal('Kamu sudah absen di sesi ini.');
        tx.set(kehadiranRef, {
          'nama': mhs.nama,
          'nim': mhs.nimNidn,
          'waktu': FieldValue.serverTimestamp(),
          'status': 'hadir',
        });
        tx.update(sesiRef, {'jumlahHadir': FieldValue.increment(1)});
      });

      return AbsensiResult(
        sukses: true,
        pesan: 'Kehadiran berhasil dicatat.',
        waktu: DateTime.now(),
        matkulNama: mk['nama'] as String?,
      );
    } on _Gagal catch (e) {
      return AbsensiResult(sukses: false, pesan: e.pesan);
    } on FirebaseException catch (e) {
      final offline = e.code == 'unavailable' || e.code == 'network-request-failed';
      return AbsensiResult(
        sukses: false,
        pesan: offline
            ? 'Tidak ada koneksi internet.'
            : 'Gagal mencatat absensi (${e.code}).',
      );
    } catch (_) {
      return const AbsensiResult(
          sukses: false, pesan: 'Terjadi kesalahan. Coba scan lagi.');
    }
  }
}
