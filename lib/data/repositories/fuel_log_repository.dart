import 'package:dartz/dartz.dart';
import 'package:flutter_kendaraanku_app/data/database_helper.dart';
import 'package:flutter_kendaraanku_app/data/models/fuel_log_model.dart';

class FuelLogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();

  Future<Either<String, List<FuelLogModel>>> getByVehicle(int vehicleId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'fuel_logs',
        where: 'vehicle_id = ?',
        whereArgs: [vehicleId],
        orderBy: 'date DESC',
      );
      return Right(results.map((m) => FuelLogModel.fromMap(m)).toList());
    } catch (e) {
      return Left('Gagal memuat catatan BBM: $e');
    }
  }

  Future<Either<String, List<FuelLogModel>>> getByDateRange(
    int vehicleId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'fuel_logs',
        where: 'vehicle_id = ? AND date >= ? AND date <= ?',
        whereArgs: [vehicleId, start.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC',
      );
      return Right(results.map((m) => FuelLogModel.fromMap(m)).toList());
    } catch (e) {
      return Left('Gagal memuat data: $e');
    }
  }

  Future<Either<String, int>> add(FuelLogModel fuelLog) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert('fuel_logs', fuelLog.toMap());
      return Right(id);
    } catch (e) {
      return Left('Gagal menambah catatan BBM: $e');
    }
  }

  Future<Either<String, bool>> update(FuelLogModel fuelLog) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'fuel_logs',
        fuelLog.toMap(),
        where: 'id = ?',
        whereArgs: [fuelLog.id],
      );
      return const Right(true);
    } catch (e) {
      return Left('Gagal update: $e');
    }
  }

  Future<Either<String, bool>> delete(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('fuel_logs', where: 'id = ?', whereArgs: [id]);
      return const Right(true);
    } catch (e) {
      return Left('Gagal menghapus: $e');
    }
  }

  Future<Either<String, double>> getLatestOdometer(int vehicleId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT MAX(odometer) as max_odo FROM fuel_logs WHERE vehicle_id = ?',
        [vehicleId],
      );
      final maxOdo = result.first['max_odo'];
      return Right(maxOdo != null ? (maxOdo as num).toDouble() : 0.0);
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
