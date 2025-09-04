// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imdb.dart';

// ignore_for_file: type=lint
class $ContaictTable extends Contaict
    with TableInfo<$ContaictTable, ContaictData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContaictTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedColumn<int>? _id;
  @override
  GeneratedColumn<int> get id =>
      _id ??= GeneratedColumn<int>('id', aliasedName, false,
          hasAutoIncrement: true,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultConstraints:
              GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _affMeta = const VerificationMeta('aff');
  GeneratedColumn<String>? _aff;
  @override
  GeneratedColumn<String> get aff =>
      _aff ??= GeneratedColumn<String>('aff', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  GeneratedColumn<String>? _messageId;
  @override
  GeneratedColumn<String> get messageId =>
      _messageId ??= GeneratedColumn<String>('message_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userUuidMeta =
      const VerificationMeta('userUuid');
  GeneratedColumn<String>? _userUuid;
  @override
  GeneratedColumn<String> get userUuid =>
      _userUuid ??= GeneratedColumn<String>('user_uuid', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userAvatarMeta =
      const VerificationMeta('userAvatar');
  GeneratedColumn<String>? _userAvatar;
  @override
  GeneratedColumn<String> get userAvatar =>
      _userAvatar ??= GeneratedColumn<String>('user_avatar', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userNicknameMeta =
      const VerificationMeta('userNickname');
  GeneratedColumn<String>? _userNickname;
  @override
  GeneratedColumn<String> get userNickname => _userNickname ??=
      GeneratedColumn<String>('user_nickname', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountUuidMeta =
      const VerificationMeta('accountUuid');
  GeneratedColumn<String>? _accountUuid;
  @override
  GeneratedColumn<String> get accountUuid => _accountUuid ??=
      GeneratedColumn<String>('account_uuid', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastMsgTimeMeta =
      const VerificationMeta('lastMsgTime');
  GeneratedColumn<String>? _lastMsgTime;
  @override
  GeneratedColumn<String> get lastMsgTime => _lastMsgTime ??=
      GeneratedColumn<String>('last_msg_time', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastMsgContentMeta =
      const VerificationMeta('lastMsgContent');
  GeneratedColumn<String>? _lastMsgContent;
  @override
  GeneratedColumn<String> get lastMsgContent => _lastMsgContent ??=
      GeneratedColumn<String>('last_msg_content', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastMsgStatusMeta =
      const VerificationMeta('lastMsgStatus');
  GeneratedColumn<String>? _lastMsgStatus;
  @override
  GeneratedColumn<String> get lastMsgStatus => _lastMsgStatus ??=
      GeneratedColumn<String>('last_msg_status', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastMsgTypeMeta =
      const VerificationMeta('lastMsgType');
  GeneratedColumn<String>? _lastMsgType;
  @override
  GeneratedColumn<String> get lastMsgType => _lastMsgType ??=
      GeneratedColumn<String>('last_msg_type', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _extMeta = const VerificationMeta('ext');
  GeneratedColumn<String>? _ext;
  @override
  GeneratedColumn<String> get ext =>
      _ext ??= GeneratedColumn<String>('ext', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        aff,
        messageId,
        userUuid,
        userAvatar,
        userNickname,
        accountUuid,
        lastMsgTime,
        lastMsgContent,
        lastMsgStatus,
        lastMsgType,
        ext
      ];
  @override
  String get aliasedName => _alias ?? 'contaict';
  @override
  String get actualTableName => 'contaict';
  @override
  VerificationContext validateIntegrity(Insertable<ContaictData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aff')) {
      context.handle(
          _affMeta, aff.isAcceptableOrUnknown(data['aff']!, _affMeta));
    } else if (isInserting) {
      context.missing(_affMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('user_uuid')) {
      context.handle(_userUuidMeta,
          userUuid.isAcceptableOrUnknown(data['user_uuid']!, _userUuidMeta));
    } else if (isInserting) {
      context.missing(_userUuidMeta);
    }
    if (data.containsKey('user_avatar')) {
      context.handle(
          _userAvatarMeta,
          userAvatar.isAcceptableOrUnknown(
              data['user_avatar']!, _userAvatarMeta));
    } else if (isInserting) {
      context.missing(_userAvatarMeta);
    }
    if (data.containsKey('user_nickname')) {
      context.handle(
          _userNicknameMeta,
          userNickname.isAcceptableOrUnknown(
              data['user_nickname']!, _userNicknameMeta));
    } else if (isInserting) {
      context.missing(_userNicknameMeta);
    }
    if (data.containsKey('account_uuid')) {
      context.handle(
          _accountUuidMeta,
          accountUuid.isAcceptableOrUnknown(
              data['account_uuid']!, _accountUuidMeta));
    } else if (isInserting) {
      context.missing(_accountUuidMeta);
    }
    if (data.containsKey('last_msg_time')) {
      context.handle(
          _lastMsgTimeMeta,
          lastMsgTime.isAcceptableOrUnknown(
              data['last_msg_time']!, _lastMsgTimeMeta));
    } else if (isInserting) {
      context.missing(_lastMsgTimeMeta);
    }
    if (data.containsKey('last_msg_content')) {
      context.handle(
          _lastMsgContentMeta,
          lastMsgContent.isAcceptableOrUnknown(
              data['last_msg_content']!, _lastMsgContentMeta));
    } else if (isInserting) {
      context.missing(_lastMsgContentMeta);
    }
    if (data.containsKey('last_msg_status')) {
      context.handle(
          _lastMsgStatusMeta,
          lastMsgStatus.isAcceptableOrUnknown(
              data['last_msg_status']!, _lastMsgStatusMeta));
    } else if (isInserting) {
      context.missing(_lastMsgStatusMeta);
    }
    if (data.containsKey('last_msg_type')) {
      context.handle(
          _lastMsgTypeMeta,
          lastMsgType.isAcceptableOrUnknown(
              data['last_msg_type']!, _lastMsgTypeMeta));
    } else if (isInserting) {
      context.missing(_lastMsgTypeMeta);
    }
    if (data.containsKey('ext')) {
      context.handle(
          _extMeta, ext.isAcceptableOrUnknown(data['ext']!, _extMeta));
    } else if (isInserting) {
      context.missing(_extMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContaictData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContaictData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      aff: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aff']),
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id']),
      userUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_uuid']),
      userAvatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_avatar']),
      userNickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_nickname']),
      accountUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_uuid']),
      lastMsgTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_msg_time']),
      lastMsgContent: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_msg_content']),
      lastMsgStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_msg_status']),
      lastMsgType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_msg_type']),
      ext: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ext']),
    );
  }

  @override
  $ContaictTable createAlias(String alias) {
    return $ContaictTable(attachedDatabase, alias);
  }
}

class ContaictData extends DataClass implements Insertable<ContaictData> {
  final int? id;
  final String? aff;
  final String? messageId;
  final String? userUuid;
  final String? userAvatar;
  final String? userNickname;
  final String? accountUuid;
  final String? lastMsgTime;
  final String? lastMsgContent;
  final String? lastMsgStatus;
  final String? lastMsgType;
  final String? ext;
  const ContaictData(
      {this.id,
      this.aff,
      this.messageId,
      this.userUuid,
      this.userAvatar,
      this.userNickname,
      this.accountUuid,
      this.lastMsgTime,
      this.lastMsgContent,
      this.lastMsgStatus,
      this.lastMsgType,
      this.ext});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aff'] = Variable<String>(aff);
    map['message_id'] = Variable<String>(messageId);
    map['user_uuid'] = Variable<String>(userUuid);
    map['user_avatar'] = Variable<String>(userAvatar);
    map['user_nickname'] = Variable<String>(userNickname);
    map['account_uuid'] = Variable<String>(accountUuid);
    map['last_msg_time'] = Variable<String>(lastMsgTime);
    map['last_msg_content'] = Variable<String>(lastMsgContent);
    map['last_msg_status'] = Variable<String>(lastMsgStatus);
    map['last_msg_type'] = Variable<String>(lastMsgType);
    map['ext'] = Variable<String>(ext);
    return map;
  }

  ContaictCompanion toCompanion(bool nullToAbsent) {
    return ContaictCompanion(
      id: Value(id!),
      aff: Value(aff!),
      messageId: Value(messageId!),
      userUuid: Value(userUuid!),
      userAvatar: Value(userAvatar!),
      userNickname: Value(userNickname!),
      accountUuid: Value(accountUuid!),
      lastMsgTime: Value(lastMsgTime!),
      lastMsgContent: Value(lastMsgContent!),
      lastMsgStatus: Value(lastMsgStatus!),
      lastMsgType: Value(lastMsgType!),
      ext: Value(ext!),
    );
  }

  factory ContaictData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContaictData(
      id: serializer.fromJson<int>(json['id']),
      aff: serializer.fromJson<String>(json['aff']),
      messageId: serializer.fromJson<String>(json['messageId']),
      userUuid: serializer.fromJson<String>(json['userUuid']),
      userAvatar: serializer.fromJson<String>(json['userAvatar']),
      userNickname: serializer.fromJson<String>(json['userNickname']),
      accountUuid: serializer.fromJson<String>(json['accountUuid']),
      lastMsgTime: serializer.fromJson<String>(json['lastMsgTime']),
      lastMsgContent: serializer.fromJson<String>(json['lastMsgContent']),
      lastMsgStatus: serializer.fromJson<String>(json['lastMsgStatus']),
      lastMsgType: serializer.fromJson<String>(json['lastMsgType']),
      ext: serializer.fromJson<String>(json['ext']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id!),
      'aff': serializer.toJson<String>(aff!),
      'messageId': serializer.toJson<String>(messageId!),
      'userUuid': serializer.toJson<String>(userUuid!),
      'userAvatar': serializer.toJson<String>(userAvatar!),
      'userNickname': serializer.toJson<String>(userNickname!),
      'accountUuid': serializer.toJson<String>(accountUuid!),
      'lastMsgTime': serializer.toJson<String>(lastMsgTime!),
      'lastMsgContent': serializer.toJson<String>(lastMsgContent!),
      'lastMsgStatus': serializer.toJson<String>(lastMsgStatus!),
      'lastMsgType': serializer.toJson<String>(lastMsgType!),
      'ext': serializer.toJson<String>(ext!),
    };
  }

  ContaictData copyWith(
          {int? id,
          String? aff,
          String? messageId,
          String? userUuid,
          String? userAvatar,
          String? userNickname,
          String? accountUuid,
          String? lastMsgTime,
          String? lastMsgContent,
          String? lastMsgStatus,
          String? lastMsgType,
          String? ext}) =>
      ContaictData(
        id: id ?? this.id,
        aff: aff ?? this.aff,
        messageId: messageId ?? this.messageId,
        userUuid: userUuid ?? this.userUuid,
        userAvatar: userAvatar ?? this.userAvatar,
        userNickname: userNickname ?? this.userNickname,
        accountUuid: accountUuid ?? this.accountUuid,
        lastMsgTime: lastMsgTime ?? this.lastMsgTime,
        lastMsgContent: lastMsgContent ?? this.lastMsgContent,
        lastMsgStatus: lastMsgStatus ?? this.lastMsgStatus,
        lastMsgType: lastMsgType ?? this.lastMsgType,
        ext: ext ?? this.ext,
      );
  @override
  String toString() {
    return (StringBuffer('ContaictData(')
          ..write('id: $id, ')
          ..write('aff: $aff, ')
          ..write('messageId: $messageId, ')
          ..write('userUuid: $userUuid, ')
          ..write('userAvatar: $userAvatar, ')
          ..write('userNickname: $userNickname, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('lastMsgTime: $lastMsgTime, ')
          ..write('lastMsgContent: $lastMsgContent, ')
          ..write('lastMsgStatus: $lastMsgStatus, ')
          ..write('lastMsgType: $lastMsgType, ')
          ..write('ext: $ext')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      aff,
      messageId,
      userUuid,
      userAvatar,
      userNickname,
      accountUuid,
      lastMsgTime,
      lastMsgContent,
      lastMsgStatus,
      lastMsgType,
      ext);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContaictData &&
          other.id == this.id &&
          other.aff == this.aff &&
          other.messageId == this.messageId &&
          other.userUuid == this.userUuid &&
          other.userAvatar == this.userAvatar &&
          other.userNickname == this.userNickname &&
          other.accountUuid == this.accountUuid &&
          other.lastMsgTime == this.lastMsgTime &&
          other.lastMsgContent == this.lastMsgContent &&
          other.lastMsgStatus == this.lastMsgStatus &&
          other.lastMsgType == this.lastMsgType &&
          other.ext == this.ext);
}

class ContaictCompanion extends UpdateCompanion<ContaictData> {
  Value<int?> id;
  Value<String?> aff;
  Value<String?> messageId;
  Value<String?> userUuid;
  Value<String?> userAvatar;
  Value<String?> userNickname;
  Value<String?> accountUuid;
  Value<String?> lastMsgTime;
  Value<String?> lastMsgContent;
  Value<String?> lastMsgStatus;
  Value<String?> lastMsgType;
  Value<String?> ext;
  ContaictCompanion({
    this.id = const Value.absent(),
    this.aff = const Value.absent(),
    this.messageId = const Value.absent(),
    this.userUuid = const Value.absent(),
    this.userAvatar = const Value.absent(),
    this.userNickname = const Value.absent(),
    this.accountUuid = const Value.absent(),
    this.lastMsgTime = const Value.absent(),
    this.lastMsgContent = const Value.absent(),
    this.lastMsgStatus = const Value.absent(),
    this.lastMsgType = const Value.absent(),
    this.ext = const Value.absent(),
  });
  ContaictCompanion.insert({
    this.id = const Value.absent(),
    String? aff,
    String? messageId,
    String? userUuid,
    String? userAvatar,
    String? userNickname,
    String? accountUuid,
    String? lastMsgTime,
    String? lastMsgContent,
    String? lastMsgStatus,
    String? lastMsgType,
    String? ext,
  })  : aff = Value(aff!),
        messageId = Value(messageId!),
        userUuid = Value(userUuid!),
        userAvatar = Value(userAvatar!),
        userNickname = Value(userNickname!),
        accountUuid = Value(accountUuid!),
        lastMsgTime = Value(lastMsgTime!),
        lastMsgContent = Value(lastMsgContent!),
        lastMsgStatus = Value(lastMsgStatus!),
        lastMsgType = Value(lastMsgType!),
        ext = Value(ext!);
  static Insertable<ContaictData> custom({
    Expression<int>? id,
    Expression<String>? aff,
    Expression<String>? messageId,
    Expression<String>? userUuid,
    Expression<String>? userAvatar,
    Expression<String>? userNickname,
    Expression<String>? accountUuid,
    Expression<String>? lastMsgTime,
    Expression<String>? lastMsgContent,
    Expression<String>? lastMsgStatus,
    Expression<String>? lastMsgType,
    Expression<String>? ext,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aff != null) 'aff': aff,
      if (messageId != null) 'message_id': messageId,
      if (userUuid != null) 'user_uuid': userUuid,
      if (userAvatar != null) 'user_avatar': userAvatar,
      if (userNickname != null) 'user_nickname': userNickname,
      if (accountUuid != null) 'account_uuid': accountUuid,
      if (lastMsgTime != null) 'last_msg_time': lastMsgTime,
      if (lastMsgContent != null) 'last_msg_content': lastMsgContent,
      if (lastMsgStatus != null) 'last_msg_status': lastMsgStatus,
      if (lastMsgType != null) 'last_msg_type': lastMsgType,
      if (ext != null) 'ext': ext,
    });
  }

  ContaictCompanion copyWith(
      {Value<int>? id,
      Value<String>? aff,
      Value<String>? messageId,
      Value<String>? userUuid,
      Value<String>? userAvatar,
      Value<String>? userNickname,
      Value<String>? accountUuid,
      Value<String>? lastMsgTime,
      Value<String>? lastMsgContent,
      Value<String>? lastMsgStatus,
      Value<String>? lastMsgType,
      Value<String>? ext}) {
    return ContaictCompanion(
      id: id ?? this.id,
      aff: aff ?? this.aff,
      messageId: messageId ?? this.messageId,
      userUuid: userUuid ?? this.userUuid,
      userAvatar: userAvatar ?? this.userAvatar,
      userNickname: userNickname ?? this.userNickname,
      accountUuid: accountUuid ?? this.accountUuid,
      lastMsgTime: lastMsgTime ?? this.lastMsgTime,
      lastMsgContent: lastMsgContent ?? this.lastMsgContent,
      lastMsgStatus: lastMsgStatus ?? this.lastMsgStatus,
      lastMsgType: lastMsgType ?? this.lastMsgType,
      ext: ext ?? this.ext,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (aff.present) {
      map['aff'] = Variable<String>(aff.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (userUuid.present) {
      map['user_uuid'] = Variable<String>(userUuid.value);
    }
    if (userAvatar.present) {
      map['user_avatar'] = Variable<String>(userAvatar.value);
    }
    if (userNickname.present) {
      map['user_nickname'] = Variable<String>(userNickname.value);
    }
    if (accountUuid.present) {
      map['account_uuid'] = Variable<String>(accountUuid.value);
    }
    if (lastMsgTime.present) {
      map['last_msg_time'] = Variable<String>(lastMsgTime.value);
    }
    if (lastMsgContent.present) {
      map['last_msg_content'] = Variable<String>(lastMsgContent.value);
    }
    if (lastMsgStatus.present) {
      map['last_msg_status'] = Variable<String>(lastMsgStatus.value);
    }
    if (lastMsgType.present) {
      map['last_msg_type'] = Variable<String>(lastMsgType.value);
    }
    if (ext.present) {
      map['ext'] = Variable<String>(ext.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContaictCompanion(')
          ..write('id: $id, ')
          ..write('aff: $aff, ')
          ..write('messageId: $messageId, ')
          ..write('userUuid: $userUuid, ')
          ..write('userAvatar: $userAvatar, ')
          ..write('userNickname: $userNickname, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('lastMsgTime: $lastMsgTime, ')
          ..write('lastMsgContent: $lastMsgContent, ')
          ..write('lastMsgStatus: $lastMsgStatus, ')
          ..write('lastMsgType: $lastMsgType, ')
          ..write('ext: $ext')
          ..write(')'))
        .toString();
  }
}

class $MessageTable extends Message with TableInfo<$MessageTable, MessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedColumn<int>? _id;
  @override
  GeneratedColumn<int> get id =>
      _id ??= GeneratedColumn<int>('id', aliasedName, false,
          hasAutoIncrement: true,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultConstraints:
              GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  GeneratedColumn<String>? _messageId;
  @override
  GeneratedColumn<String> get messageId =>
      _messageId ??= GeneratedColumn<String>('message_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _acountUuidMeta =
      const VerificationMeta('acountUuid');
  GeneratedColumn<String>? _acountUuid;
  @override
  GeneratedColumn<String> get acountUuid =>
      _acountUuid ??= GeneratedColumn<String>('acount_uuid', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _acountAvatarMeta =
      const VerificationMeta('acountAvatar');
  GeneratedColumn<String>? _acountAvatar;
  @override
  GeneratedColumn<String> get acountAvatar => _acountAvatar ??=
      GeneratedColumn<String>('acount_avatar', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userUuidMeta =
      const VerificationMeta('userUuid');
  GeneratedColumn<String>? _userUuid;
  @override
  GeneratedColumn<String> get userUuid =>
      _userUuid ??= GeneratedColumn<String>('user_uuid', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userAvatarMeta =
      const VerificationMeta('userAvatar');
  GeneratedColumn<String>? _userAvatar;
  @override
  GeneratedColumn<String> get userAvatar =>
      _userAvatar ??= GeneratedColumn<String>('user_avatar', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  GeneratedColumn<String>? _content;
  @override
  GeneratedColumn<String> get content =>
      _content ??= GeneratedColumn<String>('content', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentTypeMeta =
      const VerificationMeta('contentType');
  GeneratedColumn<String>? _contentType;
  @override
  GeneratedColumn<String> get contentType => _contentType ??=
      GeneratedColumn<String>('content_type', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _msgSendTimeMeta =
      const VerificationMeta('msgSendTime');
  GeneratedColumn<String>? _msgSendTime;
  @override
  GeneratedColumn<String> get msgSendTime => _msgSendTime ??=
      GeneratedColumn<String>('msg_send_time', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _msgResourceUrlMeta =
      const VerificationMeta('msgResourceUrl');
  GeneratedColumn<String>? _msgResourceUrl;
  @override
  GeneratedColumn<String> get msgResourceUrl => _msgResourceUrl ??=
      GeneratedColumn<String>('msg_resource_url', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _signMeta = const VerificationMeta('sign');

  GeneratedColumn<String>? _sign;
  @override
  GeneratedColumn<String> get sign =>
      _sign ??= GeneratedColumn<String>('sign', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _extMeta = const VerificationMeta('ext');
  GeneratedColumn<String>? _ext;
  @override
  GeneratedColumn<String> get ext =>
      _ext ??= GeneratedColumn<String>('ext', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  GeneratedColumn<bool>? _isRead;
  @override
  GeneratedColumn<bool> get isRead =>
      _isRead ??= GeneratedColumn<bool>('is_read', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_read" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  static const VerificationMeta _isTapMeta = const VerificationMeta('isTap');
  GeneratedColumn<bool>? _isTap;
  @override
  GeneratedColumn<bool> get isTap =>
      _isTap ??= GeneratedColumn<bool>('is_tap', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_tap" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  static const VerificationMeta _microtimeMeta =
      const VerificationMeta('microtime');
  GeneratedColumn<int>? _microtime;
  @override
  GeneratedColumn<int> get microtime =>
      _microtime ??= GeneratedColumn<int>('microtime', aliasedName, false,
          type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _msgSendStatusMeta =
      const VerificationMeta('msgSendStatus');
  GeneratedColumn<int>? _msgSendStatus;
  @override
  GeneratedColumn<int> get msgSendStatus => _msgSendStatus ??=
      GeneratedColumn<int>('msg_send_status', aliasedName, false,
          type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        messageId,
        acountUuid,
        acountAvatar,
        userUuid,
        userAvatar,
        content,
        contentType,
        msgSendTime,
        msgResourceUrl,
        sign,
        ext,
        isRead,
        isTap,
        microtime,
        msgSendStatus
      ];
  @override
  String get aliasedName => _alias ?? 'message';
  @override
  String get actualTableName => 'message';
  @override
  VerificationContext validateIntegrity(Insertable<MessageData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('acount_uuid')) {
      context.handle(
          _acountUuidMeta,
          acountUuid.isAcceptableOrUnknown(
              data['acount_uuid']!, _acountUuidMeta));
    } else if (isInserting) {
      context.missing(_acountUuidMeta);
    }
    if (data.containsKey('acount_avatar')) {
      context.handle(
          _acountAvatarMeta,
          acountAvatar.isAcceptableOrUnknown(
              data['acount_avatar']!, _acountAvatarMeta));
    } else if (isInserting) {
      context.missing(_acountAvatarMeta);
    }
    if (data.containsKey('user_uuid')) {
      context.handle(_userUuidMeta,
          userUuid.isAcceptableOrUnknown(data['user_uuid']!, _userUuidMeta));
    } else if (isInserting) {
      context.missing(_userUuidMeta);
    }
    if (data.containsKey('user_avatar')) {
      context.handle(
          _userAvatarMeta,
          userAvatar.isAcceptableOrUnknown(
              data['user_avatar']!, _userAvatarMeta));
    } else if (isInserting) {
      context.missing(_userAvatarMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
          _contentTypeMeta,
          contentType.isAcceptableOrUnknown(
              data['content_type']!, _contentTypeMeta));
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('msg_send_time')) {
      context.handle(
          _msgSendTimeMeta,
          msgSendTime.isAcceptableOrUnknown(
              data['msg_send_time']!, _msgSendTimeMeta));
    } else if (isInserting) {
      context.missing(_msgSendTimeMeta);
    }
    if (data.containsKey('msg_resource_url')) {
      context.handle(
          _msgResourceUrlMeta,
          msgResourceUrl.isAcceptableOrUnknown(
              data['msg_resource_url']!, _msgResourceUrlMeta));
    } else if (isInserting) {
      context.missing(_msgResourceUrlMeta);
    }
    if (data.containsKey('sign')) {
      context.handle(
          _signMeta, sign.isAcceptableOrUnknown(data['sign']!, _signMeta));
    } else if (isInserting) {
      context.missing(_signMeta);
    }
    if (data.containsKey('ext')) {
      context.handle(
          _extMeta, ext.isAcceptableOrUnknown(data['ext']!, _extMeta));
    } else if (isInserting) {
      context.missing(_extMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    } else if (isInserting) {
      context.missing(_isReadMeta);
    }
    if (data.containsKey('is_tap')) {
      context.handle(
          _isTapMeta, isTap.isAcceptableOrUnknown(data['is_tap']!, _isTapMeta));
    } else if (isInserting) {
      context.missing(_isTapMeta);
    }
    if (data.containsKey('microtime')) {
      context.handle(_microtimeMeta,
          microtime.isAcceptableOrUnknown(data['microtime']!, _microtimeMeta));
    } else if (isInserting) {
      context.missing(_microtimeMeta);
    }
    if (data.containsKey('msg_send_status')) {
      context.handle(
          _msgSendStatusMeta,
          msgSendStatus.isAcceptableOrUnknown(
              data['msg_send_status']!, _msgSendStatusMeta));
    } else if (isInserting) {
      context.missing(_msgSendStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id']),
      acountUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}acount_uuid']),
      acountAvatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}acount_avatar']),
      userUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_uuid']),
      userAvatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_avatar']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      contentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      msgSendTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}msg_send_time']),
      msgResourceUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}msg_resource_url']),
      sign: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sign']),
      ext: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ext']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read']),
      isTap: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_tap']),
      microtime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}microtime']),
      msgSendStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}msg_send_status']),
    );
  }

  @override
  $MessageTable createAlias(String alias) {
    return $MessageTable(attachedDatabase, alias);
  }
}

class MessageData extends DataClass implements Insertable<MessageData> {
  int? id;
  String? messageId;
  String? acountUuid;
  String? acountAvatar;
  String? userUuid;
  String? userAvatar;
  String? content;
  String? contentType;
  String? msgSendTime;
  String? msgResourceUrl;
  String? sign;
  String? ext;
  bool? isRead;
  bool? isTap;
  int? microtime;
  int? msgSendStatus;
  MessageData(
      {this.id,
      this.messageId,
      this.acountUuid,
      this.acountAvatar,
      this.userUuid,
      this.userAvatar,
      this.content,
      this.contentType,
      this.msgSendTime,
      this.msgResourceUrl,
      this.sign,
      this.ext,
      this.isRead,
      this.isTap,
      this.microtime,
      this.msgSendStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['acount_uuid'] = Variable<String>(acountUuid);
    map['acount_avatar'] = Variable<String>(acountAvatar);
    map['user_uuid'] = Variable<String>(userUuid);
    map['user_avatar'] = Variable<String>(userAvatar);
    map['content'] = Variable<String>(content);
    map['content_type'] = Variable<String>(contentType);
    map['msg_send_time'] = Variable<String>(msgSendTime);
    map['msg_resource_url'] = Variable<String>(msgResourceUrl);
    map['sign'] = Variable<String>(sign);
    map['ext'] = Variable<String>(ext);
    map['is_read'] = Variable<bool>(isRead);
    map['is_tap'] = Variable<bool>(isTap);
    map['microtime'] = Variable<int>(microtime);
    map['msg_send_status'] = Variable<int>(msgSendStatus);
    return map;
  }

  MessageCompanion toCompanion(bool nullToAbsent) {
    return MessageCompanion(
      id: Value(id!),
      messageId: Value(messageId!),
      acountUuid: Value(acountUuid!),
      acountAvatar: Value(acountAvatar!),
      userUuid: Value(userUuid!),
      userAvatar: Value(userAvatar!),
      content: Value(content!),
      contentType: Value(contentType!),
      msgSendTime: Value(msgSendTime!),
      msgResourceUrl: Value(msgResourceUrl!),
      sign: Value(sign!),
      ext: Value(ext!),
      isRead: Value(isRead!),
      isTap: Value(isTap!),
      microtime: Value(microtime!),
      msgSendStatus: Value(msgSendStatus!),
    );
  }

  factory MessageData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageData(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      acountUuid: serializer.fromJson<String>(json['acountUuid']),
      acountAvatar: serializer.fromJson<String>(json['acountAvatar']),
      userUuid: serializer.fromJson<String>(json['userUuid']),
      userAvatar: serializer.fromJson<String>(json['userAvatar']),
      content: serializer.fromJson<String>(json['content']),
      contentType: serializer.fromJson<String>(json['contentType']),
      msgSendTime: serializer.fromJson<String>(json['msgSendTime']),
      msgResourceUrl: serializer.fromJson<String>(json['msgResourceUrl']),
      sign: serializer.fromJson<String>(json['sign']),
      ext: serializer.fromJson<String>(json['ext']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isTap: serializer.fromJson<bool>(json['isTap']),
      microtime: serializer.fromJson<int>(json['microtime']),
      msgSendStatus: serializer.fromJson<int>(json['msgSendStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id!),
      'messageId': serializer.toJson<String>(messageId!),
      'acountUuid': serializer.toJson<String>(acountUuid!),
      'acountAvatar': serializer.toJson<String>(acountAvatar!),
      'userUuid': serializer.toJson<String>(userUuid!),
      'userAvatar': serializer.toJson<String>(userAvatar!),
      'content': serializer.toJson<String>(content!),
      'contentType': serializer.toJson<String>(contentType!),
      'msgSendTime': serializer.toJson<String>(msgSendTime!),
      'msgResourceUrl': serializer.toJson<String>(msgResourceUrl!),
      'sign': serializer.toJson<String>(sign!),
      'ext': serializer.toJson<String>(ext!),
      'isRead': serializer.toJson<bool>(isRead!),
      'isTap': serializer.toJson<bool>(isTap!),
      'microtime': serializer.toJson<int>(microtime!),
      'msgSendStatus': serializer.toJson<int>(msgSendStatus!),
    };
  }

  MessageData copyWith(
          {int? id,
          String? messageId,
          String? acountUuid,
          String? acountAvatar,
          String? userUuid,
          String? userAvatar,
          String? content,
          String? contentType,
          String? msgSendTime,
          String? msgResourceUrl,
          String? sign,
          String? ext,
          bool? isRead,
          bool? isTap,
          int? microtime,
          int? msgSendStatus}) =>
      MessageData(
        id: id ?? this.id,
        messageId: messageId ?? this.messageId,
        acountUuid: acountUuid ?? this.acountUuid,
        acountAvatar: acountAvatar ?? this.acountAvatar,
        userUuid: userUuid ?? this.userUuid,
        userAvatar: userAvatar ?? this.userAvatar,
        content: content ?? this.content,
        contentType: contentType ?? this.contentType,
        msgSendTime: msgSendTime ?? this.msgSendTime,
        msgResourceUrl: msgResourceUrl ?? this.msgResourceUrl,
        sign: sign ?? this.sign,
        ext: ext ?? this.ext,
        isRead: isRead ?? this.isRead,
        isTap: isTap ?? this.isTap,
        microtime: microtime ?? this.microtime,
        msgSendStatus: msgSendStatus ?? this.msgSendStatus,
      );
  @override
  String toString() {
    return (StringBuffer('MessageData(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('acountUuid: $acountUuid, ')
          ..write('acountAvatar: $acountAvatar, ')
          ..write('userUuid: $userUuid, ')
          ..write('userAvatar: $userAvatar, ')
          ..write('content: $content, ')
          ..write('contentType: $contentType, ')
          ..write('msgSendTime: $msgSendTime, ')
          ..write('msgResourceUrl: $msgResourceUrl, ')
          ..write('sign: $sign, ')
          ..write('ext: $ext, ')
          ..write('isRead: $isRead, ')
          ..write('isTap: $isTap, ')
          ..write('microtime: $microtime, ')
          ..write('msgSendStatus: $msgSendStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      messageId,
      acountUuid,
      acountAvatar,
      userUuid,
      userAvatar,
      content,
      contentType,
      msgSendTime,
      msgResourceUrl,
      sign,
      ext,
      isRead,
      isTap,
      microtime,
      msgSendStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageData &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.acountUuid == this.acountUuid &&
          other.acountAvatar == this.acountAvatar &&
          other.userUuid == this.userUuid &&
          other.userAvatar == this.userAvatar &&
          other.content == this.content &&
          other.contentType == this.contentType &&
          other.msgSendTime == this.msgSendTime &&
          other.msgResourceUrl == this.msgResourceUrl &&
          other.sign == this.sign &&
          other.ext == this.ext &&
          other.isRead == this.isRead &&
          other.isTap == this.isTap &&
          other.microtime == this.microtime &&
          other.msgSendStatus == this.msgSendStatus);
}

class MessageCompanion extends UpdateCompanion<MessageData> {
  final Value<int?> id;
  final Value<String?> messageId;
  final Value<String?> acountUuid;
  final Value<String?> acountAvatar;
  final Value<String?> userUuid;
  final Value<String?> userAvatar;
  final Value<String?> content;
  final Value<String?> contentType;
  final Value<String?> msgSendTime;
  final Value<String?> msgResourceUrl;
  final Value<String?> sign;
  final Value<String?> ext;
  final Value<bool?> isRead;
  final Value<bool?> isTap;
  final Value<int?> microtime;
  final Value<int?> msgSendStatus;
  const MessageCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.acountUuid = const Value.absent(),
    this.acountAvatar = const Value.absent(),
    this.userUuid = const Value.absent(),
    this.userAvatar = const Value.absent(),
    this.content = const Value.absent(),
    this.contentType = const Value.absent(),
    this.msgSendTime = const Value.absent(),
    this.msgResourceUrl = const Value.absent(),
    this.sign = const Value.absent(),
    this.ext = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isTap = const Value.absent(),
    this.microtime = const Value.absent(),
    this.msgSendStatus = const Value.absent(),
  });
  MessageCompanion.insert({
    this.id = const Value.absent(),
    String? messageId,
    String? acountUuid,
    String? acountAvatar,
    String? userUuid,
    String? userAvatar,
    String? content,
    String? contentType,
    String? msgSendTime,
    String? msgResourceUrl,
    String? sign,
    String? ext,
    bool? isRead,
    bool? isTap,
    int? microtime,
    int? msgSendStatus,
  })  : messageId = Value(messageId!),
        acountUuid = Value(acountUuid!),
        acountAvatar = Value(acountAvatar!),
        userUuid = Value(userUuid!),
        userAvatar = Value(userAvatar!),
        content = Value(content!),
        contentType = Value(contentType!),
        msgSendTime = Value(msgSendTime!),
        msgResourceUrl = Value(msgResourceUrl!),
        sign = Value(sign!),
        ext = Value(ext!),
        isRead = Value(isRead!),
        isTap = Value(isTap!),
        microtime = Value(microtime!),
        msgSendStatus = Value(msgSendStatus!);
  static Insertable<MessageData> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? acountUuid,
    Expression<String>? acountAvatar,
    Expression<String>? userUuid,
    Expression<String>? userAvatar,
    Expression<String>? content,
    Expression<String>? contentType,
    Expression<String>? msgSendTime,
    Expression<String>? msgResourceUrl,
    Expression<String>? sign,
    Expression<String>? ext,
    Expression<bool>? isRead,
    Expression<bool>? isTap,
    Expression<int>? microtime,
    Expression<int>? msgSendStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (acountUuid != null) 'acount_uuid': acountUuid,
      if (acountAvatar != null) 'acount_avatar': acountAvatar,
      if (userUuid != null) 'user_uuid': userUuid,
      if (userAvatar != null) 'user_avatar': userAvatar,
      if (content != null) 'content': content,
      if (contentType != null) 'content_type': contentType,
      if (msgSendTime != null) 'msg_send_time': msgSendTime,
      if (msgResourceUrl != null) 'msg_resource_url': msgResourceUrl,
      if (sign != null) 'sign': sign,
      if (ext != null) 'ext': ext,
      if (isRead != null) 'is_read': isRead,
      if (isTap != null) 'is_tap': isTap,
      if (microtime != null) 'microtime': microtime,
      if (msgSendStatus != null) 'msg_send_status': msgSendStatus,
    });
  }

  MessageCompanion copyWith(
      {Value<int>? id,
      Value<String>? messageId,
      Value<String>? acountUuid,
      Value<String>? acountAvatar,
      Value<String>? userUuid,
      Value<String>? userAvatar,
      Value<String>? content,
      Value<String>? contentType,
      Value<String>? msgSendTime,
      Value<String>? msgResourceUrl,
      Value<String>? sign,
      Value<String>? ext,
      Value<bool>? isRead,
      Value<bool>? isTap,
      Value<int>? microtime,
      Value<int>? msgSendStatus}) {
    return MessageCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      acountUuid: acountUuid ?? this.acountUuid,
      acountAvatar: acountAvatar ?? this.acountAvatar,
      userUuid: userUuid ?? this.userUuid,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      msgSendTime: msgSendTime ?? this.msgSendTime,
      msgResourceUrl: msgResourceUrl ?? this.msgResourceUrl,
      sign: sign ?? this.sign,
      ext: ext ?? this.ext,
      isRead: isRead ?? this.isRead,
      isTap: isTap ?? this.isTap,
      microtime: microtime ?? this.microtime,
      msgSendStatus: msgSendStatus ?? this.msgSendStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (acountUuid.present) {
      map['acount_uuid'] = Variable<String>(acountUuid.value);
    }
    if (acountAvatar.present) {
      map['acount_avatar'] = Variable<String>(acountAvatar.value);
    }
    if (userUuid.present) {
      map['user_uuid'] = Variable<String>(userUuid.value);
    }
    if (userAvatar.present) {
      map['user_avatar'] = Variable<String>(userAvatar.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (msgSendTime.present) {
      map['msg_send_time'] = Variable<String>(msgSendTime.value);
    }
    if (msgResourceUrl.present) {
      map['msg_resource_url'] = Variable<String>(msgResourceUrl.value);
    }
    if (sign.present) {
      map['sign'] = Variable<String>(sign.value);
    }
    if (ext.present) {
      map['ext'] = Variable<String>(ext.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isTap.present) {
      map['is_tap'] = Variable<bool>(isTap.value);
    }
    if (microtime.present) {
      map['microtime'] = Variable<int>(microtime.value);
    }
    if (msgSendStatus.present) {
      map['msg_send_status'] = Variable<int>(msgSendStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('acountUuid: $acountUuid, ')
          ..write('acountAvatar: $acountAvatar, ')
          ..write('userUuid: $userUuid, ')
          ..write('userAvatar: $userAvatar, ')
          ..write('content: $content, ')
          ..write('contentType: $contentType, ')
          ..write('msgSendTime: $msgSendTime, ')
          ..write('msgResourceUrl: $msgResourceUrl, ')
          ..write('sign: $sign, ')
          ..write('ext: $ext, ')
          ..write('isRead: $isRead, ')
          ..write('isTap: $isTap, ')
          ..write('microtime: $microtime, ')
          ..write('msgSendStatus: $msgSendStatus')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $ContaictTable? _contaict;
  $ContaictTable get contaict => _contaict ??= $ContaictTable(this);
  $MessageTable? _message;
  $MessageTable get message => _message ??= $MessageTable(this);
  @override
  Iterable<TableInfo<Table, Object>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [contaict, message];
}
