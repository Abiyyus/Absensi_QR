import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sesi_model.dart';
import '../models/kehadiran_model.dart';
import '../services/sesi_service.dart';

/// Dipakai per-layar Live Dashboard (dibuat & dibuang bersama layarnya).
class SesiProvider extends ChangeNotifier {
  final SesiService _service = SesiService();

  SesiModel? _sesi;
  List<KehadiranModel> _kehadiran = [];
  StreamSubscription<SesiModel?>? _sesiSub;
  StreamSubscription<List<KehadiranModel>>? _kehadiranSub;

  SesiModel? get sesi => _sesi;
  List<KehadiranModel> get kehadiran => _kehadiran;
  int get totalMahasiswa => _sesi?.totalMahasiswa ?? 0;

  void listenSesi(String sesiId) {
    _sesiSub?.cancel();
    _kehadiranSub?.cancel();

    _sesiSub = _service.streamSesi(sesiId).listen((s) {
      _sesi = s;
      notifyListeners();
    });
    _kehadiranSub = _service.streamKehadiran(sesiId).listen((list) {
      _kehadiran = list;
      notifyListeners();
    });
  }

  Future<void> akhiriSesi() async {
    final s = _sesi;
    if (s != null && s.aktif) await _service.akhiriSesi(s.id);
  }

  @override
  void dispose() {
    _sesiSub?.cancel();
    _kehadiranSub?.cancel();
    super.dispose();
  }
}
