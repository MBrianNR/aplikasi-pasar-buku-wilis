import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/buku.dart';
import '../../domain/entities/buku_temuan.dart';
import '../../domain/entities/kategori.dart';
import '../viewmodels/stok_kategori_viewmodel.dart';
import '../widgets/buku_cover.dart';
import 'detail_buku_page.dart';

/// Daftar buku pada satu kartu kategori, diambil dari backend (GET /buku).
class KategoriDetailPage extends StatefulWidget {
  final KategoriTematik kategori;
  const KategoriDetailPage({super.key, required this.kategori});

  @override
  State<KategoriDetailPage> createState() => _KategoriDetailPageState();
}

class _KategoriDetailPageState extends State<KategoriDetailPage> {
  static const _menipis = 5;
  late final StokKategoriViewModel _stokVm;

  @override
  void initState() {
    super.initState();
    _stokVm = Injection.get<StokKategoriViewModel>();
    _stokVm.mulaiPantau();
  }

  @override
  void dispose() {
    _stokVm.berhenti();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kategori;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(k.nama, style: serif(20)),
      ),
      body: ListenableBuilder(
          listenable: _stokVm, builder: (context, _) => _isi(k)),
    );
  }

  Widget _isi(KategoriTematik k) {
    final stok = _stokVm;

    if (!stok.termuat) {
      if (stok.error == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 44, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(stok.error!,
                textAlign: TextAlign.center,
                style: sans(13, color: AppColors.body)),
            const SizedBox(height: 16),
            FilledButton(onPressed: stok.muat, child: const Text('Coba lagi')),
          ]),
        ),
      );
    }

    final buku = stok.bukuUntuk(k.kategoriApi);
    final eksemplar = buku.fold<int>(0, (s, b) => s + b.jumlah);

    return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(k.deskripsi,
              style: sans(12.5, color: AppColors.muted, height: 1.4)),
          const SizedBox(height: 10),
          Row(children: [
            Pill('${buku.length} judul • ${formatRibuan(eksemplar)} eks',
                fontSize: 10.5, letterSpacing: 0),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                k.lorong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sans(11.5,
                    weight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text('Kategori di web admin: ${k.kategoriApi.join(', ')}',
              style: sans(11.5, color: AppColors.muted)),
          const SizedBox(height: 14),
          if (buku.isEmpty)
            SoftCard(
              child: Text(
                'Belum ada buku di kategori ini. Tambahkan lewat web admin, halaman ini akan terisi sendiri.',
                style: sans(13, color: AppColors.body),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: buku.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 370,
              ),
              itemBuilder: (context, index) =>
                  _kartuBukuGrid(buku[index], buku),
            ),
        ]);
  }

  Widget _kartuBukuGrid(Buku b, List<Buku> daftarBuku) {
    final tipis = b.jumlah < _menipis;
    final detailBuku = _ubahKeBukuTemuan(b);
    final rekomendasi = daftarBuku
        .where((item) => item.judul != b.judul)
        .map(_ubahKeBukuTemuan)
        .toList();

    return Material(
      color: const Color(0xFFF1F9FE),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.sky200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => DetailBukuPage(
            buku: detailBuku,
            rekomendasi: rekomendasi,
          ),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: SizedBox(
                width: double.infinity,
                child: BukuCover(
                  source: b.coverUrl ?? _gambarUntukKategori(b.kategori),
                  fallbackAsset: _gambarUntukKategori(b.kategori),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: sans(13,
                          weight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b.penulis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(11.5, color: AppColors.muted),
                    ),
                    const Spacer(),
                    Text(
                      b.harga > 0
                          ? 'Rp ${formatRibuan(b.harga)}'
                          : 'Tanya harga di kios',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(11.5,
                          weight: FontWeight.w700, color: AppColors.primary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${b.jumlah} eks. tersedia${tipis ? ' • Stok menipis' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(10.5,
                          weight: tipis ? FontWeight.w700 : FontWeight.w500,
                          color:
                              tipis ? Colors.orange.shade800 : AppColors.muted),
                    ),
                    if (b.pemasok.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        b.pemasok,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sans(10, color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuBuku(Buku b, List<Buku> daftarBuku) {
    final tipis = b.jumlah < _menipis;
    final warnaTipis = Colors.orange.shade800;
    final detailBuku = _ubahKeBukuTemuan(b);
    final rekomendasi = daftarBuku
        .where((item) => item.judul != b.judul)
        .map(_ubahKeBukuTemuan)
        .toList();
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => DetailBukuPage(
          buku: detailBuku,
          rekomendasi: rekomendasi,
        ),
      )),
      child: SoftCard(
        radius: 16,
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 58,
              height: 78,
              child: BukuCover(
                source: b.coverUrl ?? _gambarUntukKategori(b.kategori),
                fallbackAsset: _gambarUntukKategori(b.kategori),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.judul,
                  style: sans(14.5,
                      weight: FontWeight.w700, color: AppColors.ink)),
              const SizedBox(height: 2),
              Text(b.penulis, style: sans(12.5, color: AppColors.muted)),
              const SizedBox(height: 6),
              Text(
                [b.tanggal, if (b.pemasok.isNotEmpty) b.pemasok].join(' • '),
                style: sans(11.5, color: AppColors.muted),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${b.jumlah} eks.',
              style: sans(13,
                  weight: FontWeight.w800,
                  color: tipis ? warnaTipis : AppColors.ink),
            ),
            const SizedBox(height: 2),
            Text(
                b.harga > 0
                    ? 'Rp ${formatRibuan(b.harga)}'
                    : 'Tanya harga di kios',
                style: sans(12, color: AppColors.body)),
            if (tipis)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Stok menipis',
                    style:
                        sans(10.5, weight: FontWeight.w600, color: warnaTipis)),
              ),
          ]),
        ]),
      ),
    );
  }

  BukuTemuan _ubahKeBukuTemuan(Buku b) => BukuTemuan(
        gambar: _gambarUntukKategori(b.kategori),
        gambarUrl: b.coverUrl,
        info: b.tanggal.isEmpty ? 'Stok ${b.jumlah} tersedia' : b.tanggal,
        judul: b.judul,
        penulis: b.penulis,
        harga:
            b.harga > 0 ? 'Rp ${formatRibuan(b.harga)}' : 'Tanya harga di kios',
        kios: b.pemasok.isEmpty ? 'Pasar Buku Wilis' : b.pemasok,
        kategori: b.kategori,
        penerbit: b.pemasok.isEmpty ? 'Tidak dicantumkan' : b.pemasok,
        tahunTerbit: b.tanggal.isEmpty ? 'Belum dicantumkan' : b.tanggal,
        jumlahHalaman: 'Belum dicantumkan',
        kondisi: tipisLabel(b.jumlah),
        jumlahTerjual: '${b.jumlah} tersedia di Wilis',
        ringkasan:
            '${b.judul} karya ${b.penulis}. Stok tercatat ${b.jumlah} eksemplar di Pasar Buku Wilis.',
      );

  String tipisLabel(int jumlah) => jumlah < _menipis
      ? 'Stok menipis - $jumlah eksemplar'
      : 'Stok tersedia - $jumlah eksemplar';

  String _gambarUntukKategori(String kategori) {
    final nilai = kategori.toLowerCase();
    if (nilai.contains('agama') || nilai.contains('tafsir')) {
      return 'assets/images/buku_tafsir.png';
    }
    if (nilai.contains('novel') || nilai.contains('sastra')) {
      return 'assets/images/buku_bumi_manusia.png';
    }
    if (nilai.contains('komik')) return 'assets/images/kategori_5.png';
    return 'assets/images/kategori_3.png';
  }
}
