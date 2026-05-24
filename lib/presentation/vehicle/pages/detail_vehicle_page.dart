import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/constants/app_styles.dart';
import 'package:flutter_kendaraanku_app/core/utils/formatters.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_model.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/vehicle/pages/edit_vehicle_page.dart';
import 'package:flutter_kendaraanku_app/presentation/service/pages/service_page.dart';
import 'package:flutter_kendaraanku_app/presentation/fuel/pages/fuel_page.dart';
import 'package:flutter_kendaraanku_app/presentation/settings/pages/export_page.dart';
import 'package:flutter_kendaraanku_app/data/repositories/service_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/fuel_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/models/service_log_model.dart';
import 'package:flutter_kendaraanku_app/data/models/fuel_log_model.dart';


class DetailVehiclePage extends StatefulWidget {
  final VehicleModel vehicle;
  const DetailVehiclePage({super.key, required this.vehicle});

  @override
  State<DetailVehiclePage> createState() => _DetailVehiclePageState();
}

class _DetailVehiclePageState extends State<DetailVehiclePage> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _HeroHeader(
                vehicle: widget.vehicle,
                onEdit: _navigateToEdit,
              ),
              const SizedBox(height: 18),
              _StatsGrid(vehicle: widget.vehicle),
              const SizedBox(height: 20),
              _TabBar(
                activeIndex: _activeTabIndex,
                onTap: (index) => setState(() => _activeTabIndex = index),
              ),
              const SizedBox(height: 16),
              if (_activeTabIndex == 0)
                _SpesifikasiCard(vehicle: widget.vehicle)
              else if (_activeTabIndex == 1)
                _ServisTab(vehicle: widget.vehicle)
              else
                _DokumenTab(vehicle: widget.vehicle),
              const SizedBox(height: 16),
              _ActionButtonsRow(vehicle: widget.vehicle),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    final vehicleBloc = context.read<VehicleBloc>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: vehicleBloc,
          child: EditVehiclePage(vehicle: widget.vehicle),
        ),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }
}

// ─── Hero Header ───────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onEdit;

  const _HeroHeader({required this.vehicle, required this.onEdit});

  IconData _vehicleIcon() {
    switch (vehicle.type) {
      case 'motor':
        return Icons.two_wheeler_rounded;
      case 'mobil':
        return Icons.directions_car_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradientVertical,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 4),
            // Top bar
            Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Detail Kendaraan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Edit button
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Car icon
            Icon(
              _vehicleIcon(),
              size: 150,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 12),
            // Plate badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                vehicle.plateNumber,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Vehicle name
            Text(
              '${vehicle.brand} ${vehicle.model}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${vehicle.color} · ${vehicle.year}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final VehicleModel vehicle;

  const _StatsGrid({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  iconBg: AppColors.tintBlueBg,
                  icon: Icons.speed_rounded,
                  iconColor: AppColors.tintBlueFg,
                  label: 'ODOMETER',
                  value: Formatters.odometer(vehicle.initialOdometer),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatCard(
                  iconBg: AppColors.tintPeachBg,
                  icon: Icons.local_gas_station_rounded,
                  iconColor: AppColors.tintPeachFg,
                  label: 'TIPE BBM',
                  value: vehicle.fuelType,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  iconBg: AppColors.tintMintBg,
                  icon: Icons.build_rounded,
                  iconColor: AppColors.tintMintFg,
                  label: 'SERVIS TERAKHIR',
                  value: '-',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatCard(
                  iconBg: AppColors.tintAmberBg,
                  icon: Icons.receipt_long_rounded,
                  iconColor: AppColors.tintAmberFg,
                  label: 'PAJAK BERIKUT',
                  value: '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MiniStatCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.rLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppColors.textSoft,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Bar ───────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _TabBar({required this.activeIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tabs = ['Spesifikasi', 'Servis', 'Dokumen'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isActive = index == activeIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Spesifikasi Card ──────────────────────────────────────────────────────────
class _SpesifikasiCard extends StatelessWidget {
  final VehicleModel vehicle;

  const _SpesifikasiCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final specs = [
      ('Nama', vehicle.name),
      ('Merk & Tipe', '${vehicle.brand} ${vehicle.model}'),
      ('Tahun', vehicle.year.toString()),
      ('Warna', vehicle.color),
      ('Plat Nomor', vehicle.plateNumber),
      ('Jenis', vehicle.type[0].toUpperCase() + vehicle.type.substring(1)),
      ('Bahan Bakar', vehicle.fuelType),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppStyles.rLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: List.generate(specs.length, (index) {
            final spec = specs[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        spec.$1,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        spec.$2,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < specs.length - 1)
                  const Divider(color: AppColors.divider, height: 1),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─── Action Buttons Row ────────────────────────────────────────────────────────
class _ActionButtonsRow extends StatelessWidget {
  final VehicleModel vehicle;

  const _ActionButtonsRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              bg: AppColors.tintMintBg,
              icon: Icons.build_rounded,
              iconColor: AppColors.tintMintFg,
              label: 'Servis',
              onTap: () {
                final vehicleBloc = context.read<VehicleBloc>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: vehicleBloc,
                      child: const ServicePage(),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              bg: AppColors.tintPeachBg,
              icon: Icons.local_gas_station_rounded,
              iconColor: AppColors.tintPeachFg,
              label: 'BBM',
              onTap: () {
                final vehicleBloc = context.read<VehicleBloc>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: vehicleBloc,
                      child: const FuelPage(),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              bg: AppColors.tintAmberBg,
              icon: Icons.receipt_long_rounded,
              iconColor: AppColors.tintAmberFg,
              label: 'Pajak',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExportPage(
                    vehicleId: vehicle.id!,
                    vehicleName: '${vehicle.brand} ${vehicle.model}',
                    plateNumber: vehicle.plateNumber,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.bg,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppStyles.r),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ─── Servis Tab ───────────────────────────────────────────────────────────────
class _ServisTab extends StatelessWidget {
  final VehicleModel vehicle;

  const _ServisTab({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ServiceLogRepository().getByVehicle(vehicle.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final logs = snapshot.data?.fold(
          (l) => <ServiceLogModel>[],
          (r) => r,
        ) ?? <ServiceLogModel>[];

        if (logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.tintMintBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.build_rounded,
                      color: AppColors.tintMintFg,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada catatan servis',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final displayLogs = logs.take(5).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ...displayLogs.map((log) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppStyles.rLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.tintMintBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.build_rounded,
                          size: 20,
                          color: AppColors.tintMintFg,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              log.workshopName ?? '-',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.currency(log.cost),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.date(log.date),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
              if (logs.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    onTap: () {
                      final vehicleBloc = context.read<VehicleBloc>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: vehicleBloc,
                            child: const ServicePage(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppStyles.r),
                      ),
                      child: Center(
                        child: Text(
                          'Lihat Semua Servis',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Dokumen Tab ──────────────────────────────────────────────────────────────
class _DokumenTab extends StatelessWidget {
  final VehicleModel vehicle;

  const _DokumenTab({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        FuelLogRepository().getByVehicle(vehicle.id!),
        ServiceLogRepository().getByVehicle(vehicle.id!),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final results = snapshot.data;
        final fuelLogs = (results?[0] as dynamic)?.fold(
          (l) => <FuelLogModel>[],
          (r) => r,
        ) as List<FuelLogModel>? ?? <FuelLogModel>[];
        final serviceLogs = (results?[1] as dynamic)?.fold(
          (l) => <ServiceLogModel>[],
          (r) => r,
        ) as List<ServiceLogModel>? ?? <ServiceLogModel>[];

        final fuelWithPhotos = fuelLogs
            .where((l) => l.receiptImagePath != null)
            .toList();
        final serviceWithPhotos = serviceLogs
            .where((l) => l.receiptImagePath != null)
            .toList();
        final totalPhotos = fuelWithPhotos.length + serviceWithPhotos.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Info count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppStyles.rLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.tintLavenderBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.folder_rounded,
                        size: 20,
                        color: AppColors.tintLavenderFg,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${fuelLogs.length} catatan BBM  ·  ${serviceLogs.length} catatan servis',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (totalPhotos == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada foto dokumen',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Foto nota akan muncul di sini saat Anda menambahkan foto pada catatan BBM atau servis',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                ...fuelWithPhotos.map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DocPhotoCard(
                    iconBg: AppColors.tintPeachBg,
                    icon: Icons.local_gas_station_rounded,
                    iconColor: AppColors.tintPeachFg,
                    title: 'Nota BBM - ${log.fuelType}',
                    subtitle: Formatters.date(log.date),
                    amount: Formatters.currency(log.totalCost),
                  ),
                )),
                ...serviceWithPhotos.map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DocPhotoCard(
                    iconBg: AppColors.tintMintBg,
                    icon: Icons.build_rounded,
                    iconColor: AppColors.tintMintFg,
                    title: 'Nota Servis - ${log.description}',
                    subtitle: Formatters.date(log.date),
                    amount: Formatters.currency(log.cost),
                  ),
                )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DocPhotoCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;

  const _DocPhotoCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.rLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amount,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.camera_alt,
                size: 14,
                color: AppColors.tintBlueFg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
