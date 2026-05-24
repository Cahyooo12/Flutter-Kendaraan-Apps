import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
          'Bantuan & FAQ',
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
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: _faqItems.asMap().entries.map((entry) {
                final index = entry.key;
                final faq = entry.value;
                final isLast = index == _faqItems.length - 1;
                return Column(
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        title: Text(
                          faq['q']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        iconColor: AppColors.textMuted,
                        collapsedIconColor: AppColors.textSoft,
                        children: [
                          Text(
                            faq['a']!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        color: AppColors.divider,
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static final List<Map<String, String>> _faqItems = [
    {
      'q': 'Bagaimana cara menambah kendaraan?',
      'a':
          'Tap tombol \'+Tambah\' di halaman utama, lalu isi form data kendaraan Anda.',
    },
    {
      'q': 'Bagaimana cara mencatat BBM?',
      'a':
          'Buka detail kendaraan, lalu tap tombol \'BBM\'. Tap tombol \'Tambah BBM\' untuk mencatat pengisian.',
    },
    {
      'q': 'Bagaimana cara mencatat servis?',
      'a':
          'Buka detail kendaraan, lalu tap tombol \'Servis\'. Tap \'Tambah Servis\' untuk mencatat.',
    },
    {
      'q': 'Bagaimana cara export data?',
      'a':
          'Buka detail kendaraan, tap \'Pajak/Export\', lalu pilih format export (CSV atau PDF).',
    },
    {
      'q': 'Data saya tersimpan di mana?',
      'a':
          'Semua data tersimpan secara lokal di perangkat Anda. Tidak ada data yang dikirim ke server.',
    },
    {
      'q': 'Bagaimana cara backup data?',
      'a':
          'Buka Profil → Backup Database untuk menyimpan salinan database.',
    },
  ];
}
