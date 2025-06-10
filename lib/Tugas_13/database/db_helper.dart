import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:warung_app1/Tugas_13/model/product.dart';
import 'package:warung_app1/Tugas_13/model/user_model.dart';
class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;

  static Database? _database;

  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'tokohp.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Tabel Products
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        brand TEXT NOT NULL,
        price INTEGER NOT NULL,
        stock INTEGER NOT NULL,
        image TEXT
      )
    ''');
  }

  // =======================
  // USER FUNCTIONS
  // =======================

  Future<int> registerUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // =======================
  // PRODUCT FUNCTIONS
  // =======================

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'id DESC');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // OPTIONAL: Hapus semua data (untuk reset/debug)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('products');
    await db.delete('users');
  }
//   Future<void> resetDatabase() async {
//     String dbPath = await getDatabasesPath();
//     String path = join(dbPath, 'tokohp.db');
//     await deleteDatabase(path);
//     print("✅ Database berhasil dihapus.");
//   }
}
