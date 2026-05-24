import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/components/app_icon_button.dart';
import 'package:flutter_kendaraanku_app/core/utils/formatters.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_model.dart';

class EditVehiclePage extends StatefulWidget {
  final VehicleModel vehicle;
  const EditVehiclePage({super.key, required this.vehicle});

  @override
  State<EditVehiclePage> createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _plateController;
  late final TextEditingController _customBrandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _colorController;
  late final TextEditingController _odometerController;

  int _selectedFuel = 0;
  late String _selectedType;
  String? _selectedBrand;

  final _fuelTypes = ['Pertalite', 'Pertamax', 'Pertamax Turbo', 'Solar', 'Listrik'];

  static const _brandsByType = <String, List<String>>{
    'motor': [
      'Honda', 'Yamaha', 'Suzuki', 'Kawasaki', 'TVS',
      'Vespa', 'BMW', 'KTM', 'Benelli', 'Royal Enfield',
      'Viar', 'Gesits', 'Lainnya',
    ],
    'mobil': [
      'Toyota', 'Honda', 'Daihatsu', 'Suzuki', 'Mitsubishi',
      'Nissan', 'Hyundai', 'Wuling', 'BMW', 'Mercedes-Benz',
      'Mazda', 'Kia', 'Isuzu', 'Subaru', 'Volkswagen',
      'MG', 'Chery', 'BYD', 'Lainnya',
    ],
  };

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _nameController = TextEditingController(text: v.name);
    _plateController = TextEditingController(text: v.plateNumber);
    _customBrandController = TextEditingController();
    _modelController = TextEditingController(text: v.model);

    final brands = _brandsByType[v.type] ?? _brandsByType['mobil']!;
    if (brands.contains(v.brand)) {
      _selectedBrand = v.brand;
    } else {
      _selectedBrand = 'Lainnya';
      _customBrandController.text = v.brand;
    }
    _yearController = TextEditingController(text: v.year.toString());
    _colorController = TextEditingController(text: v.color);
    _odometerController = TextEditingController(
      text: v.initialOdometer > 0
          ? Formatters.thousands(v.initialOdometer.round())
          : '',
    );
    _selectedType = (v.type == 'motor') ? 'motor' : 'mobil';

    // Match fuel type
    final fuelIndex = _fuelTypes.indexWhere(
      (f) => f.toLowerCase() == v.fuelType.toLowerCase(),
    );
    if (fuelIndex >= 0) _selectedFuel = fuelIndex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _customBrandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updated = widget.vehicle.copyWith(
      name: _nameController.text.trim(),
      type: _selectedType,
      brand: _selectedBrand == 'Lainnya' ? _customBrandController.text.trim() : _selectedBrand ?? '',
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      plateNumber: _plateController.text.trim().toUpperCase(),
      color: _colorController.text.trim(),
      initialOdometer: Formatters.parseFormattedNumber(_odometerController.text),
      fuelType: _fuelTypes[_selectedFuel],
      updatedAt: DateTime.now(),
    );

    if (mounted) {
      context.read<VehicleBloc>().add(UpdateVehicle(updated));
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.text),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Edit Kendaraan',
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

  Widget _buildVehicleTypeRadio() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedType = 'motor';
              _selectedBrand = null;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _selectedType == 'motor' ? AppColors.primarySofter : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedType == 'motor' ? AppColors.primary : AppColors.border,
                  width: _selectedType == 'motor' ? 2 : 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.two_wheeler_rounded,
                    size: 20,
                    color: _selectedType == 'motor' ? AppColors.primary : AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Motor',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _selectedType == 'motor' ? AppColors.primary : AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedType = 'mobil';
              _selectedBrand = null;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _selectedType == 'mobil' ? AppColors.primarySofter : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedType == 'mobil' ? AppColors.primary : AppColors.border,
                  width: _selectedType == 'mobil' ? 2 : 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_rounded,
                    size: 20,
                    color: _selectedType == 'mobil' ? AppColors.primary : AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mobil',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _selectedType == 'mobil' ? AppColors.primary : AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JENIS KENDARAAN',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.44,
            ),
          ),
          const SizedBox(height: 10),
          _buildVehicleTypeRadio(),
          const SizedBox(height: 20),
          Text(
            'INFORMASI KENDARAAN',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.44,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _nameController,
            label: 'Nama Panggilan',
            hint: 'contoh: Si Putih',
            icon: Icons.directions_car_outlined,
            capitalization: TextCapitalization.words,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _plateController,
            label: 'Plat Nomor',
            hint: 'contoh: B 1234 ABC',
            icon: Icons.pin_outlined,
            capitalization: TextCapitalization.characters,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Plat nomor wajib diisi' : null,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildBrandDropdown()),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: _modelController,
                  label: 'Tipe',
                  hint: 'Avanza',
                  capitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
              ),
            ],
          ),
          if (_selectedBrand == 'Lainnya') ...[
            const SizedBox(height: 14),
            _buildTextField(
              controller: _customBrandController,
              label: 'Nama Merk',
              hint: 'Ketik nama merk',
              icon: Icons.edit_outlined,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _yearController,
                  label: 'Tahun',
                  hint: '2023',
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                    if (v.trim().length != 4) return '4 digit';
                    final year = int.tryParse(v.trim());
                    if (year == null || year < 1900 || year > DateTime.now().year + 1) return 'Tidak valid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: _colorController,
                  label: 'Warna',
                  hint: 'Putih',
                  icon: Icons.palette_outlined,
                  capitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'TIPE BAHAN BAKAR',
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: isActive ? null : Border.all(color: AppColors.border, width: 1.5),
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
          _buildTextField(
            controller: _odometerController,
            label: 'Odometer Saat Ini',
            hint: '0',
            icon: Icons.speed_outlined,
            trailing: 'km',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandDropdown() {
    final brands = _brandsByType[_selectedType] ?? _brandsByType['mobil']!;
    if (_selectedBrand != null &&
        _selectedBrand != 'Lainnya' &&
        !brands.contains(_selectedBrand)) {
      _selectedBrand = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merk',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.23,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedBrand,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.textMuted),
          validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: 'Pilih merk',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSoft,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 10),
              child: Icon(Icons.business, size: 18, color: AppColors.textMuted),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            errorStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
          ),
          items: brands
              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
              .toList(),
          onChanged: (v) => setState(() => _selectedBrand = v),
        ),
      ],
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
    TextCapitalization capitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.23,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: capitalization,
          validator: validator,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
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
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      'Batal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _isSaving ? null : _onSave,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isSaving ? AppColors.primary.withValues(alpha: 0.6) : AppColors.primary,
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
                          'Simpan Perubahan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
