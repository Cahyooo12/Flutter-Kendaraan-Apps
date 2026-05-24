import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_kendaraanku_app/core/components/app_icon_button.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/utils/image_helper.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_document_model.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_model.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle_document/vehicle_document_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle_document/vehicle_document_event.dart';

class AddDocumentPage extends StatefulWidget {
  final int userId;
  final List<VehicleModel> vehicles;
  final int? initialVehicleId;

  const AddDocumentPage({
    super.key,
    required this.userId,
    required this.vehicles,
    this.initialVehicleId,
  });

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _notesController = TextEditingController();

  late int _selectedVehicleId;
  String _selectedType = VehicleDocumentTypes.stnk;
  DateTime? _issueDate;
  DateTime? _expiryDate;
  bool _isPermanent = false;
  File? _photoFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedVehicleId =
        widget.initialVehicleId ?? widget.vehicles.first.id!;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isIssue}) async {
    final initial = isIssue
        ? (_issueDate ?? DateTime.now())
        : (_expiryDate ?? DateTime.now().add(const Duration(days: 365)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isIssue) {
          _issueDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _pickPhoto() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: Text('Kamera',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: Text('Galeri',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (src == null) return;
    final file = src == ImageSource.camera
        ? await ImageHelper.pickFromCamera()
        : await ImageHelper.pickFromGallery();
    if (file != null) {
      setState(() => _photoFile = file);
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isPermanent && _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tanggal kadaluarsa wajib diisi',
              style: GoogleFonts.plusJakartaSans()),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final doc = VehicleDocumentModel(
      vehicleId: _selectedVehicleId,
      documentType: _selectedType,
      documentNumber: _numberController.text.trim().isEmpty
          ? null
          : _numberController.text.trim(),
      issueDate: _issueDate,
      expiryDate: _isPermanent ? null : _expiryDate,
      imagePath: _photoFile?.path,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    if (mounted) {
      context
          .read<VehicleDocumentBloc>()
          .add(AddDocument(doc, widget.userId));
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
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.text),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tambah Dokumen',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ],
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

          // Jenis dokumen chips
          _buildSectionLabel('JENIS DOKUMEN'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: VehicleDocumentTypes.all.map((type) {
              final isActive = _selectedType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type),
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
                    type,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Vehicle picker
          _buildLabel('Kendaraan'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedVehicleId,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
                items: widget.vehicles
                    .map((v) => DropdownMenuItem<int>(
                          value: v.id,
                          child: Text('${v.name} · ${v.plateNumber}'),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedVehicleId = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Document number
          _buildLabel('Nomor Dokumen (opsional)'),
          const SizedBox(height: 6),
          _textField(
            controller: _numberController,
            hint: 'Contoh: 1234567890',
            icon: Icons.tag_rounded,
          ),
          const SizedBox(height: 14),

          // Issue date
          _buildLabel('Tanggal Terbit (opsional)'),
          const SizedBox(height: 6),
          _datePickerTile(
            value: _issueDate,
            placeholder: 'Pilih tanggal terbit',
            onTap: () => _pickDate(isIssue: true),
            onClear: () => setState(() => _issueDate = null),
          ),
          const SizedBox(height: 14),

          // Permanent toggle
          GestureDetector(
            onTap: () => setState(() {
              _isPermanent = !_isPermanent;
              if (_isPermanent) _expiryDate = null;
            }),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock_outlined,
                      size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Berlaku Permanen (mis. BPKB)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _isPermanent,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() {
                      _isPermanent = v;
                      if (v) _expiryDate = null;
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Expiry date
          if (!_isPermanent) ...[
            _buildLabel('Tanggal Kadaluarsa'),
            const SizedBox(height: 6),
            _datePickerTile(
              value: _expiryDate,
              placeholder: 'Pilih tanggal kadaluarsa',
              onTap: () => _pickDate(isIssue: false),
              onClear: () => setState(() => _expiryDate = null),
            ),
            const SizedBox(height: 14),
          ],

          // Photo
          _buildLabel('Foto Dokumen (opsional)'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _photoFile != null
                      ? AppColors.primarySoft
                      : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: _photoFile == null
                  ? Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Foto / scan dokumen',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Kamera atau galeri',
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
                    )
                  : Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _photoFile!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Foto dipilih',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _photoFile = null),
                          child: const Icon(Icons.close_rounded,
                              size: 20, color: AppColors.textMuted),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // Notes
          _buildLabel('Catatan (opsional)'),
          const SizedBox(height: 6),
          _textField(
            controller: _notesController,
            hint: 'Tambah catatan...',
            icon: Icons.notes_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.44,
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

  Widget _datePickerTile({
    required DateTime? value,
    required String placeholder,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            const Icon(Icons.event_outlined,
                size: 18, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text(
              value != null
                  ? DateFormat('dd MMMM yyyy', 'id_ID').format(value)
                  : placeholder,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: value != null ? AppColors.text : AppColors.textSoft,
              ),
            ),
            const Spacer(),
            if (value != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close_rounded,
                    size: 18, color: AppColors.textMuted),
              )
            else
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
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
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
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
                      'Simpan Dokumen',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white),
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
