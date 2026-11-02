class MatkulModel {
  final String id;
  final String nama;
  final String dosenId;
  final List<String> mahasiswaIds;

  MatkulModel({
    required this.id,
    required this.nama,
    required this.dosenId,
    required this.mahasiswaIds,
  });

  factory MatkulModel.fromMap(Map<String, dynamic> map, String id) {
    return MatkulModel(
      id: id,
      nama: map['nama'] ?? '',
      dosenId: map['dosenId'] ?? '',
      mahasiswaIds: List<String>.from(map['mahasiswaIds'] ?? []),
    );
  }
}