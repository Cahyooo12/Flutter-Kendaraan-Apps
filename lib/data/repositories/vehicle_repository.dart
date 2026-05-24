import 'package:dartz/dartz.dart';
import 'package:flutter_kendaraanku_app/data/database_helper.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_model.dart';

class VehicleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();

  Future<Either<String, List<VehicleModel>>> getByUser(int userId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'vehicles',
        where: 'user_id = ? AND is_active = 1',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      return Right(results.map((m) => VehicleModel.fromMap(m)).toList());
    } catch (e) {
      return Left('Gagal memuat kendaraan: $e');
    }
  }

  Future<Either<String, VehicleModel>> getById(int id) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('vehicles', where: 'id = ?', whereArgs: [id]);
      if (results.isEmpty) return const Left('Kendaraan tidak ditemukan');
      return Right(VehicleModel.fromMap(results.first));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  Future<Either<String, int>> add(VehicleModel vehicle) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert('vehicles', vehicle.toMap());
      return Right(id);
    } catch (e) {
      return Left('Gagal menambah kendaraan: $e');
    }
  }

  Future<Either<String, bool>> update(VehicleModel vehicle) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'vehicles',
        vehicle.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [vehicle.id],
      );
      return const Right(true);
    } catch (e) {
      return Left('Gagal update kendaraan: $e');
    }
  }

  Future<Either<String, bool>> archive(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'vehicles',
        {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(true);
    } catch (e) {
      return Left('Gagal mengarsipkan: $e');
    }
  }
}
