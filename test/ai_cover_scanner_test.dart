import 'package:flutter_test/flutter_test.dart';
import 'package:wilis_mobile/features/buku/data/services/ai_cover_scanner_service.dart';

void main() {
  group('AiCoverScannerService Unit Tests', () {
    late AiCoverScannerService service;

    setUp(() {
      service = AiCoverScannerService();
    });

    test('Pindai cover Bumi Manusia mengembalikan data akurat Kios Wilis', () async {
      final hasil = await service.pindaiCover(
        assetPath: 'assets/images/cover_bumi.png',
      );

      expect(hasil.judul.contains('Bumi Manusia'), true);
      expect(hasil.penulis.contains('Pramoedya Ananta Toer'), true);
      expect(hasil.kodeKios, 'A-04');
      expect(hasil.kiosRekomendasi.contains('Toko Buku Barokah'), true);
      expect(hasil.akurasi >= 95, true);
    });

    test('Pindai cover Babad Tanah Djawi mengembalikan Kios A-02 Pustaka Kuno', () async {
      final hasil = await service.pindaiCover(
        assetPath: 'assets/images/cover_babad.png',
      );

      expect(hasil.judul.contains('Babad Tanah Djawi'), true);
      expect(hasil.kodeKios, 'A-02');
      expect(hasil.kiosRekomendasi.contains('Pustaka Kuno'), true);
    });

    test('Pindai judul buku hukum bebas mengarahkan ke Kios A-01 Toko Surya', () async {
      final hasil = await service.pindaiCover(
        inputJudul: 'Pengantar Hukum Perdata Indonesia',
      );

      expect(hasil.kategori.contains('Hukum'), true);
      expect(hasil.kodeKios, 'A-01');
      expect(hasil.kiosRekomendasi.contains('Toko Surya'), true);
    });
  });
}
