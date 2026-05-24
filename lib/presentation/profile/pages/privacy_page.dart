import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
          'Kebijakan Privasi',
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
          _buildHighlightCard(),
          const SizedBox(height: 18),
          _sectionHeader('Detail Penggunaan Data'),
          const SizedBox(height: 10),
          ..._dataSections.map(_buildSection),
          const SizedBox(height: 6),
          _sectionHeader('Izin Aplikasi'),
          const SizedBox(height: 10),
          ..._permissions.map(_buildPermissionRow),
          const SizedBox(height: 18),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privasi Anda Prioritas Kami',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Berlaku efektif 01 Januari 2026',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Kendaraanku dirancang sebagai aplikasi 100% offline. '
            'Tidak ada data Anda yang dikirim ke server eksternal manapun, '
            'termasuk pengembang aplikasi ini.',
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

  Widget _buildHighlightCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _highlightRow(
            icon: Icons.cloud_off_rounded,
            tintBg: AppColors.tintMintBg,
            tintFg: AppColors.tintMintFg,
            title: 'Tidak Ada Server',
            subtitle: 'Semua data tersimpan di perangkat Anda',
          ),
          const Divider(height: 18, color: AppColors.divider),
          _highlightRow(
            icon: Icons.analytics_outlined,
            tintBg: AppColors.tintRoseBg,
            tintFg: AppColors.tintRoseFg,
            title: 'Tanpa Analytics',
            subtitle: 'Tidak ada pelacakan aktivitas pengguna',
          ),
          const Divider(height: 18, color: AppColors.divider),
          _highlightRow(
            icon: Icons.lock_outline_rounded,
            tintBg: AppColors.tintBlueBg,
            tintFg: AppColors.tintBlueFg,
            title: 'Akun Lokal',
            subtitle: 'Email & password disimpan di SQLite lokal',
          ),
        ],
      ),
    );
  }

  Widget _highlightRow({
    required IconData icon,
    required Color tintBg,
    required Color tintFg,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: tintBg,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: tintFg),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildSection(_PrivacySection s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s.body,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.textMuted,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow(_Permission p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                color: p.tintBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(p.icon, size: 18, color: p.tintFg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.purpose,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      height: 1.45,
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySofter,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Versi 1.0 · Terakhir diperbarui 01 Jan 2026',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<_PrivacySection> _dataSections = [
    _PrivacySection(
      title: 'Data yang Disimpan',
      body:
          'Aplikasi menyimpan: data kendaraan, catatan pengisian BBM, riwayat servis, dokumen kendaraan (STNK/BPKB/SIM/Asuransi/Pajak), foto nota & dokumen, serta data akun (nama, email, password). Semuanya disimpan di database SQLite lokal di perangkat Anda.',
    ),
    _PrivacySection(
      title: 'Pemindaian Nota (OCR)',
      body:
          'Fitur scan nota menggunakan Google ML Kit Text Recognition yang berjalan sepenuhnya offline di perangkat. Gambar nota tidak dikirim ke layanan cloud. Hasil teks hanya digunakan untuk mengisi form otomatis.',
    ),
    _PrivacySection(
      title: 'Penyimpanan Foto',
      body:
          'Foto kendaraan, nota, dan dokumen yang Anda ambil disimpan di direktori aplikasi pada penyimpanan internal perangkat. Foto akan ikut terhapus jika aplikasi di-uninstall, jadi pastikan backup terlebih dahulu.',
    ),
    _PrivacySection(
      title: 'Tidak Ada Pelacakan',
      body:
          'Kami tidak menggunakan Google Analytics, Firebase Analytics, Crashlytics, atau alat pelacakan apapun. Tidak ada data perilaku, lokasi, atau penggunaan aplikasi yang dikumpulkan.',
    ),
    _PrivacySection(
      title: 'Backup & Ekspor',
      body:
          'Anda dapat melakukan backup database dan ekspor data ke PDF/CSV. File hasil backup/ekspor disimpan di perangkat Anda dan sepenuhnya berada di bawah kendali Anda.',
    ),
    _PrivacySection(
      title: 'Penghapusan Data',
      body:
          'Anda dapat menghapus data individual (kendaraan, log BBM, log servis, dokumen) melalui menu masing-masing. Untuk menghapus seluruh data, cukup uninstall aplikasi.',
    ),
  ];

  static const List<_Permission> _permissions = [
    _Permission(
      icon: Icons.camera_alt_outlined,
      tintBg: AppColors.tintBlueBg,
      tintFg: AppColors.tintBlueFg,
      name: 'Kamera',
      purpose: 'Untuk memfoto kendaraan, dokumen, dan nota.',
    ),
    _Permission(
      icon: Icons.photo_library_outlined,
      tintBg: AppColors.tintPeachBg,
      tintFg: AppColors.tintPeachFg,
      name: 'Galeri / Penyimpanan',
      purpose: 'Untuk memilih foto dari galeri perangkat.',
    ),
    _Permission(
      icon: Icons.folder_outlined,
      tintBg: AppColors.tintMintBg,
      tintFg: AppColors.tintMintFg,
      name: 'Penyimpanan Internal',
      purpose: 'Menyimpan database lokal dan file backup.',
    ),
  ];
}

class _PrivacySection {
  final String title;
  final String body;
  const _PrivacySection({required this.title, required this.body});
}

class _Permission {
  final IconData icon;
  final Color tintBg;
  final Color tintFg;
  final String name;
  final String purpose;
  const _Permission({
    required this.icon,
    required this.tintBg,
    required this.tintFg,
    required this.name,
    required this.purpose,
  });
}
