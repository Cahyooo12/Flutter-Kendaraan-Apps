import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter_kendaraanku_app/data/models/fuel_log_model.dart';
import 'package:flutter_kendaraanku_app/data/models/service_log_model.dart';

class ExportHelper {
  /// Export fuel logs to CSV file, returns the file path
  static Future<String> exportFuelLogsCsv(
    List<FuelLogModel> logs,
    String vehicleName,
  ) async {
    final headers = [
      'Tanggal',
      'Odometer (km)',
      'Liter',
      'Harga/Liter',
      'Total',
      'Jenis BBM',
      'SPBU',
      'Full Tank',
      'Catatan',
    ];
    final rows = logs
        .map((l) => [
              l.date.toIso8601String().substring(0, 10),
              l.odometer.toString(),
              l.liters.toString(),
              l.pricePerLiter.toString(),
              l.totalCost.toString(),
              l.fuelType,
              l.stationName ?? '',
              l.isFullTank ? 'Ya' : 'Tidak',
              l.notes ?? '',
            ])
        .toList();

    final csvData = const ListToCsvConverter().convert([headers, ...rows]);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = vehicleName.replaceAll(' ', '_');
    final file = File('${dir.path}/bbm_${safeName}_$timestamp.csv');
    await file.writeAsString(csvData);
    return file.path;
  }

  /// Export service logs to CSV file, returns the file path
  static Future<String> exportServiceLogsCsv(
    List<ServiceLogModel> logs,
    String vehicleName,
  ) async {
    final headers = [
      'Tanggal',
      'Odometer (km)',
      'Jenis Servis',
      'Deskripsi',
      'Biaya',
      'Bengkel',
      'Catatan',
    ];
    final rows = logs
        .map((l) => [
              l.date.toIso8601String().substring(0, 10),
              l.odometer?.toString() ?? '',
              l.serviceType,
              l.description,
              l.cost.toString(),
              l.workshopName ?? '',
              l.notes ?? '',
            ])
        .toList();

    final csvData = const ListToCsvConverter().convert([headers, ...rows]);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = vehicleName.replaceAll(' ', '_');
    final file = File('${dir.path}/servis_${safeName}_$timestamp.csv');
    await file.writeAsString(csvData);
    return file.path;
  }

  /// Export full vehicle report as PDF, returns the file path
  static Future<String> exportVehicleReportPdf({
    required String vehicleName,
    required String plateNumber,
    required List<FuelLogModel> fuelLogs,
    required List<ServiceLogModel> serviceLogs,
  }) async {
    final pdf = pw.Document();

    final totalFuelCost =
        fuelLogs.fold(0.0, (sum, l) => sum + l.totalCost);
    final totalServiceCost =
        serviceLogs.fold(0.0, (sum, l) => sum + l.cost);
    final totalLiters =
        fuelLogs.fold(0.0, (sum, l) => sum + l.liters);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: 'Laporan Kendaraan - $vehicleName'),
          pw.Paragraph(text: 'Plat Nomor: $plateNumber'),
          pw.Paragraph(
            text:
                'Tanggal: ${DateTime.now().toString().substring(0, 10)}',
          ),
          pw.SizedBox(height: 20),

          // Summary
          pw.Header(level: 1, text: 'Ringkasan'),
          pw.Bullet(
            text:
                'Total BBM: ${fuelLogs.length} pengisian, ${totalLiters.toStringAsFixed(1)} liter',
          ),
          pw.Bullet(
            text:
                'Total Biaya BBM: Rp ${totalFuelCost.toStringAsFixed(0)}',
          ),
          pw.Bullet(
            text: 'Total Servis: ${serviceLogs.length} kali',
          ),
          pw.Bullet(
            text:
                'Total Biaya Servis: Rp ${totalServiceCost.toStringAsFixed(0)}',
          ),
          pw.Bullet(
            text:
                'Total Pengeluaran: Rp ${(totalFuelCost + totalServiceCost).toStringAsFixed(0)}',
          ),
          pw.SizedBox(height: 20),

          // Fuel logs table
          if (fuelLogs.isNotEmpty) ...[
            pw.Header(level: 1, text: 'Riwayat BBM'),
            pw.TableHelper.fromTextArray(
              headers: ['Tanggal', 'Odometer', 'Liter', 'Total'],
              data: fuelLogs
                  .map((l) => [
                        l.date.toString().substring(0, 10),
                        '${l.odometer.toStringAsFixed(0)} km',
                        '${l.liters.toStringAsFixed(1)} L',
                        'Rp ${l.totalCost.toStringAsFixed(0)}',
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Service logs table
          if (serviceLogs.isNotEmpty) ...[
            pw.Header(level: 1, text: 'Riwayat Servis'),
            pw.TableHelper.fromTextArray(
              headers: ['Tanggal', 'Jenis', 'Deskripsi', 'Biaya'],
              data: serviceLogs
                  .map((l) => [
                        l.date.toString().substring(0, 10),
                        l.serviceType,
                        l.description,
                        'Rp ${l.cost.toStringAsFixed(0)}',
                      ])
                  .toList(),
            ),
          ],
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = vehicleName.replaceAll(' ', '_');
    final file =
        File('${dir.path}/laporan_${safeName}_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
