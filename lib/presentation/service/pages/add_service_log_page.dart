import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/components/app_icon_button.dart';
import 'package:flutter_kendaraanku_app/core/utils/formatters.dart';
import 'package:flutter_kendaraanku_app/core/utils/receipt_parser.dart';
import 'package:flutter_kendaraanku_app/data/models/service_log_model.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/service_log/service_log_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/service_log/service_log_event.dart';
import 'package:flutter_kendaraanku_app/presentation/scan/pages/scan_receipt_page.dart';
import 'package:intl/intl.dart';

class AddServiceLogPage extends StatefulWidget {
  final int vehicleId;

  const AddServiceLogPage({
    super.key,
    required this.vehicleId,
  });

  @override
  State<AddServiceLogPage> createState() => _AddServiceLogPageState();
}

class _AddServiceLogPageState extends State<AddServiceLogPage> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();
  final _workshopController = TextEditingController();
  final _nextOdometerController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime? _nextServiceDate;
  int _selectedCategory = 0;
  bool _isSaving = false;
  String? _receiptImagePath;

  final _serviceCategories = [
    'Ganti Oli Mesin',
    'Ganti Oli Gardan',
    'Ganti Ban',
    'Tune Up / Servis Rutin',
    'Ganti Aki',
    'Ganti Kampas Rem',
    'Ganti V-Belt',
    'Servis AC',
    'Perpanjang STNK / Pajak',
    'Lain-lain',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    _workshopController.dispose();
    _nextOdometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickNextServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextServiceDate ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _nextServiceDate = picked);
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final serviceLog = ServiceLogModel(
      vehicleId: widget.vehicleId,
      date: _selectedDate,
      odometer: _odometerController.text.trim().isNotEmpty
          ? Formatters.parseFormattedNumber(_odometerController.text)
          : null,
      serviceType: _serviceCategories[_selectedCategory],
      description: _descriptionController.text.trim(),
      cost: Formatters.parseFormattedNumber(_costController.text),
      workshopName: _workshopController.text.trim().isEmpty
          ? null
          : _workshopController.text.trim(),
      receiptImagePath: _receiptImagePath,
      nextServiceOdometer: _nextOdometerController.text.trim().isNotEmpty
          ? Formatters.parseFormattedNumber(_nextOdometerController.text)
          : null,
      nextServiceDate: _nextServiceDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    if (mounted) {
      context.read<ServiceLogBloc>().add(AddServiceLog(serviceLog));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(),
                    _buildFormFields(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomCTA(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16,
                color: AppColors.text),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Catat Servis',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          GestureDetector(
            onTap: _openScan,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.document_scanner_outlined,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Scan Nota',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openScan() async {
    final result = await Navigator.of(context).push<ScanReceiptResult>(
      MaterialPageRoute(
        builder: (_) => const ScanReceiptPage(kindHint: ReceiptKind.service),
      ),
    );
    if (result == null || !mounted) return;
    _applyScanResult(result);
  }

  void _applyScanResult(ScanReceiptResult result) {
    final p = result.parsed;

    if (p.date != null) _selectedDate = p.date!;
    if (p.totalAmount != null) {
      _costController.text = Formatters.thousands(p.totalAmount!.round());
    }
    if (p.stationOrWorkshopName != null) {
      _workshopController.text = p.stationOrWorkshopName!;
    }
    _receiptImagePath = result.imageFile.path;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          p.hasAnyField
              ? 'Hasil scan diisi ke form. Periksa lagi sebelum simpan.'
              : 'Tidak ada data terdeteksi.',
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        backgroundColor:
            p.hasAnyField ? AppColors.primary : AppColors.warning,
      ),
    );
  }

  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Date picker
          _buildLabel('Tanggal'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18,
                      color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20,
                      color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Service category chips
          Text(
            'JENIS SERVIS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.44,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_serviceCategories.length, (index) {
              final isActive = _selectedCategory == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surface2,
                    borderRadius: BorderRadius.circular(100),
                    border: isActive
                        ? null
                        : Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Text(
                    _serviceCategories[index],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),

          // Description
          _buildTextField(
            controller: _descriptionController,
            label: 'Deskripsi',
            hint: 'Deskripsi layanan servis',
            icon: Icons.description_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Deskripsi wajib diisi';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Cost
          _buildTextField(
            controller: _costController,
            label: 'Biaya (Rp)',
            hint: 'Contoh: 350.000',
            icon: Icons.payments_outlined,
            prefix: 'Rp',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Biaya wajib diisi';
              final val = Formatters.parseFormattedNumber(v);
              if (val <= 0) return 'Harus lebih dari 0';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Odometer
          _buildTextField(
            controller: _odometerController,
            label: 'Odometer (opsional)',
            hint: 'Contoh: 45.231',
            icon: Icons.speed_outlined,
            trailing: 'km',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
          ),
          const SizedBox(height: 14),

          // Workshop name
          _buildTextField(
            controller: _workshopController,
            label: 'Nama Bengkel (opsional)',
            hint: 'Nama bengkel / dealer',
            icon: Icons.store_outlined,
          ),
          const SizedBox(height: 18),

          // Next service reminder section
          Text(
            'PENGINGAT SERVIS BERIKUTNYA',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.44,
            ),
          ),
          const SizedBox(height: 10),

          // Next service odometer
          _buildTextField(
            controller: _nextOdometerController,
            label: 'Odometer Servis Berikutnya (opsional)',
            hint: 'Contoh: 50.000',
            icon: Icons.update_outlined,
            trailing: 'km',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
          ),
          const SizedBox(height: 14),

          // Next service date
          _buildLabel('Tanggal Servis Berikutnya (opsional)'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickNextServiceDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined, size: 18,
                      color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Text(
                    _nextServiceDate != null
                        ? DateFormat('dd MMMM yyyy', 'id_ID')
                            .format(_nextServiceDate!)
                        : 'Pilih tanggal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _nextServiceDate != null
                          ? AppColors.text
                          : AppColors.textSoft,
                    ),
                  ),
                  const Spacer(),
                  if (_nextServiceDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _nextServiceDate = null),
                      child: const Icon(Icons.close_rounded, size: 18,
                          color: AppColors.textMuted),
                    )
                  else
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 20,
                        color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Receipt photo (from scan)
          if (_receiptImagePath != null) ...[
            _buildLabel('Foto Nota'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_receiptImagePath!),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nota dilampirkan dari scan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _receiptImagePath = null),
                    child: const Icon(Icons.close_rounded,
                        size: 20, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Notes
          _buildTextField(
            controller: _notesController,
            label: 'Catatan (opsional)',
            hint: 'Tambahkan catatan...',
            icon: Icons.notes_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.23,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    String? trailing,
    String? prefix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSoft,
            ),
            prefixIcon: icon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Icon(icon, size: 18, color: AppColors.textMuted),
                  )
                : null,
            prefixIconConstraints: icon != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            prefixText: prefix != null ? '$prefix ' : null,
            prefixStyle: prefix != null
                ? GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  )
                : null,
            suffixIcon: trailing != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      trailing,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: trailing != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: Colors.redAccent, width: 1.5),
            ),
            errorStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCTA() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bg.withValues(alpha: 0.0),
              AppColors.bg.withValues(alpha: 1.0),
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: _isSaving ? null : _onSave,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: _isSaving
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSaving)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else ...[
                    Text(
                      'Simpan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.check_rounded, size: 16,
                        color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
