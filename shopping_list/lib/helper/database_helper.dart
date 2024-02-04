import 'package:listcom/constant/app_constants.dart';
import 'package:listcom/model/shopping_item.dart';
import 'package:listcom/model/shopping_list.dart';
import 'package:listcom/model/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('shopping_list.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(path, version: 6, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
  create table ${AppConstants.users} ( 
    ${AppConstants.id} integer primary key autoincrement, 
    ${AppConstants.email} text not null,
    ${AppConstants.passwordHash} text not null,
    ${AppConstants.name} text not null
    )
''');

    await db.execute('''
  create table ${AppConstants.lists} ( 
    ${AppConstants.id} integer primary key autoincrement, 
    ${AppConstants.name} text not null,
    ${AppConstants.userIdList} text,
    ${AppConstants.uniqueCode} text not null
    )
''');

    await db.execute('''
  create table ${AppConstants.listItems} ( 
    ${AppConstants.id} integer primary key autoincrement, 
    ${AppConstants.title} text not null,
    ${AppConstants.listId} integer not null,
    ${AppConstants.isDone} integer not null
    )
''');
  }

  // Yeni bir liste eklemek için
  Future<int> insertList(ShoppingList list) async {
    return await _database!.insert(AppConstants.lists, list.toMap());
  }

  // Tüm listeleri okumak için
  Future<List<ShoppingList>> getLists(int userId) async {
    var db = await database;
    List<Map<String, dynamic>> maps = await db.query(AppConstants.lists);

    var list = List.generate(maps.length, (i) {
      return ShoppingList.fromMap(maps[i]);
    });

    return list
        .where((element) => element.userIdList.contains(userId))
        .toList();
  }

  // Belirli bir liste güncellemek için
  Future<int> updateList(ShoppingList list) async {
    var db = await database;

    return await db.update(AppConstants.lists, list.toMap(),
        where: '${AppConstants.id} = ?', whereArgs: [list.id]);
  }

  // Bir listeyi silmek için
  Future<int> deleteList(int id) async {
    var db = await database;

    return await db.delete(AppConstants.lists,
        where: '${AppConstants.id} = ?', whereArgs: [id]);
  }

  // Yeni bir öğe eklemek için
  Future<int> insertItem(ShoppingItem item) async {
    var db = await database;

    return await db.insert(AppConstants.listItems, item.toMap());
  }

  // Belirli bir listeye ait tüm öğeleri okumak için
  Future<List<ShoppingItem>> getItems(int listId) async {
    var db = await database;

    List<Map<String, dynamic>> maps = await db.query(AppConstants.listItems,
        where: '${AppConstants.listId} = ?', whereArgs: [listId]);
    return List.generate(maps.length, (i) {
      return ShoppingItem.fromMap(maps[i]);
    });
  }

  // Bir öğeyi güncellemek için
  Future<int> updateItem(ShoppingItem item) async {
    var db = await database;

    return await db.update(AppConstants.listItems, item.toMap(),
        where: '${AppConstants.id} = ?', whereArgs: [item.id]);
  }

  // Bir öğeyi silmek için
  Future<int> deleteItem(int id) async {
    var db = await database;

    return await db.delete(AppConstants.listItems,
        where: '${AppConstants.id} = ?', whereArgs: [id]);
  }

  Future<int> insertUser(User user) async {
    var db = await database;

    return await db.insert(AppConstants.users, user.toMap());
  }

  Future<void> insertUserToList(ShoppingList list, int userId) async {
    var db = await database;
    var newUserIdList = list.userIdList..add(userId);

    var newShoppingList = ShoppingList(
        id: list.id,
        name: list.name,
        uniqueCode: list.uniqueCode,
        userIdList: newUserIdList);

    await db.update(AppConstants.lists, newShoppingList.toMap(),
        where: '${AppConstants.id} = ?', whereArgs: [newShoppingList.id]);
  }

  Future<User?> getUserByEmail(String email) async {
    var db = await database;
    List<Map<String, dynamic>> maps = (await db.query(AppConstants.users,
            where: '${AppConstants.email} = ?', whereArgs: [email]))
        ;

    return maps.isEmpty ? null : User.fromMap(maps.single);
  }
}
