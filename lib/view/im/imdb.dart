import 'dart:convert';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:drift/drift.dart';
part 'imdb.g.dart';

class Contaict extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get aff => text()();
  TextColumn get messageId => text()();
  TextColumn get userUuid => text()();
  TextColumn get userAvatar => text()();
  TextColumn get userNickname => text()();
  TextColumn get accountUuid => text()();
  TextColumn get lastMsgTime => text()();
  TextColumn get lastMsgContent => text()();
  TextColumn get lastMsgStatus => text()();
  TextColumn get lastMsgType => text()();
  TextColumn get ext => text()();
}

class Message extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text()();
  TextColumn get acountUuid => text()();
  TextColumn get acountAvatar => text()();
  TextColumn get userUuid => text()();
  TextColumn get userAvatar => text()();
  TextColumn get content => text()();
  TextColumn get contentType => text()();
  TextColumn get msgSendTime => text()();
  TextColumn get msgResourceUrl => text()();
  TextColumn get sign => text()();
  TextColumn get ext => text()();
  BoolColumn get isRead => boolean()();
  BoolColumn get isTap => boolean()();
  IntColumn get microtime => integer()();
  IntColumn get msgSendStatus => integer()();
}

@DriftDatabase(tables: [Contaict, Message])
class AppDb extends _$AppDb {
  AppDb(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;
  static List<MessageData> messageList = [];
  static _num(int _nub) {
    return _nub >= 10 ? _nub : '0$_nub';
  }

  static String getTimeString({int? time}) {
    DateTime _date = time == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(time * 1000);
    return '${_date.year}-${_num(_date.month)}-${_num(_date.day)} ${_num(_date.hour)}:${_num(_date.minute)}:${_num(_date.second)}';
  }

//添加联系人
  Future addContact(MessageModel data) async {
    var ext = data.ext == '' ? {} : json.decode(data.ext ?? '{}');
    ContaictCompanion contaictData = ContaictCompanion(
        aff: Value(ext['aff'].toString()),
        messageId: Value(data.uniqueId!),
        userUuid: Value(data.fromUuid == WebSocketUtility.uuid ? data.toUuid : data.fromUuid),
        userAvatar: Value((data.avatar ?? ext['avatar'] ?? '1')),
        userNickname: Value(data.nickname ?? ext['nickname'] ?? '不知名的茶友'),
        accountUuid: Value(WebSocketUtility.uuid),
        lastMsgContent: Value(data.content),
        lastMsgStatus: Value(data.contentType),
        lastMsgTime: Value(data.createdAt.toString()),
        lastMsgType: Value(data.contentType),
        ext: Value(data.ext ?? ''));
    var _contaict = await (select(contaict)
          ..where((tbl) =>
              (tbl.userUuid.equals(data.toUuid!) | tbl.userUuid.equals(data.fromUuid!)) &
              tbl.accountUuid.equals(WebSocketUtility.uuid!)))
        .get();
    if (_contaict.isEmpty) {
      return await into(contaict).insert(contaictData);
    } else {
      contaictData.id = Value(_contaict[0].id);
      contaictData.userAvatar =
          Value(data.avatar != _contaict[0].userAvatar ? (data.avatar ?? '1') : _contaict[0].userAvatar);
      contaictData.userNickname =
          Value(data.nickname != _contaict[0].userNickname ? (data.nickname ?? '不知名的茶友') : _contaict[0].userNickname);
      contaictData.userUuid = Value(data.fromUuid == WebSocketUtility.uuid ? data.toUuid : data.fromUuid);
      return await update(contaict).replace(contaictData);
    }
  }

//查询联系人
  Future<List<ContaictData>> getAccountContact({String? uuid}) async {
    if (uuid != null) {
      return await (select(contaict)
            ..where((tbl) => tbl.accountUuid.equals(WebSocketUtility.uuid!) & tbl.userUuid.equals(uuid))
            ..orderBy([(t) => OrderingTerm.desc(t.lastMsgTime)]))
          .get()
          .then((value) {
        return value;
      });
    } else {
      return await (select(contaict)
            ..where((tbl) => tbl.accountUuid.equals(WebSocketUtility.uuid!))
            ..orderBy([(t) => OrderingTerm.desc(t.lastMsgTime)]))
          .get()
          .then((value) {
        AppGlobal.accountContact.value = [...value];
        return value;
      });
    }
  }

  //添加聊天记录
  Future<List<MessageData>?> addChatRecord(MessageModel data, {bool isRead = false}) async {
    MessageCompanion _msg = MessageCompanion(
        content: Value(data.content!),
        contentType: Value(data.contentType!),
        messageId: Value(data.uniqueId!),
        acountUuid: Value(WebSocketUtility.uuid!),
        acountAvatar: Value(WebSocketUtility.avatar!),
        userUuid: Value(WebSocketUtility.uuid == data.toUuid ? data.fromUuid : data.toUuid),
        userAvatar: Value(data.avatar ?? '1'),
        msgSendTime: Value(data.sendTime.toString()),
        sign: Value(data.uniqueId),
        ext: Value(data.ext ?? ''),
        isRead: Value(isRead),
        isTap: Value(false),
        microtime: Value(data.microtime),
        msgResourceUrl: Value(''),
        msgSendStatus: Value(0));
    var _isHove = await (select(message)..where((tbl) => tbl.sign.equals(data.uniqueId!))).get();
    if (_isHove.length == 0) {
      return await into(message).insert(_msg).then((value) async {
        return await (select(message)..where((tbl) => tbl.sign.equals(data.uniqueId!))).get().then((value) {
          AppGlobal.appDb!.gelUnreadLength(WebSocketUtility.uuid!).then((_v) {
            AppGlobal.unreadMessage.value = (_v ?? 0) + AppGlobal.systemMessage;
          });
          return null;
        });
      });
    } else {
      return null;
    }
  }

  //删除记录
  Future deleteChatRecord(int id) async {
    await (delete(contaict)
          ..where((tbl) {
            return tbl.id.isValue(id);
          }))
        .go();
  }

  //未读条数
  Future<int> gelUnreadLength(String uuid) async {
    if (uuid != WebSocketUtility.uuid) {
      return await (select(message)
            ..where((tbl) => tbl.userUuid.equals(uuid) & tbl.acountUuid.equals(WebSocketUtility.uuid!)))
          .get()
          .then((value) {
        getAccountContact(uuid: uuid);
        return value.length;
      });
    } else {
      return await (select(message)..where((tbl) => tbl.acountUuid.equals(WebSocketUtility.uuid!))).get().then((value) {
        return value.length;
      });
    }
  }

//清空未读消息
  Future cleanMsg(FormUserMsg userInfo) async {
    return await (delete(message)
          ..where((tbl) {
            return tbl.acountUuid.equals(WebSocketUtility.uuid!) & tbl.userUuid.equals(userInfo.uuid!);
          }))
        .go();
  }
}
