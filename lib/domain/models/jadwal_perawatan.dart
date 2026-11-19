/// Model data utama untuk jadwal perawatan rutin hewan peliharaan.
class JadwalPerawatan {
  final int id;
  final String namaHewan;
  final String kegiatan;
  final String hari; // "Senin" .. "Minggu"
  final String jam; // format "07:00"
  final String kategori; // "Makan", "Klinik", "Grooming"

  const JadwalPerawatan({
    required this.id,
    required this.namaHewan,
    required this.kegiatan,
    required this.hari,
    required this.jam,
    required this.kategori,
  });

  /// Konversi dari Map JSON ke objek JadwalPerawatan.
  factory JadwalPerawatan.fromJson(Map<String, dynamic> json) {
    return JadwalPerawatan(
      id: json['id'] as int,
      namaHewan: json['namaHewan'] as String,
      kegiatan: json['kegiatan'] as String,
      hari: json['hari'] as String,
      jam: json['jam'] as String,
      kategori: json['kategori'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaHewan': namaHewan,
      'kegiatan': kegiatan,
      'hari': hari,
      'jam': jam,
      'kategori': kategori,
    };
  }
}
