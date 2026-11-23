import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_page.dart';

/// Halaman akun dengan profil dan menu bantuan pengguna.
class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  Future<void> _keluar(BuildContext context) async {
    final authVm = Injection.get<AuthViewModel>();
    await authVm.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _pesanMenu(BuildContext context, String judul) {
    pesan(context, '$judul belum tersedia di aplikasi.');
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData ikon,
    required String judul,
    VoidCallback? onTap,
  }) =>
      SizedBox(
        height: 52,
        child: InkWell(
          onTap: onTap ?? () => _pesanMenu(context, judul),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              Icon(ikon, size: 20, color: AppColors.ink),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  judul,
                  style: sans(14, weight: FontWeight.w700, color: AppColors.ink),
                ),
              ),
            ]),
          ),
        ),
      );

  Widget _pemisah() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Divider(height: 16, color: AppColors.slate200),
      );

  @override
  Widget build(BuildContext context) {
    final authVm = Injection.get<AuthViewModel>();

    return ListenableBuilder(
      listenable: authVm,
      builder: (context, _) {
        final user = authVm.currentUser;
        return Column(children: [
          const WilisHeader(title: 'Akun'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 20, 18),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFD1D5DB),
                      child: const Icon(Icons.person, size: 42, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.nama, style: sans(15, weight: FontWeight.w800, color: AppColors.ink)),
                          if (user.email.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: sans(12.5, color: AppColors.muted),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ]),
                ),
                _menuItem(context, ikon: Icons.favorite_border, judul: 'Wishlist'),
                _menuItem(context, ikon: Icons.person_outline, judul: 'Akun'),
                _menuItem(context, ikon: Icons.star_border, judul: 'Ulasan Produk'),
                _pemisah(),
                _menuItem(context, ikon: Icons.chat_bubble_outline, judul: 'Live Chat'),
                _menuItem(context, ikon: Icons.info_outline, judul: 'Info Berbelanja'),
                _menuItem(context, ikon: Icons.arrow_circle_right_outlined, judul: 'Syarat & Ketentuan'),
                _menuItem(context, ikon: Icons.verified_user_outlined, judul: 'Kebijakan Privasi'),
                _menuItem(context, ikon: Icons.star_outline, judul: 'Beri Rating Aplikasi'),
                _pemisah(),
                _menuItem(context, ikon: Icons.store_outlined, judul: 'Toko Saya'),
                _pemisah(),
                _menuItem(
                  context,
                  ikon: Icons.logout,
                  judul: 'Keluar Akun',
                  onTap: () => _keluar(context),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Text('Versi 1.0.0 (1)', style: sans(12, color: const Color(0xFF94A3B8))),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ]);
      },
    );
  }
}
