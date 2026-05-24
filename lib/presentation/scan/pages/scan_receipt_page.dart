import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_kendaraanku_app/core/components/app_icon_button.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/utils/formatters.dart';
import 'package:flutter_kendaraanku_app/core/utils/image_helper.dart';
import 'package:flutter_kendaraanku_app/core/utils/receipt_parser.dart';

class ScanReceiptResult {
  final ParsedReceipt parsed;
  final File imageFile;

  const ScanReceiptResult({required this.parsed, required this.imageFile});
}

class ScanReceiptPage extends StatefulWidget {
  final ReceiptKind kindHint;

  const ScanReceiptPage({super.key, required this.kindHint});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  File? _imageFile;
  ParsedReceipt? _parsed;
  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _error = null;
      _processing = true;
    });

    try {
      final file = source == ImageSource.camera
          ? await ImageHelper.pickFromCamera()
          : await ImageHelper.pickFromGallery();

      if (file == null) {
        setState(() => _processing = false);
        return;
      }

      _imageFile = file;

      final input = InputImage.fromFile(file);
      final recognized = await _recognizer.processImage(input);

      final parsed = ReceiptParser.parse(
        recognized.text,
        hintKind: widget.kindHint,
      );

      if (!mounted) return;
      setState(() {
        _parsed = parsed;
        _processing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memproses gambar: $e';
        _processing = false;
      });
    }
  }

  void _useResult() {
    if (_parsed == null || _imageFile == null) return;
    Navigator.pop(
      context,
      ScanReceiptResult(parsed: _parsed!, imageFile: _imageFile!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_imageFile == null) _buildEmpty(),
                    if (_imageFile != null) _buildPreview(),
                    if (_processing) ...[
                      const SizedBox(height: 16),
                      _buildProcessing(),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      _buildError(),
                    ],
                    if (_parsed != null && !_processing) ...[
                      const SizedBox(height: 16),
                      _buildResult(),
                    ],
                  ],
                ),
              ),
            ),
            if (_parsed != null && !_processing) _buildBottomCTA(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.text),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Nota',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  widget.kindHint == ReceiptKind.fuel
                      ? 'BBM · auto-isi tanggal, liter, harga'
                      : 'Servis · auto-isi tanggal, bengkel, biaya',
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
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Foto Nota Pengisian',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pastikan teks pada nota terlihat jelas\nuntuk hasil scan yang akurat.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _sourceButton(
            icon: Icons.camera_alt_rounded,
            label: 'Buka Kamera',
            subtitle: 'Ambil foto langsung dari nota',
            onTap: () => _pick(ImageSource.camera),
          ),
          const SizedBox(height: 10),
          _sourceButton(
            icon: Icons.photo_library_rounded,
            label: 'Pilih dari Galeri',
            subtitle: 'Gunakan foto yang sudah ada',
            onTap: () => _pick(ImageSource.gallery),
          ),
          const SizedBox(height: 18),
          _tipsCard(),
        ],
      ),
    );
  }

  Widget _sourceButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _processing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
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
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySofter,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Tips Scan Maksimal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryStrong,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _tipBullet('Cahaya cukup, hindari bayangan'),
          _tipBullet('Nota rata, tidak terlipat'),
          _tipBullet('Kamera tegak lurus dengan nota'),
        ],
      ),
    );
  }

  Widget _tipBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            _imageFile!,
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _processing ? null : () => _pick(ImageSource.camera),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh_rounded,
                            size: 16, color: AppColors.text),
                        const SizedBox(width: 6),
                        Text(
                          'Foto Ulang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _processing ? null : () => _pick(ImageSource.gallery),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_outlined,
                            size: 16, color: AppColors.text),
                        const SizedBox(width: 6),
                        Text(
                          'Galeri',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProcessing() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Membaca teks dari nota...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintRoseBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.tintRoseFg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.tintRoseFg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final p = _parsed!;
    final isFuel = p.kind == ReceiptKind.fuel;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Pembacaan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      p.hasAnyField
                          ? 'Periksa hasil, lalu pakai untuk auto-isi'
                          : 'Field tidak terdeteksi, coba foto ulang',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),
          _row('Tanggal', p.formattedDate),
          if (isFuel) ...[
            _row('Jenis BBM', p.fuelType ?? '-'),
            _row(
              'Volume',
              p.liters != null ? Formatters.liters(p.liters!) : '-',
            ),
            _row(
              'Harga / Liter',
              p.pricePerLiter != null
                  ? Formatters.currency(p.pricePerLiter!)
                  : '-',
            ),
          ],
          _row(
            isFuel ? 'SPBU' : 'Bengkel',
            p.stationOrWorkshopName ?? '-',
          ),
          _row(
            'Total',
            p.totalAmount != null ? Formatters.currency(p.totalAmount!) : '-',
            bold: true,
          ),
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            iconColor: AppColors.textMuted,
            collapsedIconColor: AppColors.textMuted,
            title: Text(
              'Lihat teks mentah OCR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  p.rawText.isEmpty ? '(kosong)' : p.rawText,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA() {
    final canUse = _parsed!.hasAnyField;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: canUse ? _useResult : null,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: canUse
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  canUse ? 'Pakai Hasil Ini' : 'Tidak Ada Data Terbaca',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (canUse) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
