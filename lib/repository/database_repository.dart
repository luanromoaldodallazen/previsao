import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:previsao_tempo/models/location_model.dart';

class DatabaseRepository {
  static final DatabaseRepository _instance =
      DatabaseRepository._internal();

  factory DatabaseRepository() => _instance;

  DatabaseRepository._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), "previsao_tempo.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE location(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL,
            longitude REAL
          )
        """);
      },
    );
  }

  Future<void> salvarLocalizacao(LocationModel location) async {
    final db = await database;

    final resultado = await db.query("location");

    if (resultado.isEmpty) {
      await db.insert(
        "location",
        location.toMap(),
      );
    } else {
      await db.update(
        "location",
        location.toMap(),
        where: "id = ?",
        whereArgs: [resultado.first["id"]],
      );
    }
  }

  Future<LocationModel?> buscarLocalizacao() async {
    final db = await database;

    final resultado = await db.query("location");

    if (resultado.isEmpty) {
      return null;
    }

    return LocationModel.fromMap(resultado.first);
  }

  Future<void> limparLocalizacao() async {
    final db = await database;
    await db.delete("location");
  }
}
