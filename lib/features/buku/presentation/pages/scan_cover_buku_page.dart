
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../main_shell/presentation/pages/main_shell.dart';
import '../../data/services/ai_cover_scanner_service.dart';
import '../../domain/entities/hasil_scan_buku.dart';

/// Halaman Fitur AI: Scan Cover Buku Pasar Wilis
/// Pengunjung dapat memindai cover buku secara visual untuk:
/// 1. Mengidentifikasi judul, penulis, dan cetakan
/// 2. Mengetahui estimasi kondisi fisik dan harga wajar bekas di Wilis
/// 3. Menemukan rekomendasi nomor kios yang menjualnya di Pasar Wilis
class ScanCoverBukuPage extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const ScanCoverBukuPage({super.key, this.onNavigate});

  @override
  State<ScanCoverBukuPage> createState() => _ScanCoverBukuPageState();
}

class _ScanCoverBukuPageState extends State<ScanCoverBukuPage>
    with SingleTickerProviderStateMixin {
  late final AiCoverScannerService _scannerService;
  late final AnimationController _animCtrl;
  late final Animation<double> _animLaser;
  final ImagePicker _imagePicker = ImagePicker();

  String? _customTitle;
  String? _geminiApiKey;
  Uint8List? _fotoCover;

  bool _isScanning = false;
  int _scanStep = 0;
  HasilScanBuku? _hasilScan;

  final TextEditingController _customInputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scannerService = Injection.get<AiCoverScannerService>();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _animLaser = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _customInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _jalankanScan() async {
    if (_isScanning) return;
    if (_fotoCover == null) {
      pesan(context, 'Ambil foto cover terlebih dahulu.');
      return;
    }

    setState(() {
      _isScanning = true;
      _hasilScan = null;
      _scanStep = 1;
    });

    // Step 1: Ekstraksi teks & fitur visual
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _scanStep = 2);

    // Step 2: Analisis kondisi & estimasi pasar Wilis
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    setState(() => _scanStep = 3);

    final hasil = await _scannerService.pindaiCover(
      inputJudul: _customTitle,
      apiKey: _geminiApiKey,
    );

    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _hasilScan = hasil;
    });
  }

  Future<void> _ambilFotoCover() async {
    if (_isScanning) return;

    try {
      final foto = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (foto == null || !mounted) return;

      final bytes = await foto.readAsBytes();
      if (!mounted) return;
      setState(() {
        _fotoCover = bytes;
        _hasilScan = null;
      });
      pesan(context, 'Foto cover berhasil diambil.');
    } on PlatformException catch (error) {
      if (!mounted) return;
      final message = error.code.toLowerCase().contains('permission') ||
              error.code.toLowerCase().contains('denied')
          ? 'Izin kamera ditolak. Izinkan Kamera untuk Pasar Buku Wilis di Setelan HP.'
          : 'Kamera tidak dapat dibuka: ${error.message ?? error.code}';
      pesan(context, message);
    } catch (error) {
      if (!mounted) return;
      pesan(
        context,
        'Gagal membuka kamera. Coba tutup dan buka ulang aplikasi. ($error)',
      );
    }
  }

  void _dialogInputBuku() {
    _customInputCtrl.text = _customTitle ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.edit_note_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Input Judul Bebas', style: sans(17, weight: FontWeight.w700)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan judul buku jika ingin menambahkan konteks pada hasil pindai:',
              style: sans(13, color: AppColors.body),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customInputCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Misal: Hukum Perdata Subekti, Harry Potter...',
                hintStyle: sans(13, color: AppColors.muted),
                filled: true,
                fillColor: AppColors.sky50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.sky200),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: sans(13, color: AppColors.muted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final text = _customInputCtrl.text.trim();
              Navigator.pop(ctx);
              if (text.isNotEmpty) {
                setState(() {
                  _customTitle = text;
                  _hasilScan = null;
                });
                if (_fotoCover != null) {
                  _jalankanScan();
                } else {
                  pesan(context,
                      'Judul disimpan. Ambil foto cover terlebih dahulu.');
                }
              }
            },
            child:
                Text('Pindai Judul', style: sans(13, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _dialogApiKey() {
    final apiKeyCtrl = TextEditingController(text: _geminiApiKey ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.vpn_key_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Pengaturan AI Key', style: sans(17, weight: FontWeight.w700)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplikasi sudah dilengkapi dengan Wilis Offline AI Knowledge Base (berfungsi 100% tanpa internet/API).',
              style: sans(13, color: AppColors.body, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Jika ingin mengaktifkan Google Gemini Live API untuk judul buku apapun secara online, masukkan API Key Anda di bawah ini:',
              style: sans(12.5, color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apiKeyCtrl,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: sans(12, color: AppColors.muted),
                filled: true,
                fillColor: AppColors.sky50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.sky200),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (_geminiApiKey != null)
            TextButton(
              onPressed: () {
                setState(() => _geminiApiKey = null);
                Navigator.pop(ctx);
                pesan(context, 'Kembali ke Wilis Offline AI Engine.');
              },
              child: Text('Reset', style: sans(13, color: Colors.red)),
            ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final val = apiKeyCtrl.text.trim();
              setState(() => _geminiApiKey = val.isEmpty ? null : val);
              Navigator.pop(ctx);
              pesan(
                  context,
                  val.isEmpty
                      ? 'Mode AI Wilis Lokal aktif.'
                      : 'Gemini Live API Key tersimpan!');
            },
            child: Text('Simpan', style: sans(13, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageSoft,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  if (_hasilScan != null) ...[
                    _buildHasilScanCard(_hasilScan!),
                  ] else ...[
                    _buildScannerView(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _dialogInputBuku,
                        icon: const Icon(Icons.edit_note_rounded, size: 18),
                        label: Text(
                          _customTitle ?? 'Isi judul buku (opsional)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildScanAction(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate200)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: AppColors.ink),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Kembali',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Wilis AI Lens',
                        style: serif(18, weight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _geminiApiKey != null
                            ? AppColors.greenSoft
                            : AppColors.sky100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _geminiApiKey != null ? 'GEMINI LIVE' : 'AI SMART',
                        style: sans(9,
                            weight: FontWeight.w800,
                            color: _geminiApiKey != null
                                ? AppColors.green
                                : AppColors.primary),
                      ),
                    ),
                  ],
                ),
                Text(
                  'PINDAI COVER • ESTIMASI HARGA • LOKASI KIOS',
                  style: sans(9.5,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined,
                color: AppColors.primary, size: 22),
            onPressed: _dialogApiKey,
            tooltip: 'Pengaturan API Key Gemini',
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Container(
      height: 310,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Preview foto cover hasil kamera.
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: _fotoCover != null
                    ? Image.memory(
                        _fotoCover!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white54,
                            size: 80),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.menu_book_rounded,
                              color: Colors.white70, size: 64),
                          const SizedBox(height: 12),
                          Text(
                            'Foto cover akan muncul di sini',
                            style: sans(12, color: Colors.white70),
                          ),
                        ],
                      ),
              ),
            ),

            // Frame Viewfinder dengan Garis Sudut Modern
            Positioned.fill(
              child: CustomPaint(
                painter: _ViewfinderPainter(
                  isScanning: _isScanning,
                  color: _isScanning ? AppColors.sky400 : Colors.white70,
                ),
              ),
            ),

            // Animasi Garis Laser Scan
            if (_isScanning)
              AnimatedBuilder(
                animation: _animLaser,
                builder: (context, _) => Positioned(
                  top: 310 * _animLaser.value,
                  left: 36,
                  right: 36,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.sky400,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sky400.withValues(alpha: 0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Badge Status di Atas
            Positioned(
              top: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _isScanning ? AppColors.sky400 : Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isScanning
                            ? AppColors.sky400
                            : const Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isScanning
                          ? (_scanStep == 1
                              ? 'Mengekstrak Visual Cover...'
                              : _scanStep == 2
                                  ? 'Menganalisis Kondisi & Edisi...'
                                  : 'Mencari Kios di Pasar Wilis...')
                          : (_customTitle != null
                              ? 'Target: $_customTitle'
                              : _fotoCover != null
                                  ? 'Foto cover siap ditinjau'
                                  : 'Siap mengambil foto cover'),
                      style: sans(11.5,
                          weight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // Hint di Bawah
            Positioned(
              bottom: 12,
              child: Text(
                'Ambil foto cover buku dengan kamera HP',
                style: sans(10.5, color: Colors.white60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanAction() {
    return PrimaryButton(
      text: _isScanning
          ? 'Sedang Memindai dengan AI...'
          : _fotoCover == null
              ? 'Ambil Foto Cover Buku'
              : 'Mulai Pindai Cover Buku',
      icon: _isScanning
          ? null
          : _fotoCover == null
              ? Icons.camera_alt_rounded
              : Icons.document_scanner_rounded,
      onPressed: _isScanning
          ? null
          : _fotoCover == null
              ? _ambilFotoCover
              : _jalankanScan,
    );
  }

  Widget _buildHasilScanCard(HasilScanBuku b) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.sky200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Status Akurasi AI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.sky50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
              border: Border(bottom: BorderSide(color: AppColors.sky200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Identifikasi AI Terverifikasi',
                    style: sans(13,
                        weight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                ),
                Pill('Akurasi ${b.akurasi}%',
                    background: AppColors.greenSoft,
                    foreground: AppColors.green),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_fotoCover != null) ...[
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        _fotoCover!,
                        height: 190,
                        width: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Judul & Penulis
                Text(b.judul,
                    style: serif(20, weight: FontWeight.w700, height: 1.25)),
                const SizedBox(height: 4),
                Text('Karya ${b.penulis}',
                    style: sans(14,
                        weight: FontWeight.w600, color: AppColors.primaryDark)),
                const SizedBox(height: 6),
                Text('${b.penerbit} • ${b.tahun}',
                    style: sans(12, color: AppColors.muted)),

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.slate200),
                const SizedBox(height: 16),

                // Box Rekomendasi Kios Wilis
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.sky50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.sky200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'TERSEDIA DI KIOS WILIS',
                            style: sans(11,
                                weight: FontWeight.w800,
                                color: AppColors.primaryDark,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        b.kiosRekomendasi,
                        style: sans(15,
                            weight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lokasi: ${b.lokasiLorong}',
                        style: sans(12.5, color: AppColors.muted),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onNavigate?.call(NavTab.denah);
                          },
                          icon: const Icon(Icons.map_outlined, size: 16),
                          label: Text('Lihat Kios di Denah Pasar',
                              style: sans(12, weight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Grid Info Cepat: Kategori & Kondisi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _infoChip(
                        icon: Icons.category_outlined,
                        label: 'KATEGORI',
                        value: b.kategori,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoChip(
                        icon: Icons.auto_awesome_outlined,
                        label: 'KONDISI FISIK',
                        value: b.kondisi,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Box Estimasi Harga Wilis
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ESTIMASI HARGA BEKAS WILIS',
                            style: sans(11,
                                weight: FontWeight.w800,
                                color: const Color(0xFF166534),
                                letterSpacing: 0.5),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Harga Wajar',
                              style: sans(10.5,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFF15803D)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        b.estimasiHargaWajar,
                        style: sans(20,
                            weight: FontWeight.w800,
                            color: const Color(0xFF15803D)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Harga Resmi Buku Baru: ${b.hargaBukuBaru}',
                        style: sans(11.5, color: const Color(0xFF166534)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.tips_and_updates,
                              size: 15, color: Color(0xFF15803D)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              b.tipsNawarWilis,
                              style: sans(11.5,
                                  color: const Color(0xFF14532D), height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Ringkasan Buku AI
                Text('Ringkasan Cepat Buku (AI Blurb):',
                    style: sans(12.5,
                        weight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text(
                  b.ringkasan,
                  style: sans(13, color: AppColors.body, height: 1.45),
                ),

                const SizedBox(height: 20),

                // Tombol Aksi Bawah
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          setState(() => _hasilScan = null);
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text('Pindai Ulang',
                            style: sans(13, weight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // Kembalikan judul buku ke halaman pemanggil (Beranda) untuk pencarian
                          Navigator.pop(context, b.judul);
                        },
                        icon: const Icon(Icons.search, size: 16),
                        label: Text('Cari di Beranda',
                            style: sans(13, weight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(
      {required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(label,
                  style: sans(10,
                      weight: FontWeight.w800,
                      color: AppColors.muted,
                      letterSpacing: 0.4)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: sans(12.5, weight: FontWeight.w700, color: AppColors.ink),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Custom Painter untuk sudut-sudut kotak pemindaian kamera (Viewfinder Frame)
class _ViewfinderPainter extends CustomPainter {
  final bool isScanning;
  final Color color;

  _ViewfinderPainter({required this.isScanning, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;
    const margin = 26.0;

    final left = margin;
    final top = margin;
    final right = size.width - margin;
    final bottom = size.height - margin;

    // Kiri Atas
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), paint);

    // Kanan Atas
    canvas.drawLine(
        Offset(right - cornerLength, top), Offset(right, top), paint);
    canvas.drawLine(
        Offset(right, top), Offset(right, top + cornerLength), paint);

    // Kiri Bawah
    canvas.drawLine(
        Offset(left, bottom - cornerLength), Offset(left, bottom), paint);
    canvas.drawLine(
        Offset(left, bottom), Offset(left + cornerLength, bottom), paint);

    // Kanan Bawah
    canvas.drawLine(
        Offset(right - cornerLength, bottom), Offset(right, bottom), paint);
    canvas.drawLine(
        Offset(right, bottom), Offset(right, bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) =>
      oldDelegate.isScanning != isScanning || oldDelegate.color != color;
}
