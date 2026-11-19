import '../../domain/models/jadwal_perawatan.dart';
import '../../domain/models/tips_hewan.dart';
import '../../domain/models/tugas_perawatan.dart';

/// Service untuk mengambil data tiruan dari server (simulasi delay jaringan).
class PawtimeService {
  /// Mengambil data jadwal perawatan rutin hewan peliharaan.
  Future<List<JadwalPerawatan>> fetchJadwal() async {
    // Simulasi jeda server selama 1 detik
    await Future.delayed(const Duration(seconds: 1));

    final List<Map<String, dynamic>> rawData = [
      {
        'id': 1,
        'namaHewan': 'Bruno',
        'kegiatan': 'Makan Pagi Kibble Khusus',
        'hari': 'Senin',
        'jam': '07:00',
        'kategori': 'Makan',
      },
      {
        'id': 2,
        'namaHewan': 'Mochi',
        'kegiatan': 'Vaksin Rabies Tahunan di Vet',
        'hari': 'Selasa',
        'jam': '10:00',
        'kategori': 'Klinik',
      },
      {
        'id': 3,
        'namaHewan': 'Cloud',
        'kegiatan': 'Grooming Sisir Bulu Lembut',
        'hari': 'Rabu',
        'jam': '15:30',
        'kategori': 'Grooming',
      },
      {
        'id': 4,
        'namaHewan': 'Bruno',
        'kegiatan': 'Pemeriksaan Rutin Kulit & Telinga',
        'hari': 'Rabu',
        'jam': '11:00',
        'kategori': 'Klinik',
      },
      {
        'id': 5,
        'namaHewan': 'Mochi',
        'kegiatan': 'Makan Siang Wet Food Salmon',
        'hari': 'Kamis',
        'jam': '12:00',
        'kategori': 'Makan',
      },
      {
        'id': 6,
        'namaHewan': 'Cloud',
        'kegiatan': 'Pemberian Sayuran Segar & Hay',
        'hari': 'Kamis',
        'jam': '16:00',
        'kategori': 'Makan',
      },
      {
        'id': 7,
        'namaHewan': 'Bruno',
        'kegiatan': 'Potong Kuku & Pembersihan Telinga',
        'hari': 'Jumat',
        'jam': '14:00',
        'kategori': 'Grooming',
      },
      {
        'id': 8,
        'namaHewan': 'Cloud',
        'kegiatan': 'Pemeriksaan Gigi ke Dokter Hewan',
        'hari': 'Sabtu',
        'jam': '09:30',
        'kategori': 'Klinik',
      },
      {
        'id': 9,
        'namaHewan': 'Bruno',
        'kegiatan': 'Mandi Busa & Sampo Anti Kutu',
        'hari': 'Minggu',
        'jam': '08:30',
        'kategori': 'Grooming',
      },
      {
        'id': 10,
        'namaHewan': 'Mochi',
        'kegiatan': 'Makan Pagi Tuna & Vitamin Bulu',
        'hari': 'Senin',
        'jam': '07:30',
        'kategori': 'Makan',
      },
      {
        'id': 11,
        'namaHewan': 'Mochi',
        'kegiatan': 'Grooming Kering & Potong Cakar',
        'hari': 'Jumat',
        'jam': '16:30',
        'kategori': 'Grooming',
      },
      {
        'id': 12,
        'namaHewan': 'Bruno',
        'kegiatan': 'Makan Malam Daging Rebus & Sayur',
        'hari': 'Minggu',
        'jam': '18:30',
        'kategori': 'Makan',
      },
      {
        'id': 13,
        'namaHewan': 'Mochi',
        'kegiatan': 'Pemeriksaan Kesehatan Berkala',
        'hari': 'Minggu',
        'jam': '10:00',
        'kategori': 'Klinik',
      },
    ];

    return rawData.map((json) => JadwalPerawatan.fromJson(json)).toList();
  }

  /// Mengambil data tugas checklist perawatan harian.
  Future<List<TugasPerawatan>> fetchTugas() async {
    // Simulasi jeda server selama 1 detik
    await Future.delayed(const Duration(seconds: 1));

    final List<Map<String, dynamic>> rawData = [
      {
        'id': 1,
        'judul': 'Beri makan kibble pagi untuk Bruno',
        'namaHewan': 'Bruno',
        'isDone': false,
      },
      {
        'id': 2,
        'judul': 'Ajak jalan pagi keliling taman (30 menit)',
        'namaHewan': 'Bruno',
        'isDone': false,
      },
      {
        'id': 3,
        'judul': 'Bersihkan kotak pasir (litter box) Mochi',
        'namaHewan': 'Mochi',
        'isDone': true,
      },
      {
        'id': 4,
        'judul': 'Ganti air minum botol Cloud dengan air matang',
        'namaHewan': 'Cloud',
        'isDone': false,
      },
      {
        'id': 5,
        'judul': 'Berikan vitamin bulu & minyak ikan Mochi',
        'namaHewan': 'Mochi',
        'isDone': false,
      },
      {
        'id': 6,
        'judul': 'Sikat bulu halus Cloud dan cek area telinga',
        'namaHewan': 'Cloud',
        'isDone': false,
      },
      {
        'id': 7,
        'judul': 'Isi ulang persediaan Timothy Hay di kandang Cloud',
        'namaHewan': 'Cloud',
        'isDone': true,
      },
      {
        'id': 8,
        'judul': 'Bersihkan mangkuk makanan dan area makan hewan',
        'namaHewan': 'Mochi',
        'isDone': false,
      },
    ];

    return rawData.map((json) => TugasPerawatan.fromJson(json)).toList();
  }

  /// Mengambil data tips dan edukasi perawatan hewan peliharaan.
  Future<List<TipsHewan>> fetchTips() async {
    // Simulasi jeda server selama 1 detik
    await Future.delayed(const Duration(seconds: 1));

    final List<Map<String, dynamic>> rawData = [
      {
        'id': 1,
        'judul': 'Jadwal Vaksinasi Kucing & Anjing',
        'isi':
            'Vaksinasi inti (seperti Tricat/Tetracat untuk kucing dan DHPP untuk anjing) wajib diberikan sejak usia 6-8 minggu secara bertahap, lalu diulang setahun sekali untuk mencegah penyakit mematikan seperti panleukopenia dan parvovirus.',
        'kategori': 'Vaksin',
      },
      {
        'id': 2,
        'judul': 'Bahaya Makanan Manusia (Cokelat & Bawang)',
        'isi':
            'Cokelat mengandung teobromin yang beracun bagi sistem saraf jantung hewan. Bawang merah, bawang putih, dan daun bawang mengandung senyawa tiosulfat yang dapat merusak sel darah merah hingga memicu anemia hemolitik akut.',
        'kategori': 'Makanan',
      },
      {
        'id': 3,
        'judul': 'Mengenali Tanda Awal Hewan Sakit',
        'isi':
            'Waspadai jika hewan peliharaan tiba-tiba menjadi lesu, enggan makan selama lebih dari 24 jam, sering bersembunyi di tempat gelap, muntah berulang kali, atau diare. Gejala tersebut mengindikasikan infeksi atau gangguan pencernaan serius.',
        'kategori': 'Kesehatan',
      },
      {
        'id': 4,
        'judul': 'Pentingnya Serat Kasar untuk Kelinci',
        'isi':
            'Kelinci membutuhkan 80-85% porsi pakan berupa rumput kering (Timothy Hay). Serat kasar ini mutlak diperlukan untuk menjaga pergerakan peristaltik usus kelinci serta mengikis gigi depan dan geraham yang tumbuh terus menerus.',
        'kategori': 'Makanan',
      },
      {
        'id': 5,
        'judul': 'Vaksinasi Rabies Itu Mutlak Diperlukan',
        'isi':
            'Rabies adalah penyakit mematikan berstatus zoonosis (dapat menular ke manusia) lewat gigitan atau cakaran. Pastikan anjing dan kucing Anda memperoleh vaksin rabies minimal 1 kali setiap tahun sesuai anjuran dinas peternakan setempat.',
        'kategori': 'Vaksin',
      },
      {
        'id': 6,
        'judul': 'Rutin Menyisir Bulu untuk Cegah Hairball',
        'isi':
            'Kucing menjilati tubuhnya sendiri sehingga bulu rontok sering tertelan. Menyisir bulu secara rutin minimal 2-3 kali seminggu akan meminimalkan gumpalan bulu (hairball) yang dapat menyumbat lambung dan usus halus.',
        'kategori': 'Kesehatan',
      },
      {
        'id': 7,
        'judul': 'Perawatan Kebersihan Gigi dan Gusi',
        'isi':
            'Penumpukan plak dan karang gigi pada anjing dan kucing dapat berujung pada gingivitis dan infeksi bakteri ke organ dalam. Gunakan sikat gigi lembut dan pasta gigi khusus hewan (jangan gunakan pasta gigi manusia karena mengandung fluorida).',
        'kategori': 'Kesehatan',
      },
      {
        'id': 8,
        'judul': 'Camilan Sehat dan Segar Alami',
        'isi':
            'Anda dapat memberikan wortel kecil untuk kelinci, potongan apel tanpa biji untuk anjing, serta labu kuning kukus untuk kucing. Selalu buang biji buah karena beberapa biji (seperti biji apel) mengandung senyawa sianida beracun.',
        'kategori': 'Makanan',
      },
    ];

    return rawData.map((json) => TipsHewan.fromJson(json)).toList();
  }
}
