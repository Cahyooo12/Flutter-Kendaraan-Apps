import 'package:dartz/dartz.dart';
import 'package:flutter_kendaraanku_app/data/database_helper.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_document_model.dart';

class VehicleDocumentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();

  Future<Either<String, List<VehicleDocumentModel>>> getByUser(
      int userId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.rawQuery('''
        SELECT vd.* FROM vehicle_documents vd
        INNER JOIN vehicles v ON vd.vehicle_id = v.id
        WHERE v.user_id = ?
        ORDER BY
          CASE WHEN vd.expiry_date IS NULL THEN 1 ELSE 0 END,
          vd.expiry_date ASC
      ''', [userId]);
      return Right(
          results.map((m) => VehicleDocumentModel.fromMap(m)).toList());
    } catch (e) {
      return Left('Gagal memuat dokumen: $e');
    }
  }

  Future<Either<String, List<VehicleDocumentModel>>> getByVehicle(
      int vehicleId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'vehicle_documents',
        where: 'vehicle_id = ?',
        whereArgs: [vehicleId],
        orderBy: 'expiry_date ASC',
      );
      return Right(
          results.map((m) => VehicleDocumentModel.fromMap(m)).toList());
    } catch (e) {
      return Left('Gagal memuat dokumen: $e');
    }
  }

  Future<Either<String, int>> add(VehicleDocumentModel doc) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert('vehicle_documents', doc.toMap());
      return Right(id);
    } catch (e) {
      return Left('Gagal menambah dokumen: $e');
    }
  }

  Future<Either<String, bool>> update(VehicleDocumentModel doc) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'vehicle_documents',
        doc.toMap(),
        where: 'id = ?',
        whereArgs: [doc.id],
      );
      return const Right(true);
    } catch (e) {
      return Left('Gagal update dokumen: $e');
    }
  }

  Future<Either<String, bool>> delete(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('vehicle_documents', where: 'id = ?', whereArgs: [id]);
      return const Right(true);
    } catch (e) {
      return Left('Gagal menghapus dokumen: $e');
    }
  }
}
