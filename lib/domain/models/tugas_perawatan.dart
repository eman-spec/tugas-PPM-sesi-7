/// Model data aksi untuk tugas checklist perawatan hewan.
class TugasPerawatan {
  final int id;
  final String judul;
  final String namaHewan;
  final bool isDone;

  const TugasPerawatan({
    required this.id,
    required this.judul,
    required this.namaHewan,
    this.isDone = false,
  });

  /// Konversi dari Map JSON ke objek TugasPerawatan.
  factory TugasPerawatan.fromJson(Map<String, dynamic> json) {
    return TugasPerawatan(
      id: json['id'] as int,
      judul: json['judul'] as String,
      namaHewan: json['namaHewan'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  /// Membuat salinan objek dengan perubahan nilai tertentu.
  TugasPerawatan copyWith({
    int? id,
    String? judul,
    String? namaHewan,
    bool? isDone,
  }) {
    return TugasPerawatan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      namaHewan: namaHewan ?? this.namaHewan,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'namaHewan': namaHewan,
      'isDone': isDone,
    };
  }
}
