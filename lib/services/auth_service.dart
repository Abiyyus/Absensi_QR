import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Pulihkan sesi login yang tersimpan di perangkat (null jika belum login).
  Future<UserModel?> restoreSession() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final doc = await _db.collection('users').doc(u.uid).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return UserModel.fromMap(data, u.uid);
  }

  Future<UserModel> login(String nimNidn, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: '$nimNidn@absensi.app',
        password: password,
      );
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      final data = doc.data();
      if (!doc.exists || data == null) {
        await _auth.signOut();
        throw AuthException(
            'Data akun belum terdaftar di database. Hubungi admin.');
      }
      return UserModel.fromMap(data, cred.user!.uid);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_pesan(e.code));
    } on FirebaseException catch (e) {
      throw AuthException('Gagal membaca data akun (${e.code}).');
    } catch (_) {
      throw AuthException('Terjadi kesalahan. Coba lagi.');
    }
  }

  String _pesan(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'invalid-email':
      case 'user-not-found':
      case 'wrong-password':
        return 'NIM/NIDN atau password salah.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      default:
        return 'Login gagal ($code).';
    }
  }

  Future<void> logout() => _auth.signOut();
}
