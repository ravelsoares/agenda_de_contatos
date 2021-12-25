//import 'dart:html';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = 'contactTable';
final String idColumn = 'idColumn';
final String nameColumn = 'nameColumn';
final String emailColumn = 'emailColumn';
final String phoneColumn = 'phoneColumn';
final String imgColumn = 'imgColumn';

class ContactHelper {
  //Essa classe só terá uma instância
  static final ContactHelper _instance = ContactHelper.internal();
  //Factory vai retornar uma instância
  factory ContactHelper() => _instance;
  //Construtor interno
  ContactHelper.internal();

  Database? _bd;
  Future<Database> get bd async {
    if (_bd != null) {
      return _bd!;
    } else {
      _bd = await initBd();
      return _bd!;
    }
  }

  Future<Database> initBd() async {
    final databasesPath = await getDatabasesPath();
    //Definindo o caminho do banco de dados
    final path = join(databasesPath, 'contact.bd');
    return await openDatabase(path, version: 1,
        onCreate: (Database bd, int newerVersion) async {
      await bd.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)",
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database bdContact = await bd;
    contact.id = await bdContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database bdContact = await bd;
    List<Map> maps = await bdContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: '$idColumn = ?',
        whereArgs: [id]);

    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database bdContact = await bd;
    return await bdContact
        .delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    var bdContact = await bd;
    return await bdContact.update(contactTable, contact.toMap(),
        where: '$idColumn= ?', whereArgs: [contact.id]);
  }

  Future<List<Contact>> getAllContacts() async {
    Database bdContact = await bd;
    List listMap = await bdContact.rawQuery(' SELECT * FROM $contactTable');
    List<Contact> listContacts = [];
    for (Map m in listMap) {
      listContacts.add(Contact.fromMap(m));
    }
    return listContacts;
  }

  Future<int> getNumber() async {
    Database bdContact = await bd;
    return Sqflite.firstIntValue(
        await bdContact.rawQuery('SELECT COUNT(*) FROM $contactTable'))!;
  }
}

class Contact {
  late int id;
  late String name;
  late String email;
  late String phone;
  String img = 'assets/person.png';

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'Contact(name: $name, email: $email, phone: $phone, img: $img)';
  }
}
