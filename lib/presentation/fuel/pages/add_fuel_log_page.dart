import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/components/app_icon_button.dart';
import 'package:flutter_kendaraanku_app/core/utils/formatters.dart';
import 'package:flutter_kendaraanku_app/core/utils/receipt_parser.dart';
import 'package:flutter_kendaraanku_app/data/models/fuel_log_model.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/fuel_log/fuel_log_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/fuel_log/fuel_log_event.dart';
import 'package:flutter_kendaraanku_app/presentation/scan/pages/scan_receipt_page.dart';
import 'package:intl/intl.dart';

class AddFuelLogPage extends StatefulWidget {
  final int vehicleId;
  final String defaultFuelType;

  const AddFuelLogPage({
    super.key,
    required this.vehicleId,
    this.defaultFuelType = 'Pertalite',
  });

  @override
  State<AddFuelLogPage> createState() => _AddFuelLogPageState();
}

class _AddFuelLogPageState extends State<AddFuelLogPage> {
  final _formKey = GlobalKey<FormState>();

  final _odometerController = TextEditingController();
  final _litersController = TextEditingController();
  final _priceController = TextEditingController();
  final _stationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int _selectedFuel = 0;
  bool _isFullTank = true;
  bool _isSaving = false;
  double _calculatedTotal = 0;
  String? _receiptImagePath;

  final _fuelTypes = [
    'Pertalite',
    'Pertamax',
    'Pertamax Turbo',
    'Solar',
    'Listrik',
  ];

  @override
  void initState() {
    super.initState();
    final idx = _fuelTypes.indexOf(widget.defaultFuelType);
    if (idx >= 0) _selectedFuel = idx;

    _litersController.addListener(_updateTotal);
    _priceController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _litersController.dispose();
    _priceController.dispose();
    _stationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    final liters = double.tryParse(_litersController.text) ?? 0;
    final price = Formatters.parseFormattedNumber(_priceController.text);
    setState(() => _calculatedTotal = liters * price);
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

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final fuelLog = FuelLogModel(
      vehicleId: widget.vehicleId,
      date: _selectedDate,
      odometer: Formatters.parseFormattedNumber(_odometerController.text),
      liters: double.parse(_litersController.text.trim()),
      pricePerLiter: Formatters.parseFormattedNumber(_priceController.text),
      totalCost: _calculatedTotal,
      fuelType: _fuelTypes[_selectedFuel],
      stationName: _stationController.text.trim().isEmpty
          ? null
          : _stationController.text.trim(),
      isFullTank: _isFullTank,
      receiptImagePath: _receiptImagePath,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    if (mounted) {
      context.read<FuelLogBloc>().add(AddFuelLog(fuelLog));
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
              'Catat BBM',
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
        builder: (_) => const ScanReceiptPage(kindHint: ReceiptKind.fuel),
      ),
    );
    if (result == null || !mounted) return;
    _applyScanResult(result);
  }

  void _applyScanResult(ScanReceiptResult result) {
    final p = result.parsed;

    if (p.date != null) _selectedDate = p.date!;
    if (p.fuelType != null) {
      final idx = _fuelTypes.indexWhere(
          (t) => t.toLowerCase() == p.fuelType!.toLowerCase());
      if (idx >= 0) _selectedFuel = idx;
    }
    if (p.liters != null) {
      _litersController.text = p.liters!.toStringAsFixed(2);
    }
    if (p.pricePerLiter != null) {
      _priceController.text = Formatters.thousands(p.pricePerLiter!.round());
    } else if (p.totalAmount != null && p.liters != null && p.liters! > 0) {
      _priceController.text =
          Formatters.thousands((p.totalAmount! / p.liters!).round());
    }
    if (p.stationOrWorkshopName != null) {
      _stationController.text = p.stationOrWorkshopName!;
    }
    _receiptImagePath = result.imageFile.path;
    _updateTotal();

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
          _buildLabel('Tanggal Pengisian'),
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
          const SizedBox(height: 14),

          // Odometer
          _buildTextField(
            controller: _odometerController,
            label: 'Odometer (km)',
            hint: 'Contoh: 45.231',
            icon: Icons.speed_outlined,
            trailing: 'km',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Odometer wajib diisi';
              final val = Formatters.parseFormattedNumber(v);
              if (val <= 0) return 'Harus lebih dari 0';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Liters
          _buildTextField(
            controller: _litersController,
            label: 'Jumlah Liter',
            hint: 'Contoh: 28.5',
            icon: Icons.local_gas_station_outlined,
            trailing: 'L',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Jumlah liter wajib diisi';
              final val = double.tryParse(v.trim());
              if (val == null || val <= 0) return 'Harus lebih dari 0';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Price per liter
          _buildTextField(
            controller: _priceController,
            label: 'Harga per Liter (Rp)',
            hint: 'Contoh: 10.000',
            icon: Icons.payments_outlined,
            trailing: 'Rp',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
              final val = Formatters.parseFormattedNumber(v);
              if (val <= 0) return 'Harus lebih dari 0';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Total cost (read-only)
          _buildLabel('Total Biaya'),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primarySofter,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primarySoft, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 18,
                    color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  Formatters.currency(_calculatedTotal),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Fuel type chips
          Text(
            'JENIS BBM',
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
            children: List.generate(_fuelTypes.length, (index) {
              final isActive = _selectedFuel == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedFuel = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: isActive
                        ? null
                        : Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Text(
                    _fuelTypes[index],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.text,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),

          // Station name
          _buildTextField(
            controller: _stationController,
            label: 'Nama SPBU (opsional)',
            hint: 'Contoh: Shell Antasari',
            icon: Icons.local_gas_station_outlined,
          ),
          const SizedBox(height: 14),

          // Full tank toggle
          _buildLabel('Full Tank'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_gas_station_rounded, size: 18,
                    color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Isi Penuh',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'Centang jika tangki diisi penuh',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isFullTank,
                  onChanged: (v) => setState(() => _isFullTank = v),
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

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
