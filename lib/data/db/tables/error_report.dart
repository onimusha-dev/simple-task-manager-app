import 'package:drift/drift.dart';
// import 'dart:convert';
// import 'package:crypto/crypto.dart';

// String generateErrorHash(String stackTrace) {
//   return sha1.convert(utf8.encode(stackTrace)).toString();
// }
// final hash = generateErrorHash(stack.toString());


/// NOTE: this table is used to store error reports
/// example of data:
///   id: 14
///   errorHash: a81f2b8caa01
///   errorMessage: Null check operator used on null
///   stackTrace: login_service.dart:83
///   device: Pixel 7
///   osVersion: Android 14
///   appVersion: 1.3.0
///   breadcrumbs: opened_login -> pressed_login -> api_timeout
///   createdAt: 2026-02-28 18:20
///   sent: false

class ErrorReports extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get errorHash => text()();

  TextColumn get errorMessage => text()();

  TextColumn get stackTrace => text()();

  TextColumn get breadcrumbs => text().nullable()();

  TextColumn get device => text().nullable()();
  TextColumn get osVersion => text().nullable()();

  TextColumn get appVersion => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get sent => boolean().withDefault(const Constant(false))();
}


