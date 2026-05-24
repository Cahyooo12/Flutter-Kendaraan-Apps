import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/utils/formatters.dart';
import 'package:flutter_kendaraanku_app/data/models/fuel_log_model.dart';
import 'package:flutter_kendaraanku_app/data/repositories/fuel_log_repository.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/fuel_log/fuel_log_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/fuel_log/fuel_log_event.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/fuel_log/fuel_log_state.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_state.dart';
import 'package:flutter_kendaraanku_app/presentation/fuel/pages/add_fuel_log_page.dart';
import 'package:flutter_kendaraanku_app/presentation/vehicle/pages/add_vehicle_page.dart';

class FuelPage extends StatelessWidget {
  const FuelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        int? vehicleId;
        if (state is VehicleLoaded && state.selectedVehicle != null) {
          vehicleId = state.selectedVehicle!.id!;
        }

        if (vehicleId == null) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.tintPeachBg,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.local_gas_station_rounded,
                          color: AppColors.tintPeachFg,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Belum Ada Kendaraan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan kendaraan dulu untuk\nmulai mencatat pengisian BBM.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 22),
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
                              horizontal: 22, vertical: 13),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Tambah Kendaraan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
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
              ),
            ),
          );
        }

        return BlocProvider(
          create: (context) => FuelLogBloc(FuelLogRepository())
            ..add(LoadFuelLogs(vehicleId!)),
          child: _FuelPageContent(vehicleId: vehicleId),
        );
      },
    );
  }
}

class _FuelPageContent extends StatelessWidget {
  final int vehicleId;
  const _FuelPageContent({required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          BlocBuilder<FuelLogBloc, FuelLogState>(
            builder: (context, state) {
              if (state is FuelLogLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is FuelLogError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.textSoft,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context
                              .read<FuelLogBloc>()
                              .add(LoadFuelLogs(vehicleId)),
                          child: Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is FuelLogLoaded) {
                if (state.logs.isEmpty) {
                  return _buildEmptyState(context);
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      _buildAppBar(context),
                      const SizedBox(height: 4),
                      _buildSummaryCard(state.stats),
                      if (state.stats.monthlyData.isNotEmpty)
                        _buildBarChartCard(state.stats.monthlyData),
                      _buildHistoryHeader(),
                      const SizedBox(height: 10),
                      _buildFuelHistoryList(context, state.logs),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }
              // FuelLogInitial
              return const Center(child: CircularProgressIndicator());
            },
          ),
          // App bar always visible even during loading/empty
          BlocBuilder<FuelLogBloc, FuelLogState>(
            buildWhen: (prev, curr) => false,
            builder: (context, state) {
              if (state is FuelLogLoaded && state.logs.isNotEmpty) {
                return const SizedBox.shrink();
              }
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: AppColors.bg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      _buildAppBar(context),
                    ],
                  ),
                ),
              );
            },
          ),
          _buildFAB(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
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
                    child: const Icon(Icons.local_gas_station_rounded,
                        size: 34, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Belum Ada Catatan BBM',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Catat pengisian BBM untuk memantau\nkonsumsi dan biaya bahan bakar.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () async {
                      final fuelLogBloc = context.read<FuelLogBloc>();
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: fuelLogBloc,
                            child: AddFuelLogPage(vehicleId: vehicleId),
                          ),
                        ),
                      );
                      if (result == true && context.mounted) {
                        fuelLogBloc.add(LoadFuelLogs(vehicleId));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Catat BBM Pertama',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.text,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Catatan BBM',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.filter_list_rounded,
              color: AppColors.text,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(FuelStats stats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Total BBM',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tintBlueBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${stats.fillCount}x pengisian',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tintBlueFg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              Formatters.currency(stats.totalCost),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.52,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildKpiItem(
                    'TOTAL LITER',
                    Formatters.liters(stats.totalLiters),
                    null,
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.divider),
                Expanded(
                  child: _buildKpiItem(
                    'KONSUMSI AVG',
                    stats.avgConsumption > 0
                        ? Formatters.consumption(stats.avgConsumption)
                        : '-',
                    AppColors.primary,
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.divider),
                Expanded(
                  child: _buildKpiItem(
                    'PENGISIAN',
                    '${stats.fillCount}x',
                    null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiItem(String label, String value, Color? valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSoft,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartCard(List<MonthlyFuelData> monthlyData) {
    final now = DateTime.now();
    final maxLiters = monthlyData
        .map((m) => m.totalLiters)
        .fold(0.0, (a, b) => a > b ? a : b);
    const chartHeight = 120.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konsumsi BBM',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Liter per bulan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tintBlueBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${now.year}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tintBlueFg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: chartHeight + 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthlyData.map((m) {
                  final isActive =
                      m.month == now.month && m.year == now.year;
                  final barHeight = maxLiters > 0
                      ? (m.totalLiters / maxLiters) * chartHeight
                      : 0.0;
                  final displayHeight = m.totalLiters > 0
                      ? max(barHeight, 8.0)
                      : 8.0;
                  final displayValue = m.totalLiters > 0
                      ? Formatters.decimal(m.totalLiters)
                      : '0';

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            displayValue,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textSoft,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: displayHeight,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : (m.totalLiters > 0
                                      ? AppColors.primarySoft
                                      : AppColors.divider),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppColors.text
                                  : AppColors.textSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Text(
        'Riwayat Pengisian',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildFuelHistoryList(BuildContext context, List<FuelLogModel> logs) {
    // Sort by date descending for display
    final sorted = List<FuelLogModel>.from(logs)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Build a map of log id -> previous log (by date ascending) for distance calculation
    final ascending = List<FuelLogModel>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));
    final prevLogMap = <int?, FuelLogModel>{};
    for (int i = 1; i < ascending.length; i++) {
      prevLogMap[ascending[i].id] = ascending[i - 1];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: sorted
            .map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildFuelCard(context, log, prevLogMap[log.id]),
                ))
            .toList(),
      ),
    );
  }

  void _showFuelDetail(BuildContext context, FuelLogModel log) {
    final fuelLogBloc = context.read<FuelLogBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FuelLogDetailSheet(
        log: log,
        onDelete: () {
          if (log.id != null) {
            fuelLogBloc.add(DeleteFuelLog(log.id!, vehicleId));
          }
        },
      ),
    );
  }

  Widget _buildFuelCard(
      BuildContext context, FuelLogModel log, FuelLogModel? prevLog) {
    // Calculate distance and consumption
    final distance = prevLog != null ? log.odometer - prevLog.odometer : 0.0;
    final consumptionVal =
        (distance > 0 && log.liters > 0) ? distance / log.liters : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showFuelDetail(context, log),
        borderRadius: BorderRadius.circular(20),
        child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.tintPeachBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_gas_station_rounded,
                  color: AppColors.tintPeachFg,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            log.stationName ?? 'SPBU',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Text(
                          '-${Formatters.currency(log.totalCost)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${log.fuelType} · ${Formatters.date(log.date)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        Text(
                          '${Formatters.liters(log.liters)} · ${Formatters.currency(log.pricePerLiter)}/L',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'ODOMETER',
                    Formatters.odometer(log.odometer),
                    null,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'JARAK',
                    distance > 0 ? Formatters.odometer(distance) : '-',
                    null,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'KONSUMSI',
                    consumptionVal > 0
                        ? Formatters.consumption(consumptionVal)
                        : '-',
                    consumptionVal > 0 ? AppColors.success : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, Color? valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textSoft,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 88,
      child: GestureDetector(
        onTap: () async {
          final fuelLogBloc = context.read<FuelLogBloc>();
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: fuelLogBloc,
                child: AddFuelLogPage(vehicleId: vehicleId),
              ),
            ),
          );
          if (result == true && context.mounted) {
            fuelLogBloc.add(LoadFuelLogs(vehicleId));
          }
        },
        child: Container(
          height: 52,
          padding: const EdgeInsets.fromLTRB(18, 0, 20, 0),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                'Catat BBM',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────
class FuelLogDetailSheet extends StatelessWidget {
  final FuelLogModel log;
  final VoidCallback onDelete;

  const FuelLogDetailSheet({
    super.key,
    required this.log,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.tintPeachBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_gas_station_rounded,
                        color: AppColors.tintPeachFg, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.stationName ?? 'SPBU',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          '${log.fuelType} · ${Formatters.date(log.date)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Total cost hero
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primarySofter,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.primarySoft, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BIAYA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(log.totalCost),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Detail rows
              _detailRow('Tanggal', Formatters.date(log.date)),
              _detailRow('Odometer', Formatters.odometer(log.odometer)),
              _detailRow('Jumlah', Formatters.liters(log.liters)),
              _detailRow(
                'Harga / Liter',
                '${Formatters.currency(log.pricePerLiter)} / L',
              ),
              _detailRow('Jenis BBM', log.fuelType),
              _detailRow('Full Tank', log.isFullTank ? 'Ya' : 'Tidak'),
              if (log.stationName != null && log.stationName!.isNotEmpty)
                _detailRow('SPBU', log.stationName!),
              if (log.notes != null && log.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('CATATAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.4,
                    )),
                const SizedBox(height: 4),
                Text(
                  log.notes!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.text,
                  ),
                ),
              ],
              if (log.receiptImagePath != null) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(log.receiptImagePath!),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              // Delete button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(
                    'Hapus Catatan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Text(
            value,
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus catatan?',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Catatan pengisian BBM ini akan dihapus permanen.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dCtx, true),
            child: Text('Hapus',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      onDelete();
      Navigator.pop(context);
    }
  }
}
