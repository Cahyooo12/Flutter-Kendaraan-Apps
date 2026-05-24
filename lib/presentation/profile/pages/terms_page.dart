import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

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
          'Syarat & Ketentuan',
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
          ..._sections.map(_buildSection),
          const SizedBox(height: 20),
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
                  Icons.gavel_rounded,
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
                      'Syarat & Ketentuan',
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
            'Mohon baca syarat & ketentuan berikut dengan saksama. '
            'Dengan menggunakan aplikasi Kendaraanku, Anda dianggap setuju '
            'dengan seluruh ketentuan yang tercantum.',
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

  Widget _buildSection(_TermsSection s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      s.number,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryStrong,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              s.body,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.textMuted,
                height: 1.6,
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

  static const List<_TermsSection> _sections = [
    _TermsSection(
      number: '1',
      title: 'Penerimaan Ketentuan',
      body:
          'Dengan mengunduh, memasang, atau menggunakan aplikasi Kendaraanku, Anda menyatakan telah membaca, memahami, dan menyetujui untuk terikat dengan seluruh syarat & ketentuan ini. Jika tidak setuju, mohon segera berhenti menggunakan aplikasi.',
    ),
    _TermsSection(
      number: '2',
      title: 'Penggunaan Aplikasi',
      body:
          'Kendaraanku adalah aplikasi pencatatan kendaraan pribadi untuk kebutuhan dokumentasi personal. Anda hanya boleh menggunakan aplikasi ini untuk tujuan yang sah dan tidak melanggar hukum. Anda bertanggung jawab penuh atas data yang Anda input ke dalam aplikasi.',
    ),
    _TermsSection(
      number: '3',
      title: 'Data & Privasi',
      body:
          'Seluruh data yang Anda catat (kendaraan, pengisian BBM, servis, dokumen, foto nota) disimpan 100% di perangkat Anda menggunakan database lokal. Tidak ada data yang dikirim ke server kami. Lihat Kebijakan Privasi untuk detail lebih lanjut.',
    ),
    _TermsSection(
      number: '4',
      title: 'Kepemilikan Konten',
      body:
          'Semua data, foto, dan catatan yang Anda input adalah milik Anda sepenuhnya. Kami tidak mengklaim hak atas konten apapun yang Anda simpan di aplikasi. Anda dapat melakukan backup, ekspor, atau hapus data kapan saja melalui menu yang tersedia.',
    ),
    _TermsSection(
      number: '5',
      title: 'Batasan Tanggung Jawab',
      body:
          'Aplikasi disediakan "apa adanya" tanpa jaminan dalam bentuk apapun. Pengembang tidak bertanggung jawab atas kehilangan data, kerusakan perangkat, atau konsekuensi lain yang timbul akibat penggunaan aplikasi. Selalu lakukan backup data secara berkala.',
    ),
    _TermsSection(
      number: '6',
      title: 'Pengingat & Notifikasi',
      body:
          'Fitur pengingat servis dan tanggal kadaluarsa dokumen bersifat informatif. Anda tetap bertanggung jawab untuk memverifikasi keakuratan tanggal dan melakukan kewajiban kendaraan tepat waktu. Pengembang tidak bertanggung jawab atas keterlambatan atau denda yang timbul.',
    ),
    _TermsSection(
      number: '7',
      title: 'Hasil Pemindaian (OCR)',
      body:
          'Fitur scan nota menggunakan teknologi pengenalan teks yang berjalan offline di perangkat. Hasil pembacaan otomatis dapat tidak 100% akurat. Anda wajib memeriksa kembali data hasil scan sebelum menyimpan untuk memastikan kebenarannya.',
    ),
    _TermsSection(
      number: '8',
      title: 'Perubahan Ketentuan',
      body:
          'Kami berhak mengubah syarat & ketentuan ini sewaktu-waktu. Perubahan akan diumumkan melalui pembaruan aplikasi. Penggunaan aplikasi setelah pembaruan dianggap sebagai persetujuan atas ketentuan terbaru.',
    ),
    _TermsSection(
      number: '9',
      title: 'Hukum yang Berlaku',
      body:
          'Syarat & ketentuan ini diatur dan ditafsirkan menurut hukum Republik Indonesia. Setiap perselisihan akan diselesaikan secara musyawarah, dan jika tidak tercapai akan diselesaikan melalui jalur hukum yang berlaku.',
    ),
  ];
}

class _TermsSection {
  final String number;
  final String title;
  final String body;
  const _TermsSection({
    required this.number,
    required this.title,
    required this.body,
  });
}
