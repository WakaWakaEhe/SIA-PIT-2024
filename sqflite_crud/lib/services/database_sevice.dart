import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tasksTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _getDatabase();
    return _db!;
  }

  Future<Database> _getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tasksTableName (
            $_tasksIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
            $_tasksContentColumnName TEXT NOT NULL,
            $_tasksStatusColumnName INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> addTask(String content) async {
    final db = await database;

    await db.insert(
      _tasksTableName,
      {
        _tasksContentColumnName: content,
        _tasksStatusColumnName: 0,
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(_tasksTableName);

    return data.map((e) {
      return Task(
        id: e[_tasksIdColumnName] as int,
        content: e[_tasksContentColumnName] as String,
        status: e[_tasksStatusColumnName] as int,
      );
    }).toList();
  }

  void updateTaskStaus(int id, int status) async {
    final db = await database;
    await db.update(
      _tasksTableName,
      {
        _tasksStatusColumnName: status,
      },
      where: 'id = ?',
      whereArgs: [
        id,
      ]
    );
  }

  void deleteTask(
    int id,
  ) async {
    final db = await database;
    await db.delete(
      _tasksTableName,
      where: 'id = ?',
      whereArgs: [
        id,
      ]
    );
  }
}
