class UserModel {
  final String uid;
  final String nama;
  final String nimNidn;
  final String role;

  UserModel({
    required this.uid,
    required this.nama,
    required this.nimNidn,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      nama: map['nama'] ?? '',
      nimNidn: map['nim_nidn'] ?? '',
      role: map['role'] ?? 'mahasiswa',
    );
  }
}