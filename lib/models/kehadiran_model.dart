import 'package:cloud_firestore/cloud_firestore.dart';

class KehadiranModel {
  final String id;
  final String nama;
  final String nim;
  final DateTime waktu;
  final String status;

  KehadiranModel({
    required this.id,
    required this.nama,
    required this.nim,
    required this.waktu,
    required this.status,
  });

  factory KehadiranModel.fromMap(Map<String, dynamic> map, String id) {
    return KehadiranModel(
      id: id,
      nama: map['nama'] ?? '',
      nim: map['nim'] ?? '',
      waktu: (map['waktu'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'hadir',
    );
  }
}