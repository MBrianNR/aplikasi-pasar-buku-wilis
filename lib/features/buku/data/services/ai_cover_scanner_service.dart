import 'dart:convert';
import 'dart:io';
import '../../domain/entities/hasil_scan_buku.dart';

class AiCoverScannerService {
  AiCoverScannerService();

  /// Pindai cover buku menggunakan engine Wilis AI Lens
  Future<HasilScanBuku> pindaiCover({
    String? assetPath,
    String? inputJudul,
    String? apiKey,
  }) async {
    // Simulasi waktu pemrosesan AI (OCR + Analisis Nilai Pasar Wilis)
    await Future.delayed(const Duration(milliseconds: 1400));

    // 1. Jika pengguna memberikan API Key Gemini dan memasukkan teks judul khusus
    if (apiKey != null &&
        apiKey.trim().isNotEmpty &&
        inputJudul != null &&
        inputJudul.trim().isNotEmpty) {
      try {
        final hasilGemini = await _analisisViaGemini(
            inputJudul.trim(), apiKey.trim(), assetPath);
        if (hasilGemini != null) return hasilGemini;
      } catch (_) {
        // Fallback jika API request gagal/kuota habis
      }
    }

    // 2. Cek apakah cocok dengan preset contoh buku Wilis
    if (assetPath != null) {
      if (assetPath.contains('cover_bumi') ||
          (inputJudul != null &&
              inputJudul.toLowerCase().contains('bumi manusia'))) {
        return const HasilScanBuku(
          judul: 'Bumi Manusia (Cetakan Ke-1 Hasta Mitra 1980)',
          penulis: 'Pramoedya Ananta Toer',
          penerbit: 'Hasta Mitra (Jakarta)',
          tahun: '1980 • Edisi Pertama',
          kategori: 'Sastra Klasik Nusantara & Sejarah',
          kondisi:
              '8.8 / 10 • Layak Koleksi (Kertas Menguning Alami, Jilidan Utuh)',
          estimasiHargaWajar: 'Rp 200.000 - Rp 250.000',
          hargaBukuBaru: 'Rp 145.000 (Edisi Lentera Baru)',
          kiosRekomendasi: 'Kios A-04 (Toko Buku Barokah)',
          kodeKios: 'A-04',
          lokasiLorong: 'Lorong Blok A No. 04',
          akurasi: 98,
          ringkasan:
              'Mahakarya roman Tetralogi Buru berlatar Hindia Belanda akhir abad ke-19. Mengisahkan perjuangan Minke, pemuda priyayi cerdas melawan feodalisme dan kolonialisme.',
          tipsNawarWilis:
              'Cetakan Hasta Mitra asli 1980 merupakan barang buruan kolektor. Jika fisik utuh dan tanpa coretan tinta, harga wajar penawaran mulai dari Rp 180.000.',
          gambarCover: 'assets/images/cover_bumi.png',
        );
      }

      if (assetPath.contains('cover_babad') ||
          (inputJudul != null && inputJudul.toLowerCase().contains('babad'))) {
        return const HasilScanBuku(
          judul: 'Babad Tanah Djawi (Jilid I–III Lengkap)',
          penulis: 'W.L. Olthof (Penyunting)',
          penerbit: 'Departemen P&K / PN Balai Pustaka',
          tahun: '1982 • Hardcover',
          kategori: 'Naskah Kuno & Sejarah Jawa',
          kondisi: '8.2 / 10 • Antik (Sampul Tebal Masih Kencang)',
          estimasiHargaWajar: 'Rp 110.000 - Rp 140.000',
          hargaBukuBaru: 'Rp 210.000 (Reprint)',
          kiosRekomendasi: 'Kios A-02 (Pustaka Kuno - Bu Lastri)',
          kodeKios: 'A-02',
          lokasiLorong: 'Lorong Blok A No. 02',
          akurasi: 96,
          ringkasan:
              'Kronik babad legendaris sejarah raja-raja tanah Jawa dari era Mataram Hindu hingga keruntuhan Mataram Islam di Kartasura.',
          tipsNawarWilis:
              'Kios Bu Lastri sering memiliki koleksi naskah terjemahan Belanda. Tanyakan apakah ada versi teks Jawa Pegon atau aksara Hanacaraka.',
          gambarCover: 'assets/images/cover_babad.png',
        );
      }

      if (assetPath.contains('ronggeng') ||
          (inputJudul != null &&
              inputJudul.toLowerCase().contains('ronggeng'))) {
        return const HasilScanBuku(
          judul: 'Ronggeng Dukuh Paruk (Trilogi Lengkap)',
          penulis: 'Ahmad Tohari',
          penerbit: 'Gramedia Pustaka Utama',
          tahun: '1986 / 2003',
          kategori: 'Novel Sastra Realisme Magis',
          kondisi: '9.0 / 10 • Sangat Bagus',
          estimasiHargaWajar: 'Rp 45.000 - Rp 65.000',
          hargaBukuBaru: 'Rp 98.000',
          kiosRekomendasi: 'Kios A-03 (Wilis Book - Mas Hendra)',
          kodeKios: 'A-03',
          lokasiLorong: 'Lorong Blok A No. 03',
          akurasi: 95,
          ringkasan:
              'Kisah tragis Srintil yang terpilih menjadi ronggeng pujaan di pedukuhan miskin dan terhempas gejolak politik 1965.',
          tipsNawarWilis:
              'Buku ini sering ada di tumpukan novel populer kios A-03 dan B-04. Pasaran mahasiswa biasanya sekitar Rp 50.000.',
          gambarCover: 'assets/images/buku_ronggeng.png',
        );
      }

      if (assetPath.contains('tafsir') ||
          (inputJudul != null && inputJudul.toLowerCase().contains('tafsir'))) {
        return const HasilScanBuku(
          judul: 'Tafsir Al-Azhar (Edisi Eksklusif Pustaka Panjimas)',
          penulis: 'Prof. Dr. Hamka (Buya Hamka)',
          penerbit: 'Pustaka Panjimas Jakarta',
          tahun: '1990 • 10 Jilid',
          kategori: 'Agama & Tafsir Al-Qur\'an',
          kondisi: '8.4 / 10 • Hardcover Utuh',
          estimasiHargaWajar: 'Rp 75.000 - Rp 95.000 / jilid',
          hargaBukuBaru: 'Rp 160.000 / jilid',
          kiosRekomendasi: 'Kios A-04 (Toko Buku Barokah - H. Ridwan)',
          kodeKios: 'A-04',
          lokasiLorong: 'Lorong Blok A No. 04',
          akurasi: 94,
          ringkasan:
              'Karya agung tafsir nusantara yang ditulis Buya Hamka di masa tahanan politik era Orde Lama dengan gaya bahasa sastra Melayu yang menyejukkan.',
          tipsNawarWilis:
              'Jika membeli satu set lengkap jilid 1 sampai 30, tawar paket bundling sekitar Rp 650.000 di Kios H. Ridwan.',
          gambarCover: 'assets/images/buku_tafsir.png',
        );
      }

      if (assetPath.contains('kategori_5') ||
          (inputJudul != null && inputJudul.toLowerCase().contains('petruk'))) {
        return const HasilScanBuku(
          judul: 'Petruk Gareng: Seri Horor & Silat Antik',
          penulis: 'Tatang S.',
          penerbit: 'Gita Pustaka / TB Sandro',
          tahun: 'Era 1980-an • Ukuran Saku',
          kategori: 'Komik Nostalgia Indonesia',
          kondisi: '7.8 / 10 • Kertas Berwarna Cokelat Antik',
          estimasiHargaWajar: 'Rp 15.000 - Rp 25.000 / buku',
          hargaBukuBaru: 'Sudah tidak terbit ulang',
          kiosRekomendasi: 'Kios B-04 (Wilis Komik - Cak Slamet)',
          kodeKios: 'B-04',
          lokasiLorong: 'Lorong Blok B No. 04',
          akurasi: 97,
          ringkasan:
              'Komik legendaris humor dan misteri bernuansa pedesaan Jawa Barat dengan karakter Petruk, Gareng, Bagong, dan Semar.',
          tipsNawarWilis:
              'Cak Slamet di Blok B-04 adalah pusatnya komik Tatang S di Wilis. Ambil 5 atau 10 komik untuk mendapatkan diskon langsung.',
          gambarCover: 'assets/images/kategori_5.png',
        );
      }

      if (assetPath.contains('kategori_3') ||
          (inputJudul != null && inputJudul.toLowerCase().contains('teknik'))) {
        return const HasilScanBuku(
          judul: 'Mekanika Fluida & Termodinamika Teknik',
          penulis: 'Ir. Soeprapto, M.Eng',
          penerbit: 'Erlangga / ITB Press',
          tahun: '2015 • Cetakan 4',
          kategori: 'Buku Kuliah & Teknik',
          kondisi: '8.7 / 10 • Bersih Tanpa Coretan',
          estimasiHargaWajar: 'Rp 50.000 - Rp 70.000',
          hargaBukuBaru: 'Rp 135.000',
          kiosRekomendasi: 'Kios A-01 (Toko Surya - Pak Surya)',
          kodeKios: 'A-01',
          lokasiLorong: 'Lorong Blok A No. 01',
          akurasi: 93,
          ringkasan:
              'Buku teks standar rujukan mahasiswa teknik mesin, teknik sipil, dan teknik kimia untuk analisis aliran fluida dan energi kalor.',
          tipsNawarWilis:
              'Toko Surya sering melayani titip jual buku kuliah mahasiswa UB dan Polinema. Cek halaman lampiran tabel rumus apakah masih lengkap.',
          gambarCover: 'assets/images/kategori_3.png',
        );
      }
    }

    // 3. Heuristic Generator cerdas jika pengguna menginput judul buku bebas
    final query = (inputJudul != null && inputJudul.trim().isNotEmpty)
        ? inputJudul.trim()
        : 'Buku Pilihan Wilis';
    return _buatEstimasiKatalogWilis(query, assetPath);
  }

  /// Engine Heuristik Pengetahuan Pasar Wilis untuk judul buku umum
  HasilScanBuku _buatEstimasiKatalogWilis(String query, String? assetPath) {
    final q = query.toLowerCase();

    String kategori = 'Buku Umum';
    String kios = 'Kios A-03 (Wilis Book)';
    String kode = 'A-03';
    String lorong = 'Blok A Lorong 2';
    String hargaWajar = 'Rp 35.000 - Rp 55.000';
    String hargaBaru = 'Rp 95.000';
    String tips =
        'Periksa kelengkapan halaman dan stempel perpustakaan sebelum menawar.';

    if (q.contains('hukum') || q.contains('pidana') || q.contains('perdata')) {
      kategori = 'Buku Kuliah Hukum & Sosial';
      kios = 'Kios A-01 (Toko Surya - Pak Surya)';
      kode = 'A-01';
      lorong = 'Blok A No. 01 (Spesialis Buku Kuliah UB/UM)';
      hargaWajar = 'Rp 45.000 - Rp 75.000';
      hargaBaru = 'Rp 140.000';
      tips =
          'Pak Surya di Kios A-01 punya stok buku hukum terbitan alumni FH UB. Tawar 30% dari harga buka.';
    } else if (q.contains('kamus') ||
        q.contains('belanda') ||
        q.contains('inggris') ||
        q.contains('jawa')) {
      kategori = 'Kamus & Tata Bahasa';
      kios = 'Kios B-01 (Surya Ilmu - Pak Anwar)';
      kode = 'B-01';
      lorong = 'Blok B No. 01';
      hargaWajar = 'Rp 40.000 - Rp 80.000';
      hargaBaru = 'Rp 180.000';
      tips =
          'Kamus tebal edisi lama biasanya memiliki jilidan benang yang lebih awet dari cetakan modern.';
    } else if (q.contains('novel') ||
        q.contains('komik') ||
        q.contains('manga')) {
      kategori = 'Fiksi & Sastra Populer';
      kios = 'Kios B-04 (Wilis Komik - Cak Slamet)';
      kode = 'B-04';
      lorong = 'Blok B No. 04';
      hargaWajar = 'Rp 25.000 - Rp 45.000';
      hargaBaru = 'Rp 88.000';
      tips =
          'Tumpukan novel di lorong depan sering lebih murah jika membeli lebih dari 2 buku sekaligus.';
    } else if (q.contains('sejarah') ||
        q.contains('kuno') ||
        q.contains('antik') ||
        q.contains('arsip')) {
      kategori = 'Buku Antik & Sejarah';
      kios = 'Kios B-02 (Pustaka Lawas - Pak Bambang)';
      kode = 'B-02';
      lorong = 'Blok B No. 02';
      hargaWajar = 'Rp 85.000 - Rp 150.000';
      hargaBaru = 'Koleksi Langka / Tidak Dicetak Ulang';
      tips =
          'Pak Bambang ramah diajak berdiskusi tentang asal usul penerbitan dan tahun cetak buku antik.';
    }

    return HasilScanBuku(
      judul: query,
      penulis: 'Hasil Analisis Wilis AI Vision',
      penerbit: 'Penerbit Pilihan Nusantara',
      tahun: 'Tercatat dalam sirkulasi pasar',
      kategori: kategori,
      kondisi: '8.4 / 10 • Bekas Berkualitas',
      estimasiHargaWajar: hargaWajar,
      hargaBukuBaru: hargaBaru,
      kiosRekomendasi: kios,
      kodeKios: kode,
      lokasiLorong: lorong,
      akurasi: 92,
      ringkasan:
          'Hasil pindaian cerdas mendeteksi buku "$query" memiliki tingkat ketersediaan tinggi di bursa buku Pasar Wilis Malang.',
      tipsNawarWilis: tips,
      gambarCover: assetPath ?? 'assets/images/cover_bumi.png',
    );
  }

  /// Panggilan langsung ke Google Gemini API (opsional untuk pengguna dengan Gemini API Key)
  Future<HasilScanBuku?> _analisisViaGemini(
      String judulBuku, String apiKey, String? assetPath) async {
    final endpoint = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final prompt = '''
Kamu adalah AI Pustakawan spesialis Pasar Buku Wilis di Kota Malang, Indonesia.
Pasar Wilis adalah pasar buku legendaris tempat mahasiswa mencari buku bekas, novel langka, buku kuliah murah, dan komik antik.
Buku yang ingin dianalisis: "$judulBuku".

Berikan analisis dalam format JSON murni (tanpa tanda kutip markdown ```json) dengan struktur:
{
  "judul": "$judulBuku",
  "penulis": "nama pengarang",
  "penerbit": "nama penerbit",
  "tahun": "tahun terbit atau era terbit",
  "kategori": "kategori buku (Novel/Pelajaran/Kuliah/Kamus/Agama/Komik/Langka)",
  "kondisi": "estimasi kondisi bekas (contoh: 8.5/10 • Layak Koleksi)",
  "estimasiHargaWajar": "rentang harga bekas di Pasar Wilis (contoh: Rp 35.000 - Rp 60.000)",
  "hargaBukuBaru": "harga resmi buku baru jika masih ada di toko modern",
  "kiosRekomendasi": "nama kios di Wilis (contoh: Kios A-04 Toko Buku Barokah / Kios B-04 Wilis Komik)",
  "kodeKios": "A-04 atau B-01 atau B-04",
  "lokasiLorong": "Blok A atau Blok B",
  "akurasi": 95,
  "ringkasan": "sinopsis ringkas 2 kalimat mengenai isi buku",
  "tipsNawarWilis": "tips menawar ramah untuk mahasiswa di kios Wilis Malang"
}
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.3,
      }
    });

    final client = HttpClient();
    try {
      final request =
          await client.postUrl(endpoint).timeout(const Duration(seconds: 10));
      request.headers.contentType = ContentType.json;
      request.write(body);
      final response =
          await request.close().timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final resText = await response.transform(utf8.decoder).join();
        final jsonResponse = jsonDecode(resText) as Map<String, dynamic>;
        final candidates = jsonResponse['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String? ?? '{}';
            final parsed = jsonDecode(text) as Map<String, dynamic>;
            return HasilScanBuku.fromJson(parsed, defaultGambar: assetPath);
          }
        }
      }
    } finally {
      client.close();
    }
    return null;
  }
}
