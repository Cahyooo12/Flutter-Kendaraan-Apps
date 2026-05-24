import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/privacy_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/terms_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.text,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tentang Aplikasi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHero(),
          const SizedBox(height: 18),
          _sectionHeader('Fitur Utama'),
          const SizedBox(height: 10),
          ..._features.map(_featureRow),
          const SizedBox(height: 18),
          _sectionHeader('Teknologi'),
          const SizedBox(height: 10),
          _buildTechCard(),
          const SizedBox(height: 18),
          _sectionHeader('Legal'),
          const SizedBox(height: 10),
          _buildLegalRow(
            context,
            icon: Icons.gavel_rounded,
            label: 'Syarat & Ketentuan',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsPage()),
            ),
          ),
          const SizedBox(height: 8),
          _buildLegalRow(
            context,
            icon: Icons.shield_outlined,
            label: 'Kebijakan Privasi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPage()),
            ),
          ),
          const SizedBox(height: 22),
          _buildCopyright(),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Kendaraanku',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Versi 1.0.0 · Build 1',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Aplikasi pencatatan kendaraan pribadi yang sederhana, '
            'lengkap, dan 100% offline.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.44,
      ),
    );
  }

  Widget _featureRow(_Feature f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: f.tintBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(f.icon, size: 18, color: f.tintFg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    f.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: const [
          _TechChip('Flutter 3.x'),
          _TechChip('BLoC'),
          _TechChip('SQLite'),
          _TechChip('Google ML Kit'),
          _TechChip('fl_chart'),
          _TechChip('PDF Export'),
          _TechChip('Plus Jakarta Sans'),
        ],
      ),
    );
  }

  Widget _buildLegalRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textSoft),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Column(
      children: [
        Text(
          '© 2026 Kendaraanku',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Demo SharingSession JagoFlutter Free Event',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textSoft,
          ),
        ),
      ],
    );
  }

  static const List<_Feature> _features = [
    _Feature(
      icon: Icons.directions_car_rounded,
      tintBg: AppColors.tintBlueBg,
      tintFg: AppColors.tintBlueFg,
      title: 'Multi Kendaraan',
      subtitle: 'Catat berbagai motor & mobil',
    ),
    _Feature(
      icon: Icons.local_gas_station_rounded,
      tintBg: AppColors.tintPeachBg,
      tintFg: AppColors.tintPeachFg,
      title: 'Pencatatan BBM',
      subtitle: 'Track konsumsi & biaya bulanan',
    ),
    _Feature(
      icon: Icons.build_rounded,
      tintBg: AppColors.tintMintBg,
      tintFg: AppColors.tintMintFg,
      title: 'Riwayat Servis',
      subtitle: 'Catatan perawatan & pengingat',
    ),
    _Feature(
      icon: Icons.folder_open_rounded,
      tintBg: AppColors.tintAmberBg,
      tintFg: AppColors.tintAmberFg,
      title: 'Dokumen Kendaraan',
      subtitle: 'STNK, BPKB, SIM, Asuransi, Pajak',
    ),
    _Feature(
      icon: Icons.document_scanner_rounded,
      tintBg: AppColors.tintLavenderBg,
      tintFg: AppColors.tintLavenderFg,
      title: 'Scan Nota OCR',
      subtitle: 'Auto-isi form dari foto nota',
    ),
    _Feature(
      icon: Icons.insert_chart_rounded,
      tintBg: AppColors.tintRoseBg,
      tintFg: AppColors.tintRoseFg,
      title: 'Laporan & Ekspor',
      subtitle: 'PDF & CSV untuk dokumentasi',
    ),
  ];
}

class _Feature {
  final IconData icon;
  final Color tintBg;
  final Color tintFg;
  final String title;
  final String subtitle;
  const _Feature({
    required this.icon,
    required this.tintBg,
    required this.tintFg,
    required this.title,
    required this.subtitle,
  });
}

class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
