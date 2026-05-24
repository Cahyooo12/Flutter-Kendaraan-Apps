import 'package:dartz/dartz.dart';
import 'package:flutter_kendaraanku_app/data/database_helper.dart';
import 'package:flutter_kendaraanku_app/data/models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();

  Future<Either<String, UserModel>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final db = await _dbHelper.database;

      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (existing.isNotEmpty) {
        return const Left('Email sudah terdaftar');
      }

      final now = DateTime.now();
      final id = await db.insert('users', {
        'name': name,
        'email': email,
        'password': password,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      final user = UserModel(
        id: id,
        name: name,
        email: email,
        password: password,
        createdAt: now,
        updatedAt: now,
      );
      return Right(user);
    } catch (e) {
      return Left('Gagal mendaftar: $e');
    }
  }

  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (results.isEmpty) {
        return const Left('Email atau kata sandi salah');
      }

      return Right(UserModel.fromMap(results.first));
    } catch (e) {
      return Left('Gagal masuk: $e');
    }
  }

  Future<Either<String, UserModel>> getUserById(int id) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
      if (results.isEmpty) return const Left('User tidak ditemukan');
      return Right(UserModel.fromMap(results.first));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  Future<Either<String, bool>> updateUser(UserModel user) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'users',
        user.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return const Right(true);
    } catch (e) {
      return Left('Gagal update: $e');
    }
  }
}
