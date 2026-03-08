import 'package:sqflite_common_ffi/sqflite_ffi.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> initDatabase() async {
  databaseFactory = databaseFactoryFfiWeb;
}
