import 'package:chaguaner2023/view/im/imdb.dart';
import 'package:drift/web.dart';

AppDb constructDb({bool logStatements = false}) {
  return AppDb(WebDatabase('db', logStatements: logStatements));
}