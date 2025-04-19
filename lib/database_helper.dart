import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'music_favorites.db';
  static const _databaseVersion = 1;
  static const table = 'favorites';
  static const columnId = '_id';
  static const columnSongName = 'songName';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnSongName TEXT NOT NULL
      )
    ''');
  }

  Future<int> addFavorite(String songName) async {
    final db = await database;
    return await db.insert(table, {columnSongName: songName});
  }

  Future<List<String>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);

    return List.generate(maps.length, (i) {
      return maps[i][columnSongName];
    });
  }

  Future<void> removeFavorite(String songName) async {
    final db = await database;
    await db.delete(
      table,
      where: '$columnSongName = ?',
      whereArgs: [songName],
    );
  }
}
