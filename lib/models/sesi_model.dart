import 'package:cloud_firestore/cloud_firestore.dart';

class SesiModel {
  final String id;
  final String matkulId;
  final int pertemuanKe;
  final String token;
  final DateTime mulai;
  final DateTime selesai;
  final bool aktif;
  final int totalMahasiswa;
  final int jumlahHadir;

  SesiModel({
    required this.id,
    required this.matkulId,
    required this.pertemuanKe,
    required this.token,
    required this.mulai,
    required this.selesai,
    required this.aktif,
    required this.totalMahasiswa,
    required this.jumlahHadir,
  });

  int get durasiDetik => selesai.difference(mulai).inSeconds;

  factory SesiModel.fromMap(Map<String, dynamic> map, String id) {
    return SesiModel(
      id: id,
      matkulId: map['matkulId'] ?? '',
      pertemuanKe: map['pertemuanKe'] ?? 0,
      token: map['token'] ?? '',
      mulai: (map['mulai'] as Timestamp?)?.toDate() ?? DateTime.now(),
      selesai: (map['selesai'] as Timestamp?)?.toDate() ?? DateTime.now(),
      aktif: map['aktif'] ?? false,
      totalMahasiswa: map['totalMahasiswa'] ?? 0,
      jumlahHadir: map['jumlahHadir'] ?? 0,
    );
  }
}