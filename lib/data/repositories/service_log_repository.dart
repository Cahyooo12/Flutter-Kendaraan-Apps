import 'package:dartz/dartz.dart';
import 'package:flutter_kendaraanku_app/data/database_helper.dart';
import 'package:flutter_kendaraanku_app/data/models/service_log_model.dart';

class ServiceLogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();

  Future<Either<String, List<ServiceLogModel>>> getByVehicle(int vehicleId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'service_logs',
        where: 'vehicle_id = ?',
        whereArgs: [vehicleId],
        orderBy: 'date DESC',
      );
      return Right(results.map((m) => ServiceLogModel.fromMap(m)).toList());
    } catch (e) {
      return Left('Gagal memuat riwayat servis: $e');
    }
  }

  Future<Either<String, List<ServiceLogModel>>> getByCategory(
    int vehicleId,
    String category,
  ) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'service_logs',
        where: 'vehicle_id = ? AND service_type = ?',
        whereArgs: [vehicleId, category],
        orderBy: 'date DESC',
      );
      return Right(results.map((m) => ServiceLogModel.fromMap(m)).toList());
    } catch (e) {
      return Left('Gagal memuat data: $e');
    }
  }

  Future<Either<String, int>> add(ServiceLogModel serviceLog) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert('service_logs', serviceLog.toMap());
      return Right(id);
    } catch (e) {
      return Left('Gagal menambah catatan servis: $e');
    }
  }

  Future<Either<String, bool>> update(ServiceLogModel serviceLog) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'service_logs',
        serviceLog.toMap(),
        where: 'id = ?',
        whereArgs: [serviceLog.id],
      );
      return const Right(true);
    } catch (e) {
      return Left('Gagal update: $e');
    }
  }

  Future<Either<String, bool>> delete(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('service_logs', where: 'id = ?', whereArgs: [id]);
      return const Right(true);
    } catch (e) {
      return Left('Gagal menghapus: $e');
    }
  }

  Future<Either<String, List<ServiceLogModel>>> getUpcomingReminders(int userId) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now().toIso8601String();
      final results = await db.rawQuery('''
        SELECT sl.* FROM service_logs sl
        INNER JOIN vehicles v ON sl.vehicle_id = v.id
        WHERE v.user_id = ? AND v.is_active = 1
        AND sl.next_service_date IS NOT NULL
        AND sl.next_service_date >= ?
        ORDER BY sl.next_service_date ASC
        LIMIT 10
      ''', [userId, now]);
      return Right(results.map((m) => ServiceLogModel.fromMap(m)).toList());
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
