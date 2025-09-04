import 'dart:io';

import 'package:chaguaner2023/view/im/imdb.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

AppDb constructDb({bool logStatements = false}) {
  return AppDb(LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'imdb.sqlite'));
    return NativeDatabase(file);
  }));
}
