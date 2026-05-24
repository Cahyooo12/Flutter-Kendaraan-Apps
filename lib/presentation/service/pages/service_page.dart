import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/utils/formatters.dart';
import 'package:flutter_kendaraanku_app/data/models/service_log_model.dart';
import 'package:flutter_kendaraanku_app/data/repositories/service_log_repository.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/service_log/service_log_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/service_log/service_log_event.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/service_log/service_log_state.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_state.dart';
import 'package:flutter_kendaraanku_app/presentation/service/pages/add_service_log_page.dart';
import 'package:flutter_kendaraanku_app/presentation/vehicle/pages/add_vehicle_page.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

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
              child: _NoVehicleEmpty(
                icon: Icons.build_rounded,
                tintBg: AppColors.tintMintBg,
                tintFg: AppColors.tintMintFg,
                title: 'Belum Ada Kendaraan',
                subtitle:
                    'Tambahkan kendaraan dulu untuk mulai\nmencatat riwayat servis.',
                ctaLabel: 'Tambah Kendaraan',
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
              ),
            ),
          );
        }

        return BlocProvider(
          create: (context) => ServiceLogBloc(ServiceLogRepository())
            ..add(LoadServiceLogs(vehicleId!)),
          child: _ServicePageContent(vehicleId: vehicleId),
        );
      },
    );
  }
}

class _NoVehicleEmpty extends StatelessWidget {
  final IconData icon;
  final Color tintBg;
  final Color tintFg;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onTap;

  const _NoVehicleEmpty({
    required this.icon,
    required this.tintBg,
    required this.tintFg,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: tintBg,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, color: tintFg, size: 42),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
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
                      ctaLabel,
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
    );
  }
}

class _ServicePageContent extends StatelessWidget {
  final int vehicleId;
  const _ServicePageContent({required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          BlocBuilder<ServiceLogBloc, ServiceLogState>(
            builder: (context, state) {
              if (state is ServiceLogLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ServiceLogError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
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
                              .read<ServiceLogBloc>()
                              .add(LoadServiceLogs(vehicleId)),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is ServiceLogLoaded) {
                if (state.logs.isEmpty && state.activeFilter == null) {
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
                      _buildSummaryHeroCard(state.stats),
                      _buildFilterChips(context, state.stats, state.activeFilter),
                      _buildTimelineList(context, state.logs),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }
              // ServiceLogInitial
              return const Center(child: CircularProgressIndicator());
            },
          ),
          // App bar always visible during loading/empty
          BlocBuilder<ServiceLogBloc, ServiceLogState>(
            buildWhen: (prev, curr) => false,
            builder: (context, state) {
              if (state is ServiceLogLoaded && (state.logs.isNotEmpty || state.activeFilter != null)) {
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
                    child: const Icon(Icons.build_rounded,
                        size: 34, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Belum Ada Catatan Servis',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Catat ganti oli, ban, tune up,\ndan perawatan kendaraanmu lainnya.',
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
                      final serviceLogBloc = context.read<ServiceLogBloc>();
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: serviceLogBloc,
                            child: AddServiceLogPage(vehicleId: vehicleId),
                          ),
                        ),
                      );
                      if (result == true && context.mounted) {
                        serviceLogBloc.add(LoadServiceLogs(vehicleId));
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
                            'Catat Servis Pertama',
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
            const SizedBox(height: 22),
            Text(
              'Contoh kategori servis',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                'Ganti Oli Mesin',
                'Tune Up',
                'Ganti Ban',
                'Servis AC',
                'Ganti Aki',
              ].map((label) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              }).toList(),
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
              'Riwayat Servis',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryHeroCard(ServiceStats stats) {
    final year = DateTime.now().year;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Biaya Servis $year',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.currency(stats.totalCost),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildHeroStat(
                            'Servis',
                            '${stats.serviceCount} kali',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                        Expanded(
                          child: _buildHeroStat(
                            'Rata-rata',
                            Formatters.currency(stats.avgCost),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                        Expanded(
                          child: _buildHeroStat(
                            'Kategori',
                            '${stats.categoryCounts.length} jenis',
                          ),
                        ),
                      ],
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

  Widget _buildHeroStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    ServiceStats stats,
    String? activeFilter,
  ) {
    final totalCount = stats.categoryCounts.values.fold(0, (a, b) => a + b);
    final categories = stats.categoryCounts.keys.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 14),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length + 1, // +1 for "Semua"
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              // "Semua" chip
              final isActive = activeFilter == null;
              return GestureDetector(
                onTap: () {
                  if (!isActive) {
                    context
                        .read<ServiceLogBloc>()
                        .add(FilterByCategory(vehicleId, null));
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.text : AppColors.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: isActive
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Semua · $totalCount',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }

            final category = categories[index - 1];
            final isActive = activeFilter == category;
            return GestureDetector(
              onTap: () {
                context
                    .read<ServiceLogBloc>()
                    .add(FilterByCategory(vehicleId, category));
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.text : AppColors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border:
                      isActive ? null : Border.all(color: AppColors.border),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimelineList(BuildContext context, List<ServiceLogModel> logs) {
    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Center(
          child: Text(
            'Tidak ada catatan untuk filter ini',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    // Sort by date descending
    final sorted = List<ServiceLogModel>.from(logs)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group by month
    final grouped = <String, List<ServiceLogModel>>{};
    for (final log in sorted) {
      final key = Formatters.monthYear(log.date);
      grouped.putIfAbsent(key, () => []).add(log);
    }

    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      widgets.add(_buildMonthHeader(entry.key));
      widgets.add(const SizedBox(height: 10));
      for (int i = 0; i < entry.value.length; i++) {
        widgets.add(_buildServiceCard(context, entry.value[i]));
        if (i < entry.value.length - 1) {
          widgets.add(const SizedBox(height: 10));
        }
      }
      widgets.add(const SizedBox(height: 20));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _buildMonthHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.44,
      ),
    );
  }

  Color _iconBgForType(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'reparasi':
        return AppColors.tintRoseBg;
      case 'sparepart':
        return AppColors.tintPeachBg;
      default:
        return AppColors.tintMintBg;
    }
  }

  Color _iconFgForType(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'reparasi':
        return AppColors.tintRoseFg;
      case 'sparepart':
        return AppColors.tintPeachFg;
      default:
        return AppColors.tintMintFg;
    }
  }

  IconData _iconForType(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'reparasi':
        return Icons.warning_rounded;
      case 'sparepart':
        return Icons.bolt_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  void _showServiceDetail(BuildContext context, ServiceLogModel log) {
    final serviceLogBloc = context.read<ServiceLogBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServiceLogDetailSheet(
        log: log,
        onDelete: () {
          if (log.id != null) {
            serviceLogBloc.add(DeleteServiceLog(log.id!, vehicleId));
          }
        },
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceLogModel log) {
    final iconBg = _iconBgForType(log.serviceType);
    final iconColor = _iconFgForType(log.serviceType);
    final icon = _iconForType(log.serviceType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showServiceDetail(context, log),
        borderRadius: BorderRadius.circular(20),
        child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
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
                            log.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Text(
                          Formatters.currency(log.cost),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      log.workshopName ?? '-',
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
          const SizedBox(height: 10),
          // Meta tags row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.date(log.date),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      size: 11,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      log.odometer != null
                          ? Formatters.odometer(log.odometer!)
                          : '-',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (log.notes != null && log.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Item: ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    TextSpan(
                      text: log.notes!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 88,
      child: GestureDetector(
        onTap: () async {
          final serviceLogBloc = context.read<ServiceLogBloc>();
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: serviceLogBloc,
                child: AddServiceLogPage(vehicleId: vehicleId),
              ),
            ),
          );
          if (result == true && context.mounted) {
            serviceLogBloc.add(LoadServiceLogs(vehicleId));
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
                'Tambah Servis',
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
class ServiceLogDetailSheet extends StatelessWidget {
  final ServiceLogModel log;
  final VoidCallback onDelete;

  const ServiceLogDetailSheet({
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.tintMintBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.build_rounded,
                          color: AppColors.tintMintFg, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            '${log.serviceType} · ${Formatters.date(log.date)}',
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primarySofter,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.primarySoft, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BIAYA SERVIS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.currency(log.cost),
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
                _detailRow('Tanggal', Formatters.date(log.date)),
                _detailRow('Jenis Servis', log.serviceType),
                if (log.workshopName != null && log.workshopName!.isNotEmpty)
                  _detailRow('Bengkel', log.workshopName!),
                if (log.odometer != null)
                  _detailRow('Odometer', Formatters.odometer(log.odometer!)),
                if (log.nextServiceOdometer != null)
                  _detailRow('Servis berikutnya (km)',
                      Formatters.odometer(log.nextServiceOdometer!)),
                if (log.nextServiceDate != null)
                  _detailRow('Servis berikutnya (tgl)',
                      Formatters.date(log.nextServiceDate!)),
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
          'Catatan servis ini akan dihapus permanen.',
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
