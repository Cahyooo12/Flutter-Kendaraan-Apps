import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  static const _prefsKey = 'app_theme_mode';
  String _selected = 'light';
  bool _loading = true;

  static const _themes = [
    _ThemeOption(
      id: 'light',
      label: 'Terang',
      subtitle: 'Tampilan cerah untuk siang hari',
      icon: Icons.light_mode_rounded,
      tintBg: AppColors.tintAmberBg,
      tintFg: AppColors.tintAmberFg,
    ),
    _ThemeOption(
      id: 'dark',
      label: 'Gelap',
      subtitle: 'Nyaman di mata saat malam',
      icon: Icons.dark_mode_rounded,
      tintBg: AppColors.tintLavenderBg,
      tintFg: AppColors.tintLavenderFg,
    ),
    _ThemeOption(
      id: 'system',
      label: 'Ikuti Sistem',
      subtitle: 'Otomatis sesuai pengaturan perangkat',
      icon: Icons.settings_brightness_rounded,
      tintBg: AppColors.tintBlueBg,
      tintFg: AppColors.tintBlueFg,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selected = prefs.getString(_prefsKey) ?? 'light';
      _loading = false;
    });
  }

  Future<void> _select(String id) async {
    setState(() => _selected = id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Preferensi tema tersimpan. Restart aplikasi untuk berlaku penuh.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

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
          'Tema Warna',
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
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primarySofter,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primarySoft),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.palette_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pilih tema yang nyaman untuk mata Anda.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryStrong,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ..._themes.map(_buildOption),
              ],
            ),
    );
  }

  Widget _buildOption(_ThemeOption opt) {
    final isActive = _selected == opt.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _select(opt.id),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: opt.tintBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(opt.icon, size: 22, color: opt.tintFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opt.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      opt.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isActive ? AppColors.primary : AppColors.surface,
                  border: Border.all(
                    color:
                        isActive ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: isActive
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color tintBg;
  final Color tintFg;
  const _ThemeOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.tintBg,
    required this.tintFg,
  });
}
