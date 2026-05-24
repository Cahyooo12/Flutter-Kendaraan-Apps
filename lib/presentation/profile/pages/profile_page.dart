import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/data/local/auth_local_datasource.dart';
import 'package:flutter_kendaraanku_app/presentation/auth/pages/login_page.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_state.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/about_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/backup_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/edit_profile_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/help_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/language_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/privacy_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/security_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/terms_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/theme_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authDatasource = AuthLocalDatasource();
    final name = await authDatasource.getUserName();
    final email = await authDatasource.getUserEmail();
    if (mounted) {
      setState(() {
        _userName = name ?? 'Pengguna';
        _userEmail = email ?? '-';
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroHeader(),
              _buildProfileCard(),
              const SizedBox(height: 18),
              _buildSettingsGroup('AKUN', _accountRows()),
              _buildSettingsGroup('PREFERENSI', _preferenceRows()),
              _buildSettingsGroup('LAINNYA', _otherRows()),
              _buildLogoutButton(),
              _buildVersionText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A7BF7), Color(0xFF6B95FA)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -60,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
              child: Center(
                child: Text(
                  'Profil Saya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final vehicleState = context.watch<VehicleBloc>().state;
    final vehicleCount =
        vehicleState is VehicleLoaded ? vehicleState.vehicles.length : 0;
    final currentYear = DateTime.now().year;

    return Transform.translate(
      offset: const Offset(0, -42),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  children: [
                    // Avatar + info
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: AppColors.surface, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(_userName),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryStrong,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userEmail,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.tintAmberBg,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star,
                                        size: 12,
                                        color: AppColors.tintAmberFg),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Member Sejak $currentYear',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.tintAmberFg,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Stats
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.only(top: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.divider, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildStat('$vehicleCount', 'Kendaraan'),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<_SettingsRow> rows) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 0.44,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: List.generate(rows.length, (index) {
                  final row = rows[index];
                  final isLast = index == rows.length - 1;
                  return Column(
                    children: [
                      _buildSettingsRowWidget(row),
                      if (!isLast)
                        const Padding(
                          padding: EdgeInsets.only(left: 60),
                          child:
                              Divider(height: 1, color: AppColors.divider),
                        ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRowWidget(_SettingsRow row) {
    return GestureDetector(
      onTap: row.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: row.tintBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(row.icon, size: 18, color: row.tintFg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  if (row.subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      row.subtitle!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textSoft),
          ],
        ),
      ),
    );
  }

  List<_SettingsRow> _accountRows() {
    return [
      _SettingsRow(
        tintBg: AppColors.tintBlueBg,
        tintFg: AppColors.tintBlueFg,
        icon: Icons.person_outline,
        title: 'Informasi Pribadi',
        subtitle: 'Nama, email, telepon',
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfilePage(
                currentName: _userName,
                currentEmail: _userEmail,
              ),
            ),
          );
          if (result == true) {
            _loadUserData();
          }
        },
      ),
      _SettingsRow(
        tintBg: AppColors.tintMintBg,
        tintFg: AppColors.tintMintFg,
        icon: Icons.shield_outlined,
        title: 'Keamanan',
        subtitle: 'Kata sandi & tips keamanan',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SecurityPage()),
        ),
      ),
    ];
  }

  List<_SettingsRow> _preferenceRows() {
    return [
      _SettingsRow(
        tintBg: AppColors.tintLavenderBg,
        tintFg: AppColors.tintLavenderFg,
        icon: Icons.palette_outlined,
        title: 'Tema Warna',
        subtitle: 'Terang, Gelap, atau ikuti sistem',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ThemePage()),
        ),
      ),
      _SettingsRow(
        tintBg: AppColors.tintAmberBg,
        tintFg: AppColors.tintAmberFg,
        icon: Icons.language,
        title: 'Bahasa',
        subtitle: 'Indonesia',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LanguagePage()),
        ),
      ),
      _SettingsRow(
        tintBg: AppColors.tintBlueBg,
        tintFg: AppColors.tintBlueFg,
        icon: Icons.cloud_outlined,
        title: 'Backup Database',
        subtitle: 'Kelola backup & restore',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BackupPage()),
        ),
      ),
    ];
  }

  List<_SettingsRow> _otherRows() {
    return [
      _SettingsRow(
        tintBg: AppColors.tintMintBg,
        tintFg: AppColors.tintMintFg,
        icon: Icons.help_outline,
        title: 'Bantuan & FAQ',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpPage()),
        ),
      ),
      _SettingsRow(
        tintBg: AppColors.tintLavenderBg,
        tintFg: AppColors.tintLavenderFg,
        icon: Icons.gavel_rounded,
        title: 'Syarat & Ketentuan',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TermsPage()),
        ),
      ),
      _SettingsRow(
        tintBg: AppColors.tintBlueBg,
        tintFg: AppColors.tintBlueFg,
        icon: Icons.privacy_tip_outlined,
        title: 'Kebijakan Privasi',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrivacyPage()),
        ),
      ),
      _SettingsRow(
        tintBg: AppColors.tintPeachBg,
        tintFg: AppColors.tintPeachFg,
        icon: Icons.star_outline,
        title: 'Beri Rating',
        onTap: () => _showRatingDialog(),
      ),
      _SettingsRow(
        tintBg: AppColors.tintAmberBg,
        tintFg: AppColors.tintAmberFg,
        icon: Icons.info_outline,
        title: 'Tentang Aplikasi',
        subtitle: 'Versi 1.0.0',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutPage()),
        ),
      ),
    ];
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Beri Rating',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => const Icon(Icons.star,
                    color: AppColors.tintAmberFg, size: 36),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Terima kasih telah menggunakan Kendaraanku!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tutup',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: GestureDetector(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(
                  'Keluar',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                content: Text(
                  'Apakah Anda yakin ingin keluar?',
                  style: GoogleFonts.plusJakartaSans(),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      'Keluar',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
            if (confirm == true && mounted) {
              await AuthLocalDatasource().clearSession();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Keluar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionText() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Center(
          child: Text(
            'Kendaraanku v1.0.0',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textSoft,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsRow {
  final Color tintBg;
  final Color tintFg;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  _SettingsRow({
    required this.tintBg,
    required this.tintFg,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
}
