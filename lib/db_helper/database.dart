import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

import 'dao/network_dao.dart';
import 'models/network_model.dart';

part 'database.g.dart'; // Generated code

@Database(version: 1, entities: [NetworkModel])
abstract class AppDatabase extends FloorDatabase {
  NetworkDao get networkDao;
}
