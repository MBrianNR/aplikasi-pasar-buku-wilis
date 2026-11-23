class HasilScanBuku {
  final String judul;
  final String penulis;
  final String penerbit;
  final String tahun;
  final String kategori;
  final String kondisi;
  final String estimasiHargaWajar;
  final String hargaBukuBaru;
  final String kiosRekomendasi;
  final String kodeKios;
  final String lokasiLorong;
  final int akurasi;
  final String ringkasan;
  final String tipsNawarWilis;
  final String? gambarCover;

  const HasilScanBuku({
    required this.judul,
    required this.penulis,
    required this.penerbit,
    required this.tahun,
    required this.kategori,
    required this.kondisi,
    required this.estimasiHargaWajar,
    required this.hargaBukuBaru,
    required this.kiosRekomendasi,
    required this.kodeKios,
    required this.lokasiLorong,
    required this.akurasi,
    required this.ringkasan,
    required this.tipsNawarWilis,
    this.gambarCover,
  });

  factory HasilScanBuku.fromJson(Map<String, dynamic> json, {String? defaultGambar}) {
    return HasilScanBuku(
      judul: json['judul'] as String? ?? 'Buku Tanpa Judul',
      penulis: json['penulis'] as String? ?? 'Penulis Tidak Diketahui',
      penerbit: json['penerbit'] as String? ?? 'Penerbit Umum',
      tahun: json['tahun'] as String? ?? 'Tahun tidak tercatat',
      kategori: json['kategori'] as String? ?? 'Umum',
      kondisi: json['kondisi'] as String? ?? '8.0/10 • Layak Baca',
      estimasiHargaWajar: json['estimasiHargaWajar'] as String? ?? 'Rp 35.000 - Rp 60.000',
      hargaBukuBaru: json['hargaBukuBaru'] as String? ?? 'Rp 95.000',
      kiosRekomendasi: json['kiosRekomendasi'] as String? ?? 'Kios A-04 (Toko Buku Barokah)',
      kodeKios: json['kodeKios'] as String? ?? 'A-04',
      lokasiLorong: json['lokasiLorong'] as String? ?? 'Blok A Lorong Utama',
      akurasi: json['akurasi'] as int? ?? 94,
      ringkasan: json['ringkasan'] as String? ?? 'Buku terdaftar dalam sirkulasi Pasar Buku Wilis Malang.',
      tipsNawarWilis: json['tipsNawarWilis'] as String? ?? 'Tawar secara ramah dengan patokan 20-30% di bawah harga buka kios.',
      gambarCover: json['gambarCover'] as String? ?? defaultGambar,
    );
  }
}
