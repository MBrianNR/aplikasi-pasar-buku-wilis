class BukuTemuan {
  final String gambar;
  final String? gambarUrl;
  final String info;
  final String judul;
  final String penulis;
  final String harga;
  final String kios;
  final String kategori;
  final String penerbit;
  final String tahunTerbit;
  final String jumlahHalaman;
  final String kondisi;
  final String rating;
  final String jumlahUlasan;
  final String jumlahTerjual;
  final String namaToko;
  final String pemilikToko;
  final String lokasiToko;
  final String jamBuka;
  final String ringkasan;
  final String catatanToko;
  final String fotoPenjual;
  final List<String> galeri;

  const BukuTemuan({
    required this.gambar,
    this.gambarUrl,
    required this.info,
    required this.judul,
    required this.penulis,
    required this.harga,
    required this.kios,
    this.kategori = 'Novel & Sastra Klasik',
    this.penerbit = 'Penerbit tidak dicantumkan',
    this.tahunTerbit = 'Tidak diketahui',
    this.jumlahHalaman = 'Belum dicantumkan',
    this.kondisi = 'Bekas - kondisi baik',
    this.rating = '4.9',
    this.jumlahUlasan = '48',
    this.jumlahTerjual = '120+ Terjual di Wilis',
    this.namaToko = 'Toko Buku Barokah',
    this.pemilikToko = 'H. Ridwan (Pedagang Generasi Pertama)',
    this.lokasiToko = 'Kios Blok A-04',
    this.jamBuka = '08.30 - 18.00',
    this.ringkasan =
        'Buku koleksi Pasar Buku Wilis. Periksa kondisi fisik dan kelengkapan halaman saat berkunjung.',
    this.catatanToko =
        'Silakan tanyakan ketersediaan dan kondisi buku langsung kepada penjual.',
    this.fotoPenjual = 'assets/images/avatar_bambang.png',
    this.galeri = const [],
  });
}
