import 'package:sqflite/sqflite.dart'
    as sqflite; // <-- Import sqflite with a prefix to avoid name collision
import 'package:path/path.dart';
import 'package:warung_app1/Tugas_13/model/product.dart';
import 'package:warung_app1/Tugas_13/model/transaction.dart';
import 'package:warung_app1/Tugas_13/model/user_model.dart';
import 'package:warung_app1/Tugas_13/model/cart_item.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;

  static sqflite.Database? _database; // Use sqflite.Database

  DbHelper._internal();

  Future<sqflite.Database> get database async {
    // Use sqflite.Database
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<sqflite.Database> _initDb() async {
    // Use sqflite.Database
    String dbPath =
        await sqflite.getDatabasesPath(); // Use sqflite.getDatabasesPath()
    String path = join(dbPath, 'tokohp.db');

    // IMPORTANT: If you change the database schema (add/modify tables/columns),
    // you need to increment the version number (e.g., from 1 to 2).
    // Alternatively, for development, you can uninstall the app from your emulator/device
    // and reinstall it to force _onCreate to run again.
    return await sqflite.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    ); // Use sqflite.openDatabase
  }

  Future<void> _onCreate(sqflite.Database db, int version) async {
    // Use sqflite.Database
    // Table: Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Table: Products
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

    // Table: Cart
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL UNIQUE,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');

    // Table: Transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionDate TEXT NOT NULL,
        totalAmount REAL NOT NULL, -- REAL for double values
        status TEXT NOT NULL -- e.g., 'Success' or 'Cancelled'
      )
    ''');

    // Table: Transaction Items (details of each item within a transaction)
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        itemPrice REAL NOT NULL, -- REAL to store the item's price at the time of transaction
        FOREIGN KEY (transactionId) REFERENCES transactions (id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- USER FUNCTIONS ---

  Future<int> registerUser(User user) async {
    final db = await database;
    try {
      return await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.fail,
      );
    } catch (e) {
      print('Error registering user: $e');
      return -1; // Indicate failure
    }
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

  Future<List<User>> getUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((e) => User.fromMap(e)).toList();
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // --- PRODUCT FUNCTIONS ---

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'id DESC');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<Product?> getProductById(int productId) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
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

  // --- CART FUNCTIONS ---

  Future<int> insertCartItem(CartItem item) async {
    final db = await database;
    final existingItem = await db.query(
      'cart',
      where: 'productId = ?',
      whereArgs: [item.product.id],
    );

    if (existingItem.isNotEmpty) {
      int currentQuantity = (existingItem.first['quantity'] as num).toInt();
      int newQuantity = currentQuantity + item.quantity;
      return await db.update(
        'cart',
        {'quantity': newQuantity},
        where: 'productId = ?',
        whereArgs: [item.product.id],
      );
    } else {
      return await db.insert('cart', {
        'productId': item.product.id,
        'quantity': item.quantity,
      });
    }
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final result = await db.query('cart');
    List<CartItem> cartItems = [];
    for (var map in result) {
      final productId = (map['productId'] as num).toInt();
      final quantity = (map['quantity'] as num).toInt();

      final product = await getProductById(productId);
      if (product != null) {
        cartItems.add(
          CartItem(
            product: product,
            quantity: quantity,
            isSelected: true, // Default to true when loaded from DB
          ),
        );
      }
    }
    return cartItems;
  }

  Future<int> updateCartItem(CartItem item) async {
    final db = await database;
    return await db.update(
      'cart',
      {'quantity': item.quantity},
      where: 'productId = ?',
      whereArgs: [item.product.id],
    );
  }

  Future<int> deleteCartItem(int productId) async {
    final db = await database;
    return await db.delete(
      'cart',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  // --- TRANSACTION FUNCTIONS ---

  Future<int> insertTransaction(Transaction transaction) async {
    // This 'Transaction' is your custom model
    final db = await database;
    return await db.transaction((sqflite.Transaction txn) async {
      // Use sqflite.Transaction for the database transaction object
      int transactionId = await txn.insert('transactions', transaction.toMap());

      for (var item in transaction.items) {
        await txn.insert('transaction_items', {
          'transactionId': transactionId,
          'productId': item.product.id,
          'quantity': item.quantity,
          'itemPrice': item.itemPrice,
        });
      }
      return transactionId;
    });
  }

  Future<List<Transaction>> getAllTransactions() async {
    // This 'Transaction' is your custom model
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'transactions',
      orderBy: 'transactionDate DESC',
    );
    List<Transaction> transactions = [];

    for (var tMap in transactionMaps) {
      final transactionId = tMap['id'] as int;
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'transaction_items',
        where: 'transactionId = ?',
        whereArgs: [transactionId],
      );

      List<TransactionItem> transactionItems = [];
      for (var iMap in itemMaps) {
        final productId = (iMap['productId'] as num).toInt();
        final product = await getProductById(productId);
        if (product != null) {
          transactionItems.add(TransactionItem.fromMap(iMap, product));
        } else {
          print(
            'Warning: Product with ID $productId not found for transaction item in transaction $transactionId.',
          );
        }
      }
      transactions.add(Transaction.fromMap(tMap, transactionItems));
    }
    return transactions;
  }

  // --- UTILITY FUNCTIONS ---

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('products');
    await db.delete('users');
    await db.delete('cart');
    await db.delete('transaction_items'); // Delete detail items first
    await db.delete('transactions'); // Then delete the main transactions
  }
}
