/// Model data informasi untuk tips dan edukasi perawatan hewan.
class TipsHewan {
  final int id;
  final String judul;
  final String isi;
  final String kategori; // e.g., "Vaksin", "Makanan", "Kesehatan"

  const TipsHewan({
    required this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
  });

  /// Konversi dari Map JSON ke objek TipsHewan.
  factory TipsHewan.fromJson(Map<String, dynamic> json) {
    return TipsHewan(
      id: json['id'] as int,
      judul: json['judul'] as String,
      isi: json['isi'] as String,
      kategori: json['kategori'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'kategori': kategori,
    };
  }
}
