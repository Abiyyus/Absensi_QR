import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { memuat, keluar, masuk }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? _user;
  AuthStatus _status = AuthStatus.memuat;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Dipanggil sekali saat aplikasi dibuka: pulihkan sesi login jika ada.
  Future<void> init() async {
    final mulai = DateTime.now();
    try {
      _user = await _service.restoreSession();
    } catch (_) {
      _user = null;
    }
    // Tahan splash minimal 1,5 detik agar tidak berkedip.
    final lewat = DateTime.now().difference(mulai);
    const minimal = Duration(milliseconds: 1500);
    if (lewat < minimal) await Future.delayed(minimal - lewat);
    _status = _user == null ? AuthStatus.keluar : AuthStatus.masuk;
    notifyListeners();
  }

  Future<bool> login(String nimNidn, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _service.login(nimNidn, password);
      _status = AuthStatus.masuk;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Terjadi kesalahan. Coba lagi.';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    _error = null;
    _status = AuthStatus.keluar;
    notifyListeners();
  }
}
