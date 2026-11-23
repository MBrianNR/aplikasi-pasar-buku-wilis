import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../kios/presentation/pages/denah_page.dart';
import '../../domain/entities/buku_temuan.dart';
import '../widgets/buku_cover.dart';

class DetailBukuPage extends StatefulWidget {
  final BukuTemuan buku;
  final List<BukuTemuan> rekomendasi;

  const DetailBukuPage({
    super.key,
    required this.buku,
    this.rekomendasi = const [],
  });

  @override
  State<DetailBukuPage> createState() => _DetailBukuPageState();
}

class _DetailBukuPageState extends State<DetailBukuPage> {
  bool _disimpan = false;
  int _fotoTerpilih = 0;

  List<String> get _galeri =>
      widget.buku.galeri.isEmpty
          ? [widget.buku.gambarUrl ?? widget.buku.gambar]
          : widget.buku.galeri;

  @override
  Widget build(BuildContext context) {
    final buku = widget.buku;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text('Detail Buku', style: sans(16, weight: FontWeight.w700)),
            Text(buku.kategori, style: sans(11, color: AppColors.muted)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _disimpan ? 'Hapus dari tersimpan' : 'Simpan buku',
            onPressed: () => setState(() => _disimpan = !_disimpan),
            icon: Icon(_disimpan ? Icons.bookmark : Icons.bookmark_border),
          ),
          IconButton(
            tooltip: 'Salin detail buku',
            onPressed: _bagikan,
            icon: const Icon(Icons.share_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _buildGaleri(),
                const SizedBox(height: 16),
                _buildInformasiBuku(),
                const SizedBox(height: 16),
                _buildToko(),
                const SizedBox(height: 16),
                _buildRingkasan(),
                const SizedBox(height: 16),
                _buildSpesifikasi(),
                if (widget.rekomendasi.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _buildRekomendasi(),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: _chatPenjual,
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Chat Penjual'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaleri() {
    final photos = _galeri;
    return _card(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 250,
              width: double.infinity,
              color: AppColors.sky50,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: BukuCover(
                      source: photos[_fotoTerpilih],
                      fallbackAsset: widget.buku.gambar,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child:
                        _badge('${_fotoTerpilih + 1} / ${photos.length} Foto'),
                  ),
                ],
              ),
            ),
          ),
          if (photos.length > 1) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 62,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => setState(() => _fotoTerpilih = index),
                  child: Container(
                    width: 62,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: index == _fotoTerpilih
                            ? AppColors.primary
                            : AppColors.slate200,
                        width: index == _fotoTerpilih ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: BukuCover(
                        source: photos[index],
                        fallbackAsset: widget.buku.gambar,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInformasiBuku() {
    final buku = widget.buku;
    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(buku.kategori.toUpperCase(),
              style:
                  sans(11, weight: FontWeight.w800, color: AppColors.primary)),
          const SizedBox(height: 5),
          Text(buku.judul,
              style: serif(19, weight: FontWeight.w700, height: 1.25)),
          const SizedBox(height: 4),
          Text(buku.penulis, style: sans(13, color: AppColors.body)),
          const SizedBox(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              const Icon(Icons.star_rounded,
                  size: 17, color: Color(0xFFF59E0B)),
              Text(buku.rating,
                  style: sans(12,
                      weight: FontWeight.w700, color: const Color(0xFFB45309))),
              Text('•', style: sans(12, color: AppColors.border)),
              Text('${buku.jumlahUlasan} Ulasan Pembaca',
                  style: sans(11.5, color: AppColors.body)),
              Text('•', style: sans(12, color: AppColors.border)),
              Text(buku.jumlahTerjual,
                  style: sans(11.5,
                      weight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
          const Divider(height: 22),
          Text('Harga Pasar Kios Wilis',
              style: sans(11.5, color: AppColors.body)),
          const SizedBox(height: 2),
          Text(buku.harga,
              style:
                  sans(23, weight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildToko() {
    final buku = widget.buku;
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  buku.fotoPenjual,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => CircleAvatar(
                    backgroundColor: AppColors.sky100,
                    child: Text(
                        buku.namaToko.isEmpty
                            ? '?'
                            : buku.namaToko.substring(0, 1),
                        style: sans(18,
                            weight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(buku.namaToko,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: sans(14, weight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified,
                            size: 16, color: AppColors.primary),
                      ],
                    ),
                    Text(buku.pemilikToko,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sans(11.5, color: AppColors.body)),
                    Text(buku.lokasiToko,
                        style: sans(11.5, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppColors.green),
              const SizedBox(width: 7),
              Expanded(
                child: Text('Buka hari ini (${buku.jamBuka} WIB)',
                    style: sans(12, color: AppColors.body)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: _kunjungiKios,
              icon: const Icon(Icons.explore_outlined, size: 17),
              label: Text('Kunjungi ${buku.kios}',
                  style: sans(12.5, weight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasan() => _card(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.description_outlined,
                  size: 19, color: AppColors.primary),
              const SizedBox(width: 7),
              Text('Ringkasan & Kondisi Buku',
                  style: sans(15, weight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            Text(widget.buku.ringkasan,
                style: sans(13, color: AppColors.body, height: 1.55)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catatan Khusus ${widget.buku.namaToko}',
                      style: sans(11.5,
                          weight: FontWeight.w700,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 4),
                  Text(widget.buku.catatanToko,
                      style: sans(11.5, color: AppColors.body, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildSpesifikasi() => _card(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.fact_check_outlined,
                  size: 19, color: AppColors.primary),
              const SizedBox(width: 7),
              Text('Spesifikasi Lengkap',
                  style: sans(15, weight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            _spec('Penulis', widget.buku.penulis),
            _spec('Penerbit', widget.buku.penerbit),
            _spec('Tahun Terbit', widget.buku.tahunTerbit),
            _spec('Jumlah Halaman', widget.buku.jumlahHalaman),
            _spec('Kondisi Fisik', widget.buku.kondisi,
                color: AppColors.primary),
            _spec('Kategori', widget.buku.kategori,
                color: AppColors.primary, last: true),
          ],
        ),
      );

  Widget _buildRekomendasi() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rekomendasi Terkait', style: serif(18)),
                    Text('Koleksi buku lainnya',
                        style: sans(11.5, color: AppColors.muted)),
                  ],
                ),
              ),
              TextButton(
                onPressed: null,
                child: Text('Lihat Semua →',
                    style: sans(11.5,
                        weight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 255,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.rekomendasi.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  _kartuRekomendasi(widget.rekomendasi[index]),
            ),
          ),
        ],
      );

  Widget _kartuRekomendasi(BukuTemuan buku) => GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailBukuPage(
              buku: buku,
              rekomendasi: widget.rekomendasi
                  .where((item) => item.judul != buku.judul)
                  .toList(),
            ),
          ),
        ),
        child: Container(
          width: 158,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.slate200),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 155,
                width: double.infinity,
                child: BukuCover(
                  source: buku.gambarUrl ?? buku.gambar,
                  fallbackAsset: buku.gambar,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(buku.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sans(11.5, weight: FontWeight.w700)),
                    Text(buku.penulis,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sans(10, color: AppColors.muted)),
                    const SizedBox(height: 6),
                    Text(buku.harga,
                        style: sans(12,
                            weight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _spec(String label, String value,
      {Color color = AppColors.ink, bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.slate100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: sans(12, color: AppColors.body))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: sans(12, weight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _card(
          {required Widget child,
          EdgeInsets padding = const EdgeInsets.all(14)}) =>
      Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );

  Widget _badge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.ink.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text, style: sans(10, color: Colors.white)),
      );

  Future<void> _kunjungiKios() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DenahPage(
            initialQuery: widget.buku.kios.replaceFirst('Kios', '').trim(),
          ),
        ),
      );

  void _chatPenjual() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat Penjual', style: serif(19, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(widget.buku.namaToko,
                style: sans(14, weight: FontWeight.w700)),
            Text('${widget.buku.pemilikToko} • ${widget.buku.lokasiToko}',
                style: sans(12, color: AppColors.body)),
            const SizedBox(height: 14),
            Text(
              'Tanyakan ketersediaan buku langsung kepada penjual saat berkunjung ke kios.',
              style: sans(13, color: AppColors.body, height: 1.4),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Lihat Lokasi Kios',
              icon: Icons.map_outlined,
              onPressed: () {
                Navigator.pop(context);
                _kunjungiKios();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bagikan() async {
    await Clipboard.setData(ClipboardData(
      text:
          '${widget.buku.judul} — ${widget.buku.harga} • ${widget.buku.namaToko} (${widget.buku.kios})',
    ));
    if (mounted) pesan(context, 'Detail buku disalin.');
  }
}
