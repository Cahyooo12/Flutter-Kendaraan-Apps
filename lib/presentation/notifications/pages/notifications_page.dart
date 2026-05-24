import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/utils/formatters.dart';
import 'package:flutter_kendaraanku_app/data/local/auth_local_datasource.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_model.dart';
import 'package:flutter_kendaraanku_app/data/repositories/fuel_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/service_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_document_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_repository.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Future<_NotifData> _loadNotifications() async {
    final userId = await AuthLocalDatasource().getUserId();
    if (userId == null) return _NotifData([], []);

    final vehicleRepo = VehicleRepository();
    final fuelRepo = FuelLogRepository();
    final serviceRepo = ServiceLogRepository();
    final documentRepo = VehicleDocumentRepository();

    final vehiclesResult = await vehicleRepo.getByUser(userId);
    final vehicles =
        vehiclesResult.fold((l) => <VehicleModel>[], (r) => r);

    final reminders = <_ReminderNotif>[];
    final activities = <_ActivityNotif>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final v in vehicles) {
      final serviceResult = await serviceRepo.getByVehicle(v.id!);
      serviceResult.fold((l) => null, (logs) {
        for (final log in logs) {
          if (log.nextServiceDate != null &&
              !log.nextServiceDate!.isBefore(today)) {
            reminders.add(_ReminderNotif(
              kind: _ReminderKind.service,
              title: log.description,
              vehicleName: v.name,
              dueDate: log.nextServiceDate!,
              daysUntil:
                  log.nextServiceDate!.difference(today).inDays,
            ));
          }
          activities.add(_ActivityNotif(
            type: 'service',
            title: log.description,
            subtitle:
                '${log.workshopName ?? v.name} · ${Formatters.date(log.date)}',
            amount: log.cost,
            date: log.date,
          ));
        }
      });

      final fuelResult = await fuelRepo.getByVehicle(v.id!);
      fuelResult.fold((l) => null, (logs) {
        for (final log in logs) {
          activities.add(_ActivityNotif(
            type: 'fuel',
            title: 'Isi BBM ${log.fuelType}',
            subtitle:
                '${log.stationName ?? v.name} · ${Formatters.date(log.date)}',
            amount: log.totalCost,
            date: log.date,
          ));
        }
      });
    }

    final vehicleNameById = {
      for (final v in vehicles)
        if (v.id != null) v.id!: v.name,
    };
    final docResult = await documentRepo.getByUser(userId);
    docResult.fold((l) => null, (docs) {
      for (final d in docs) {
        if (d.expiryDate == null) continue;
        final days = d.expiryDate!.difference(today).inDays;
        if (days < 0 || days > 30) continue;
        reminders.add(_ReminderNotif(
          kind: _ReminderKind.document,
          title: d.documentType,
          vehicleName: vehicleNameById[d.vehicleId] ?? 'Kendaraan',
          dueDate: d.expiryDate!,
          daysUntil: days,
        ));
      }
    });

    reminders.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    activities.sort((a, b) => b.date.compareTo(a.date));

    return _NotifData(reminders, activities.take(10).toList());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: FutureBuilder<_NotifData>(
                  future: _loadNotifications(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    final data = snapshot.data!;
                    if (data.reminders.isEmpty && data.activities.isEmpty) {
                      return _buildEmptyState();
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.reminders.isNotEmpty) ...[
                            _buildSectionHeader('PENGINGAT JATUH TEMPO'),
                            ...data.reminders
                                .map((r) => _buildReminderCard(r)),
                            const SizedBox(height: 8),
                          ],
                          if (data.activities.isNotEmpty) ...[
                            _buildSectionHeader('AKTIVITAS TERBARU'),
                            ...data.activities
                                .map((a) => _buildActivityCard(a)),
                          ],
                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notifikasi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Tenang, Semua Aman',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada pengingat servis maupun\naktivitas terbaru untuk ditampilkan.',
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
          const SizedBox(height: 22),
          Text(
            'Apa yang akan muncul di sini',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          _hintRow(
            icon: Icons.event_repeat_rounded,
            tintBg: AppColors.tintRoseBg,
            tintFg: AppColors.tintRoseFg,
            title: 'Pengingat servis',
            subtitle: 'Berdasarkan tanggal servis berikutnya',
          ),
          const SizedBox(height: 8),
          _hintRow(
            icon: Icons.local_gas_station_rounded,
            tintBg: AppColors.tintPeachBg,
            tintFg: AppColors.tintPeachFg,
            title: 'Aktivitas BBM',
            subtitle: 'Catatan pengisian terbaru',
          ),
          const SizedBox(height: 8),
          _hintRow(
            icon: Icons.build_rounded,
            tintBg: AppColors.tintMintBg,
            tintFg: AppColors.tintMintFg,
            title: 'Aktivitas servis',
            subtitle: 'Catatan perawatan terbaru',
          ),
        ],
      ),
    );
  }

  Widget _hintRow({
    required IconData icon,
    required Color tintBg,
    required Color tintFg,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tintBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: tintFg),
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 1),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.44,
        ),
      ),
    );
  }

  Widget _buildReminderCard(_ReminderNotif reminder) {
    final isUrgent = reminder.daysUntil <= 7;
    final Color tintBg = isUrgent ? AppColors.tintRoseBg : AppColors.tintAmberBg;
    final Color tintFg = isUrgent ? AppColors.tintRoseFg : AppColors.tintAmberFg;
    final IconData icon = reminder.kind == _ReminderKind.document
        ? Icons.description_outlined
        : Icons.build_outlined;
    final String prefix =
        reminder.kind == _ReminderKind.document ? 'Dokumen: ' : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primarySofter,
          border: Border.all(color: AppColors.primarySoft),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: tintBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: tintFg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                '$prefix${reminder.title}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUrgent) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'URGEN',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        reminder.daysUntil == 0
                            ? 'Hari ini'
                            : reminder.daysUntil == 1
                                ? 'Besok'
                                : '${reminder.daysUntil} hari',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: tintFg,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reminder.vehicleName} · ${Formatters.date(reminder.dueDate)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.45,
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

  Widget _buildActivityCard(_ActivityNotif activity) {
    final bool isFuel = activity.type == 'fuel';
    final Color tintBg =
        isFuel ? AppColors.tintPeachBg : AppColors.tintMintBg;
    final Color tintFg =
        isFuel ? AppColors.tintPeachFg : AppColors.tintMintFg;
    final IconData icon =
        isFuel ? Icons.local_gas_station_outlined : Icons.build_outlined;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: tintBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: tintFg),
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
                          activity.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.timeAgo(activity.date),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.currency(activity.amount),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: tintFg,
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
}

class _NotifData {
  final List<_ReminderNotif> reminders;
  final List<_ActivityNotif> activities;

  _NotifData(this.reminders, this.activities);
}

enum _ReminderKind { service, document }

class _ReminderNotif {
  final _ReminderKind kind;
  final String title;
  final String vehicleName;
  final DateTime dueDate;
  final int daysUntil;

  _ReminderNotif({
    required this.kind,
    required this.title,
    required this.vehicleName,
    required this.dueDate,
    required this.daysUntil,
  });
}

class _ActivityNotif {
  final String type;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;

  _ActivityNotif({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
  });
}
