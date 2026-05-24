import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/constants/app_styles.dart';
import 'package:flutter_kendaraanku_app/core/components/app_card.dart';
import 'package:flutter_kendaraanku_app/core/components/app_chip.dart';
import 'package:flutter_kendaraanku_app/core/components/app_icon_button.dart';
import 'package:flutter_kendaraanku_app/core/components/section_title.dart';
import 'package:flutter_kendaraanku_app/core/components/tint_icon_box.dart';
import 'package:flutter_kendaraanku_app/core/components/status_pill.dart';
import 'package:flutter_kendaraanku_app/core/extensions/build_context_ext.dart';
import 'package:flutter_kendaraanku_app/core/extensions/string_ext.dart';
import 'package:flutter_kendaraanku_app/core/utils/formatters.dart';
import 'package:flutter_kendaraanku_app/data/local/auth_local_datasource.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_model.dart';
import 'package:flutter_kendaraanku_app/data/repositories/fuel_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/service_log_repository.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/dashboard/dashboard_event.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/dashboard/dashboard_state.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_state.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:flutter_kendaraanku_app/presentation/vehicle/pages/detail_vehicle_page.dart';
import 'package:flutter_kendaraanku_app/presentation/notifications/pages/notifications_page.dart';
import 'package:flutter_kendaraanku_app/presentation/vehicle/pages/add_vehicle_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            final VehicleModel? selectedVehicle;
            final List<VehicleModel> vehicles;
            final int selectedIndex;

            if (state is VehicleLoaded) {
              vehicles = state.vehicles;
              selectedIndex = state.selectedIndex;
              selectedVehicle = state.selectedVehicle;
            } else {
              vehicles = [];
              selectedIndex = 0;
              selectedVehicle = null;
            }

            final hasVehicles = vehicles.isNotEmpty;

            final content = SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const _HomeHeader(),
                  const SizedBox(height: 16),
                  if (hasVehicles) ...[
                    _VehicleSelectorChips(
                      vehicles: vehicles,
                      selectedIndex: selectedIndex,
                    ),
                    _HeroVehicleCard(
                      vehicle: selectedVehicle,
                      isLoading: state is VehicleLoading,
                      onDetailTap: selectedVehicle != null
                          ? () {
                              final vehicleBloc = context.read<VehicleBloc>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: vehicleBloc,
                                    child: DetailVehiclePage(
                                        vehicle: selectedVehicle!),
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                    const SizedBox(height: 18),
                    const _QuickStatsRow(),
                    const SizedBox(height: 24),
                    const _PengingatSection(),
                    const SizedBox(height: 24),
                    const _AktivitasTerakhirSection(),
                    const SizedBox(height: 24),
                  ] else ...[
                    const _EmptyStateWelcome(),
                  ],
                ],
              ),
            );

            final vehicleId = selectedVehicle?.id;
            if (vehicleId != null) {
              return BlocProvider(
                key: ValueKey(vehicleId),
                create: (_) => DashboardBloc(
                  FuelLogRepository(),
                  ServiceLogRepository(),
                )..add(LoadDashboard(vehicleId)),
                child: content,
              );
            }

            return content;
          },
        ),
      ),
    );
  }
}

// ─── Home Header ───────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<String?>(
        future: AuthLocalDatasource().getUserName(),
        builder: (context, snapshot) {
          final userName = snapshot.data ?? 'User';
          final userInitials = userName.initials;

          return Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    userInitials,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryStrong,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      userName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
              // Bell icon
              Stack(
                children: [
                  AppIconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      size: 22,
                      color: AppColors.textMuted,
                    ),
                    size: 40,
                    borderRadius: 12,
                    onTap: () => context.push(const NotificationsPage()),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Empty State Welcome ──────────────────────────────────────────────────────
class _EmptyStateWelcome extends StatelessWidget {
  const _EmptyStateWelcome();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Hero illustration card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -30,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: -10,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Belum Ada Kendaraan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan kendaraan pertamamu\nuntuk mulai mencatat aktivitas',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Builder(
                      builder: (ctx) {
                        return GestureDetector(
                          onTap: () {
                            final bloc = ctx.read<VehicleBloc>();
                            Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: bloc,
                                  child: const AddVehiclePage(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Tambah Kendaraan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Feature highlights
          Center(
            child: Text(
              'Yang bisa kamu lakukan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _FeatureRow(
            icon: Icons.local_gas_station_rounded,
            iconBg: AppColors.tintBlueBg,
            iconColor: AppColors.tintBlueFg,
            title: 'Catat Pengisian BBM',
            subtitle: 'Pantau konsumsi dan pengeluaran bahan bakar',
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            icon: Icons.build_rounded,
            iconBg: AppColors.tintMintBg,
            iconColor: AppColors.tintMintFg,
            title: 'Riwayat Servis',
            subtitle: 'Simpan catatan perawatan berkala',
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            icon: Icons.insert_chart_rounded,
            iconBg: AppColors.tintPeachBg,
            iconColor: AppColors.tintPeachFg,
            title: 'Laporan & Statistik',
            subtitle: 'Analisis pengeluaran kendaraanmu',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
        ],
      ),
    );
  }
}

// ─── Vehicle Selector Chips ────────────────────────────────────────────────────
class _VehicleSelectorChips extends StatelessWidget {
  final List<VehicleModel> vehicles;
  final int selectedIndex;

  const _VehicleSelectorChips({
    required this.vehicles,
    required this.selectedIndex,
  });

  IconData _vehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'motor':
        return Icons.two_wheeler_rounded;
      case 'mobil':
        return Icons.directions_car_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Vehicle chips from data
            ...vehicles.asMap().entries.map((entry) {
              final index = entry.key;
              final vehicle = entry.value;
              final isActive = index == selectedIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => context
                      .read<VehicleBloc>()
                      .add(SelectVehicle(index)),
                  child: AppChip(
                    label: vehicle.name,
                    isActive: isActive,
                    icon: isActive
                        ? Icon(
                            _vehicleIcon(vehicle.type),
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              );
            }),
            // Add chip
            GestureDetector(
              onTap: () {
                final bloc = context.read<VehicleBloc>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: const AddVehiclePage(),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Tambah',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero Vehicle Card ─────────────────────────────────────────────────────────
class _HeroVehicleCard extends StatelessWidget {
  final VehicleModel? vehicle;
  final bool isLoading;
  final VoidCallback? onDetailTap;

  const _HeroVehicleCard({
    this.vehicle,
    this.isLoading = false,
    this.onDetailTap,
  });

  String _formatOdometer(double value) {
    final intVal = value.toInt();
    final formatted = intVal.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return '$formatted km';
  }

  IconData _vehicleIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'motor':
        return Icons.two_wheeler_rounded;
      case 'mobil':
        return Icons.directions_car_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final plateNumber = vehicle?.plateNumber ?? '- - -';
    final vehicleDesc = vehicle != null
        ? '${vehicle!.brand} ${vehicle!.model} ${vehicle!.year}'
        : 'Belum ada kendaraan';
    final odometer = vehicle != null
        ? _formatOdometer(vehicle!.initialOdometer)
        : '0 km';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppStyles.rXl),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: 40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ),
          // Vehicle icon on the right
          Positioned(
            right: -10,
            top: 10,
            child: Icon(
              _vehicleIcon(vehicle?.type),
              size: 90,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: vehicle != null
                            ? Colors.greenAccent
                            : Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vehicle != null ? 'Aktif' : 'Kosong',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'PLAT NOMOR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              isLoading
                  ? const SizedBox(
                      height: 26,
                      width: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      plateNumber,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.66,
                        color: Colors.white,
                      ),
                    ),
              const SizedBox(height: 4),
              Text(
                vehicleDesc,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 18),
              // Bottom section
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Odometer',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        odometer,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: vehicle != null ? onDetailTap : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Detail',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick Stats Row ───────────────────────────────────────────────────────────
class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  static String _abbreviate(double value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1).replaceAll('.', ',')}jt';
    }
    if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}rb';
    }
    return Formatters.currency(value);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<DashboardBloc?>(); // nullable if no vehicle
    if (bloc == null) {
      return const _QuickStatsRowPlaceholder();
    }

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          final data = state.data;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _QuickStatCard(
                    iconBg: AppColors.tintBlueBg,
                    icon: Icons.local_gas_station_rounded,
                    iconColor: AppColors.tintBlueFg,
                    value: '${data.fuelCountThisMonth}x isi',
                    label: 'BBM bulan ini',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickStatCard(
                    iconBg: AppColors.tintPeachBg,
                    icon: Icons.speed_rounded,
                    iconColor: AppColors.tintPeachFg,
                    value: data.avgConsumption > 0
                        ? Formatters.consumption(data.avgConsumption)
                        : '-',
                    label: 'Konsumsi BBM',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickStatCard(
                    iconBg: AppColors.tintMintBg,
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.tintMintFg,
                    value: _abbreviate(data.totalExpenseThisMonth),
                    label: 'Pengeluaran',
                  ),
                ),
              ],
            ),
          );
        }

        return const _QuickStatsRowPlaceholder();
      },
    );
  }
}

class _QuickStatsRowPlaceholder extends StatelessWidget {
  const _QuickStatsRowPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuickStatCard(
              iconBg: AppColors.tintBlueBg,
              icon: Icons.local_gas_station_rounded,
              iconColor: AppColors.tintBlueFg,
              value: '-',
              label: 'BBM bulan ini',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickStatCard(
              iconBg: AppColors.tintPeachBg,
              icon: Icons.speed_rounded,
              iconColor: AppColors.tintPeachFg,
              value: '-',
              label: 'Konsumsi BBM',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickStatCard(
              iconBg: AppColors.tintMintBg,
              icon: Icons.account_balance_wallet_rounded,
              iconColor: AppColors.tintMintFg,
              value: '-',
              label: 'Pengeluaran',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _QuickStatCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.rLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, size: 18, color: iconColor)),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pengingat Section ─────────────────────────────────────────────────────────
class _PengingatSection extends StatelessWidget {
  const _PengingatSection();

  PillType _pillType(int daysUntil) {
    if (daysUntil <= 7) return PillType.due;
    if (daysUntil <= 30) return PillType.warn;
    return PillType.ok;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<DashboardBloc?>();
    if (bloc == null) {
      return _buildEmpty();
    }

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          final reminders = state.data.reminders;
          if (reminders.isEmpty) {
            return _buildEmpty();
          }
          return Column(
            children: [
              SectionTitle(
                title: 'Pengingat',
                actionText: 'Lihat semua',
                onAction: () => context.push(const NotificationsPage()),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: reminders.map((reminder) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReminderCard(
                        iconBg: AppColors.tintRoseBg,
                        icon: Icons.build_rounded,
                        iconColor: AppColors.tintRoseFg,
                        title: reminder.title,
                        subtitle: reminder.subtitle,
                        pillLabel: '${reminder.daysUntil} hari lagi',
                        pillType: _pillType(reminder.daysUntil),
                        date: Formatters.date(reminder.dueDate),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }

        return _buildEmpty();
      },
    );
  }

  Widget _buildEmpty() {
    return Builder(
      builder: (context) => Column(
        children: [
          SectionTitle(
            title: 'Pengingat',
            actionText: 'Lihat semua',
            onAction: () => context.push(const NotificationsPage()),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tidak ada pengingat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String pillLabel;
  final PillType pillType;
  final String date;

  const _ReminderCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.pillLabel,
    required this.pillType,
    required this.date,
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
          TintIconBox(
            icon: Icon(icon, size: 20, color: iconColor),
            backgroundColor: iconBg,
            size: 42,
            borderRadius: 12,
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
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusPill(label: pillLabel, type: pillType),
                    const Spacer(),
                    Text(
                      date,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Aktivitas Terakhir Section ────────────────────────────────────────────────
class _AktivitasTerakhirSection extends StatelessWidget {
  const _AktivitasTerakhirSection();

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<DashboardBloc?>();
    if (bloc == null) {
      return _buildEmpty();
    }

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          final activities = state.data.recentActivities;
          if (activities.isEmpty) {
            return _buildEmpty();
          }
          return Column(
            children: [
              SectionTitle(
                  title: 'Aktivitas Terakhir',
                  actionText: 'Lihat semua',
                  onAction: () => context.push(const NotificationsPage()),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
                  child: Column(
                    children: [
                      for (int i = 0; i < activities.length; i++) ...[
                        if (i > 0)
                          const Divider(color: AppColors.divider, height: 1),
                        _ActivityRow(
                          iconBg: activities[i].type == 'fuel'
                              ? AppColors.tintPeachBg
                              : AppColors.tintMintBg,
                          icon: activities[i].type == 'fuel'
                              ? Icons.local_gas_station_rounded
                              : Icons.build_rounded,
                          iconColor: activities[i].type == 'fuel'
                              ? AppColors.tintPeachFg
                              : AppColors.tintMintFg,
                          title: activities[i].title,
                          subtitle: activities[i].subtitle,
                          amount: '-${Formatters.currency(activities[i].amount)}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return _buildEmpty();
      },
    );
  }

  Widget _buildEmpty() {
    return Column(
      children: [
        Builder(
          builder: (context) => SectionTitle(
            title: 'Aktivitas Terakhir',
            actionText: 'Lihat semua',
            onAction: () => context.push(const NotificationsPage()),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Belum ada aktivitas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;

  const _ActivityRow({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          TintIconBox(
            icon: Icon(icon, size: 18, color: iconColor),
            backgroundColor: iconBg,
            size: 38,
            borderRadius: 10,
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
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
