import 'package:flutter/material.dart';
import '../models/riwayat_model.dart';
import '../services/riwayat_service.dart';

class RiwayatProvider extends ChangeNotifier {
  final RiwayatService _service = RiwayatService();

  List<MatkulStat> _data = [];
  bool _loading = false;
  String? _error;
  String? _uid;

  List<MatkulStat> get data => _data;
  bool get loading => _loading;
  String? get error => _error;

  int get totalSesi => _data.fold(0, (a, b) => a + b.total);
  int get totalHadir => _data.fold(0, (a, b) => a + b.hadir);
  double get persenTotal => totalSesi == 0 ? 0 : totalHadir / totalSesi;

  Future<void> muat(String uid) async {
    if (_uid != uid) {
      _uid = uid;
      _data = [];
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _service.muat(uid);
    } catch (_) {
      _error = 'Gagal memuat riwayat. Periksa koneksi internet.';
    }
    _loading = false;
    notifyListeners();
  }
}
