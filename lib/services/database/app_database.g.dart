// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayersTable extends Players with TableInfo<$PlayersTable, PlayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class PlayerRow extends DataClass implements Insertable<PlayerRow> {
  final String id;
  final String name;
  final DateTime createdAt;
  const PlayerRow({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory PlayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlayerRow copyWith({String? id, String? name, DateTime? createdAt}) =>
      PlayerRow(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  PlayerRow copyWithCompanion(PlayersCompanion data) {
    return PlayerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PlayersCompanion extends UpdateCompanion<PlayerRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayersCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<PlayerRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchesTable extends Matches with TableInfo<$MatchesTable, MatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameNameMeta = const VerificationMeta(
    'gameName',
  );
  @override
  late final GeneratedColumn<String> gameName = GeneratedColumn<String>(
    'game_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winnerIdMeta = const VerificationMeta(
    'winnerId',
  );
  @override
  late final GeneratedColumn<String> winnerId = GeneratedColumn<String>(
    'winner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _winnerNameMeta = const VerificationMeta(
    'winnerName',
  );
  @override
  late final GeneratedColumn<String> winnerName = GeneratedColumn<String>(
    'winner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameName,
    winnerId,
    winnerName,
    finishedAt,
    configJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_name')) {
      context.handle(
        _gameNameMeta,
        gameName.isAcceptableOrUnknown(data['game_name']!, _gameNameMeta),
      );
    } else if (isInserting) {
      context.missing(_gameNameMeta);
    }
    if (data.containsKey('winner_id')) {
      context.handle(
        _winnerIdMeta,
        winnerId.isAcceptableOrUnknown(data['winner_id']!, _winnerIdMeta),
      );
    }
    if (data.containsKey('winner_name')) {
      context.handle(
        _winnerNameMeta,
        winnerName.isAcceptableOrUnknown(data['winner_name']!, _winnerNameMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_finishedAtMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gameName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_name'],
      )!,
      winnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner_id'],
      ),
      winnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner_name'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      ),
    );
  }

  @override
  $MatchesTable createAlias(String alias) {
    return $MatchesTable(attachedDatabase, alias);
  }
}

class MatchRow extends DataClass implements Insertable<MatchRow> {
  final String id;
  final String gameName;
  final String? winnerId;
  final String? winnerName;
  final DateTime finishedAt;

  /// A snapshot of the small handful of config values (e.g. X01's
  /// startingScore/outRule, Cricket's lowNumber/includeBull) needed to
  /// correctly interpret this match's throws for stats later - added in
  /// schema version 3. Stored as a JSON object, not parsed columns, since
  /// each game needs different fields. This is provenance data (like
  /// gameName), not a computed aggregate - nothing here is ever a stat
  /// itself. Null for matches saved before this column existed; stats
  /// calculators fall back to that game's own config defaults then.
  final String? configJson;
  const MatchRow({
    required this.id,
    required this.gameName,
    this.winnerId,
    this.winnerName,
    required this.finishedAt,
    this.configJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_name'] = Variable<String>(gameName);
    if (!nullToAbsent || winnerId != null) {
      map['winner_id'] = Variable<String>(winnerId);
    }
    if (!nullToAbsent || winnerName != null) {
      map['winner_name'] = Variable<String>(winnerName);
    }
    map['finished_at'] = Variable<DateTime>(finishedAt);
    if (!nullToAbsent || configJson != null) {
      map['config_json'] = Variable<String>(configJson);
    }
    return map;
  }

  MatchesCompanion toCompanion(bool nullToAbsent) {
    return MatchesCompanion(
      id: Value(id),
      gameName: Value(gameName),
      winnerId: winnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerId),
      winnerName: winnerName == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerName),
      finishedAt: Value(finishedAt),
      configJson: configJson == null && nullToAbsent
          ? const Value.absent()
          : Value(configJson),
    );
  }

  factory MatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchRow(
      id: serializer.fromJson<String>(json['id']),
      gameName: serializer.fromJson<String>(json['gameName']),
      winnerId: serializer.fromJson<String?>(json['winnerId']),
      winnerName: serializer.fromJson<String?>(json['winnerName']),
      finishedAt: serializer.fromJson<DateTime>(json['finishedAt']),
      configJson: serializer.fromJson<String?>(json['configJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameName': serializer.toJson<String>(gameName),
      'winnerId': serializer.toJson<String?>(winnerId),
      'winnerName': serializer.toJson<String?>(winnerName),
      'finishedAt': serializer.toJson<DateTime>(finishedAt),
      'configJson': serializer.toJson<String?>(configJson),
    };
  }

  MatchRow copyWith({
    String? id,
    String? gameName,
    Value<String?> winnerId = const Value.absent(),
    Value<String?> winnerName = const Value.absent(),
    DateTime? finishedAt,
    Value<String?> configJson = const Value.absent(),
  }) => MatchRow(
    id: id ?? this.id,
    gameName: gameName ?? this.gameName,
    winnerId: winnerId.present ? winnerId.value : this.winnerId,
    winnerName: winnerName.present ? winnerName.value : this.winnerName,
    finishedAt: finishedAt ?? this.finishedAt,
    configJson: configJson.present ? configJson.value : this.configJson,
  );
  MatchRow copyWithCompanion(MatchesCompanion data) {
    return MatchRow(
      id: data.id.present ? data.id.value : this.id,
      gameName: data.gameName.present ? data.gameName.value : this.gameName,
      winnerId: data.winnerId.present ? data.winnerId.value : this.winnerId,
      winnerName: data.winnerName.present
          ? data.winnerName.value
          : this.winnerName,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchRow(')
          ..write('id: $id, ')
          ..write('gameName: $gameName, ')
          ..write('winnerId: $winnerId, ')
          ..write('winnerName: $winnerName, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('configJson: $configJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gameName, winnerId, winnerName, finishedAt, configJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchRow &&
          other.id == this.id &&
          other.gameName == this.gameName &&
          other.winnerId == this.winnerId &&
          other.winnerName == this.winnerName &&
          other.finishedAt == this.finishedAt &&
          other.configJson == this.configJson);
}

class MatchesCompanion extends UpdateCompanion<MatchRow> {
  final Value<String> id;
  final Value<String> gameName;
  final Value<String?> winnerId;
  final Value<String?> winnerName;
  final Value<DateTime> finishedAt;
  final Value<String?> configJson;
  final Value<int> rowid;
  const MatchesCompanion({
    this.id = const Value.absent(),
    this.gameName = const Value.absent(),
    this.winnerId = const Value.absent(),
    this.winnerName = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.configJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchesCompanion.insert({
    required String id,
    required String gameName,
    this.winnerId = const Value.absent(),
    this.winnerName = const Value.absent(),
    required DateTime finishedAt,
    this.configJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameName = Value(gameName),
       finishedAt = Value(finishedAt);
  static Insertable<MatchRow> custom({
    Expression<String>? id,
    Expression<String>? gameName,
    Expression<String>? winnerId,
    Expression<String>? winnerName,
    Expression<DateTime>? finishedAt,
    Expression<String>? configJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameName != null) 'game_name': gameName,
      if (winnerId != null) 'winner_id': winnerId,
      if (winnerName != null) 'winner_name': winnerName,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (configJson != null) 'config_json': configJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? gameName,
    Value<String?>? winnerId,
    Value<String?>? winnerName,
    Value<DateTime>? finishedAt,
    Value<String?>? configJson,
    Value<int>? rowid,
  }) {
    return MatchesCompanion(
      id: id ?? this.id,
      gameName: gameName ?? this.gameName,
      winnerId: winnerId ?? this.winnerId,
      winnerName: winnerName ?? this.winnerName,
      finishedAt: finishedAt ?? this.finishedAt,
      configJson: configJson ?? this.configJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameName.present) {
      map['game_name'] = Variable<String>(gameName.value);
    }
    if (winnerId.present) {
      map['winner_id'] = Variable<String>(winnerId.value);
    }
    if (winnerName.present) {
      map['winner_name'] = Variable<String>(winnerName.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesCompanion(')
          ..write('id: $id, ')
          ..write('gameName: $gameName, ')
          ..write('winnerId: $winnerId, ')
          ..write('winnerName: $winnerName, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('configJson: $configJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchPlayersTable extends MatchPlayers
    with TableInfo<$MatchPlayersTable, MatchPlayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchPlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerNameMeta = const VerificationMeta(
    'playerName',
  );
  @override
  late final GeneratedColumn<String> playerName = GeneratedColumn<String>(
    'player_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _botProfileIdMeta = const VerificationMeta(
    'botProfileId',
  );
  @override
  late final GeneratedColumn<String> botProfileId = GeneratedColumn<String>(
    'bot_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    matchId,
    playerId,
    playerName,
    orderIndex,
    botProfileId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'match_players';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchPlayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('player_name')) {
      context.handle(
        _playerNameMeta,
        playerName.isAcceptableOrUnknown(data['player_name']!, _playerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_playerNameMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('bot_profile_id')) {
      context.handle(
        _botProfileIdMeta,
        botProfileId.isAcceptableOrUnknown(
          data['bot_profile_id']!,
          _botProfileIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {matchId, orderIndex};
  @override
  MatchPlayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchPlayerRow(
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      playerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_name'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      botProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bot_profile_id'],
      ),
    );
  }

  @override
  $MatchPlayersTable createAlias(String alias) {
    return $MatchPlayersTable(attachedDatabase, alias);
  }
}

class MatchPlayerRow extends DataClass implements Insertable<MatchPlayerRow> {
  final String matchId;
  final String playerId;
  final String playerName;
  final int orderIndex;

  /// Set when this participant was a bot rather than a human, pointing at
  /// the BotProfile it was played with - added in schema version 4. Null
  /// for every human participant. playerId/playerName still hold the bot's
  /// id/name the same as a human's, so existing lookups keep working
  /// unchanged; this column only adds the ability to tell bots apart from
  /// humans and find which profile a bot match was played against.
  final String? botProfileId;
  const MatchPlayerRow({
    required this.matchId,
    required this.playerId,
    required this.playerName,
    required this.orderIndex,
    this.botProfileId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['match_id'] = Variable<String>(matchId);
    map['player_id'] = Variable<String>(playerId);
    map['player_name'] = Variable<String>(playerName);
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || botProfileId != null) {
      map['bot_profile_id'] = Variable<String>(botProfileId);
    }
    return map;
  }

  MatchPlayersCompanion toCompanion(bool nullToAbsent) {
    return MatchPlayersCompanion(
      matchId: Value(matchId),
      playerId: Value(playerId),
      playerName: Value(playerName),
      orderIndex: Value(orderIndex),
      botProfileId: botProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(botProfileId),
    );
  }

  factory MatchPlayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchPlayerRow(
      matchId: serializer.fromJson<String>(json['matchId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      playerName: serializer.fromJson<String>(json['playerName']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      botProfileId: serializer.fromJson<String?>(json['botProfileId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'matchId': serializer.toJson<String>(matchId),
      'playerId': serializer.toJson<String>(playerId),
      'playerName': serializer.toJson<String>(playerName),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'botProfileId': serializer.toJson<String?>(botProfileId),
    };
  }

  MatchPlayerRow copyWith({
    String? matchId,
    String? playerId,
    String? playerName,
    int? orderIndex,
    Value<String?> botProfileId = const Value.absent(),
  }) => MatchPlayerRow(
    matchId: matchId ?? this.matchId,
    playerId: playerId ?? this.playerId,
    playerName: playerName ?? this.playerName,
    orderIndex: orderIndex ?? this.orderIndex,
    botProfileId: botProfileId.present ? botProfileId.value : this.botProfileId,
  );
  MatchPlayerRow copyWithCompanion(MatchPlayersCompanion data) {
    return MatchPlayerRow(
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      playerName: data.playerName.present
          ? data.playerName.value
          : this.playerName,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      botProfileId: data.botProfileId.present
          ? data.botProfileId.value
          : this.botProfileId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchPlayerRow(')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('playerName: $playerName, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('botProfileId: $botProfileId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(matchId, playerId, playerName, orderIndex, botProfileId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchPlayerRow &&
          other.matchId == this.matchId &&
          other.playerId == this.playerId &&
          other.playerName == this.playerName &&
          other.orderIndex == this.orderIndex &&
          other.botProfileId == this.botProfileId);
}

class MatchPlayersCompanion extends UpdateCompanion<MatchPlayerRow> {
  final Value<String> matchId;
  final Value<String> playerId;
  final Value<String> playerName;
  final Value<int> orderIndex;
  final Value<String?> botProfileId;
  final Value<int> rowid;
  const MatchPlayersCompanion({
    this.matchId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.playerName = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.botProfileId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchPlayersCompanion.insert({
    required String matchId,
    required String playerId,
    required String playerName,
    required int orderIndex,
    this.botProfileId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : matchId = Value(matchId),
       playerId = Value(playerId),
       playerName = Value(playerName),
       orderIndex = Value(orderIndex);
  static Insertable<MatchPlayerRow> custom({
    Expression<String>? matchId,
    Expression<String>? playerId,
    Expression<String>? playerName,
    Expression<int>? orderIndex,
    Expression<String>? botProfileId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (matchId != null) 'match_id': matchId,
      if (playerId != null) 'player_id': playerId,
      if (playerName != null) 'player_name': playerName,
      if (orderIndex != null) 'order_index': orderIndex,
      if (botProfileId != null) 'bot_profile_id': botProfileId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchPlayersCompanion copyWith({
    Value<String>? matchId,
    Value<String>? playerId,
    Value<String>? playerName,
    Value<int>? orderIndex,
    Value<String?>? botProfileId,
    Value<int>? rowid,
  }) {
    return MatchPlayersCompanion(
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      orderIndex: orderIndex ?? this.orderIndex,
      botProfileId: botProfileId ?? this.botProfileId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (playerName.present) {
      map['player_name'] = Variable<String>(playerName.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (botProfileId.present) {
      map['bot_profile_id'] = Variable<String>(botProfileId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchPlayersCompanion(')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('playerName: $playerName, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('botProfileId: $botProfileId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TurnsTable extends Turns with TableInfo<$TurnsTable, TurnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerNameMeta = const VerificationMeta(
    'playerName',
  );
  @override
  late final GeneratedColumn<String> playerName = GeneratedColumn<String>(
    'player_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legNumberMeta = const VerificationMeta(
    'legNumber',
  );
  @override
  late final GeneratedColumn<int> legNumber = GeneratedColumn<int>(
    'leg_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'set_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    matchId,
    playerId,
    playerName,
    orderIndex,
    legNumber,
    setNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turns';
  @override
  VerificationContext validateIntegrity(
    Insertable<TurnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('player_name')) {
      context.handle(
        _playerNameMeta,
        playerName.isAcceptableOrUnknown(data['player_name']!, _playerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_playerNameMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('leg_number')) {
      context.handle(
        _legNumberMeta,
        legNumber.isAcceptableOrUnknown(data['leg_number']!, _legNumberMeta),
      );
    }
    if (data.containsKey('set_number')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['set_number']!, _setNumberMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TurnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TurnRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      playerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_name'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      legNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leg_number'],
      )!,
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_number'],
      )!,
    );
  }

  @override
  $TurnsTable createAlias(String alias) {
    return $TurnsTable(attachedDatabase, alias);
  }
}

class TurnRow extends DataClass implements Insertable<TurnRow> {
  final int id;
  final String matchId;
  final String playerId;
  final String playerName;
  final int orderIndex;

  /// Which leg/set this turn belongs to. Only X01 ever uses more than 1 -
  /// every other game is single-leg, single-set.
  final int legNumber;
  final int setNumber;
  const TurnRow({
    required this.id,
    required this.matchId,
    required this.playerId,
    required this.playerName,
    required this.orderIndex,
    required this.legNumber,
    required this.setNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['match_id'] = Variable<String>(matchId);
    map['player_id'] = Variable<String>(playerId);
    map['player_name'] = Variable<String>(playerName);
    map['order_index'] = Variable<int>(orderIndex);
    map['leg_number'] = Variable<int>(legNumber);
    map['set_number'] = Variable<int>(setNumber);
    return map;
  }

  TurnsCompanion toCompanion(bool nullToAbsent) {
    return TurnsCompanion(
      id: Value(id),
      matchId: Value(matchId),
      playerId: Value(playerId),
      playerName: Value(playerName),
      orderIndex: Value(orderIndex),
      legNumber: Value(legNumber),
      setNumber: Value(setNumber),
    );
  }

  factory TurnRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TurnRow(
      id: serializer.fromJson<int>(json['id']),
      matchId: serializer.fromJson<String>(json['matchId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      playerName: serializer.fromJson<String>(json['playerName']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      legNumber: serializer.fromJson<int>(json['legNumber']),
      setNumber: serializer.fromJson<int>(json['setNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'matchId': serializer.toJson<String>(matchId),
      'playerId': serializer.toJson<String>(playerId),
      'playerName': serializer.toJson<String>(playerName),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'legNumber': serializer.toJson<int>(legNumber),
      'setNumber': serializer.toJson<int>(setNumber),
    };
  }

  TurnRow copyWith({
    int? id,
    String? matchId,
    String? playerId,
    String? playerName,
    int? orderIndex,
    int? legNumber,
    int? setNumber,
  }) => TurnRow(
    id: id ?? this.id,
    matchId: matchId ?? this.matchId,
    playerId: playerId ?? this.playerId,
    playerName: playerName ?? this.playerName,
    orderIndex: orderIndex ?? this.orderIndex,
    legNumber: legNumber ?? this.legNumber,
    setNumber: setNumber ?? this.setNumber,
  );
  TurnRow copyWithCompanion(TurnsCompanion data) {
    return TurnRow(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      playerName: data.playerName.present
          ? data.playerName.value
          : this.playerName,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      legNumber: data.legNumber.present ? data.legNumber.value : this.legNumber,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TurnRow(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('playerName: $playerName, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('legNumber: $legNumber, ')
          ..write('setNumber: $setNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    matchId,
    playerId,
    playerName,
    orderIndex,
    legNumber,
    setNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TurnRow &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.playerId == this.playerId &&
          other.playerName == this.playerName &&
          other.orderIndex == this.orderIndex &&
          other.legNumber == this.legNumber &&
          other.setNumber == this.setNumber);
}

class TurnsCompanion extends UpdateCompanion<TurnRow> {
  final Value<int> id;
  final Value<String> matchId;
  final Value<String> playerId;
  final Value<String> playerName;
  final Value<int> orderIndex;
  final Value<int> legNumber;
  final Value<int> setNumber;
  const TurnsCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.playerName = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.legNumber = const Value.absent(),
    this.setNumber = const Value.absent(),
  });
  TurnsCompanion.insert({
    this.id = const Value.absent(),
    required String matchId,
    required String playerId,
    required String playerName,
    required int orderIndex,
    this.legNumber = const Value.absent(),
    this.setNumber = const Value.absent(),
  }) : matchId = Value(matchId),
       playerId = Value(playerId),
       playerName = Value(playerName),
       orderIndex = Value(orderIndex);
  static Insertable<TurnRow> custom({
    Expression<int>? id,
    Expression<String>? matchId,
    Expression<String>? playerId,
    Expression<String>? playerName,
    Expression<int>? orderIndex,
    Expression<int>? legNumber,
    Expression<int>? setNumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (playerId != null) 'player_id': playerId,
      if (playerName != null) 'player_name': playerName,
      if (orderIndex != null) 'order_index': orderIndex,
      if (legNumber != null) 'leg_number': legNumber,
      if (setNumber != null) 'set_number': setNumber,
    });
  }

  TurnsCompanion copyWith({
    Value<int>? id,
    Value<String>? matchId,
    Value<String>? playerId,
    Value<String>? playerName,
    Value<int>? orderIndex,
    Value<int>? legNumber,
    Value<int>? setNumber,
  }) {
    return TurnsCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      orderIndex: orderIndex ?? this.orderIndex,
      legNumber: legNumber ?? this.legNumber,
      setNumber: setNumber ?? this.setNumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (playerName.present) {
      map['player_name'] = Variable<String>(playerName.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (legNumber.present) {
      map['leg_number'] = Variable<int>(legNumber.value);
    }
    if (setNumber.present) {
      map['set_number'] = Variable<int>(setNumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TurnsCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('playerName: $playerName, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('legNumber: $legNumber, ')
          ..write('setNumber: $setNumber')
          ..write(')'))
        .toString();
  }
}

class $ThrowsTable extends Throws with TableInfo<$ThrowsTable, ThrowRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThrowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _turnIdMeta = const VerificationMeta('turnId');
  @override
  late final GeneratedColumn<int> turnId = GeneratedColumn<int>(
    'turn_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualSegmentMeta = const VerificationMeta(
    'actualSegment',
  );
  @override
  late final GeneratedColumn<int> actualSegment = GeneratedColumn<int>(
    'actual_segment',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _multiplierMeta = const VerificationMeta(
    'multiplier',
  );
  @override
  late final GeneratedColumn<int> multiplier = GeneratedColumn<int>(
    'multiplier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultingScoreDeltaMeta =
      const VerificationMeta('resultingScoreDelta');
  @override
  late final GeneratedColumn<int> resultingScoreDelta = GeneratedColumn<int>(
    'resulting_score_delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _landingRadiusMeta = const VerificationMeta(
    'landingRadius',
  );
  @override
  late final GeneratedColumn<double> landingRadius = GeneratedColumn<double>(
    'landing_radius',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _landingAngleDegreesMeta =
      const VerificationMeta('landingAngleDegrees');
  @override
  late final GeneratedColumn<double> landingAngleDegrees =
      GeneratedColumn<double>(
        'landing_angle_degrees',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _landingCoordVersionMeta =
      const VerificationMeta('landingCoordVersion');
  @override
  late final GeneratedColumn<int> landingCoordVersion = GeneratedColumn<int>(
    'landing_coord_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intendedTargetMeta = const VerificationMeta(
    'intendedTarget',
  );
  @override
  late final GeneratedColumn<int> intendedTarget = GeneratedColumn<int>(
    'intended_target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    turnId,
    timestamp,
    actualSegment,
    multiplier,
    resultingScoreDelta,
    gameId,
    source,
    landingRadius,
    landingAngleDegrees,
    landingCoordVersion,
    intendedTarget,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'throws';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThrowRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('turn_id')) {
      context.handle(
        _turnIdMeta,
        turnId.isAcceptableOrUnknown(data['turn_id']!, _turnIdMeta),
      );
    } else if (isInserting) {
      context.missing(_turnIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('actual_segment')) {
      context.handle(
        _actualSegmentMeta,
        actualSegment.isAcceptableOrUnknown(
          data['actual_segment']!,
          _actualSegmentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualSegmentMeta);
    }
    if (data.containsKey('multiplier')) {
      context.handle(
        _multiplierMeta,
        multiplier.isAcceptableOrUnknown(data['multiplier']!, _multiplierMeta),
      );
    } else if (isInserting) {
      context.missing(_multiplierMeta);
    }
    if (data.containsKey('resulting_score_delta')) {
      context.handle(
        _resultingScoreDeltaMeta,
        resultingScoreDelta.isAcceptableOrUnknown(
          data['resulting_score_delta']!,
          _resultingScoreDeltaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resultingScoreDeltaMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('landing_radius')) {
      context.handle(
        _landingRadiusMeta,
        landingRadius.isAcceptableOrUnknown(
          data['landing_radius']!,
          _landingRadiusMeta,
        ),
      );
    }
    if (data.containsKey('landing_angle_degrees')) {
      context.handle(
        _landingAngleDegreesMeta,
        landingAngleDegrees.isAcceptableOrUnknown(
          data['landing_angle_degrees']!,
          _landingAngleDegreesMeta,
        ),
      );
    }
    if (data.containsKey('landing_coord_version')) {
      context.handle(
        _landingCoordVersionMeta,
        landingCoordVersion.isAcceptableOrUnknown(
          data['landing_coord_version']!,
          _landingCoordVersionMeta,
        ),
      );
    }
    if (data.containsKey('intended_target')) {
      context.handle(
        _intendedTargetMeta,
        intendedTarget.isAcceptableOrUnknown(
          data['intended_target']!,
          _intendedTargetMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThrowRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThrowRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      turnId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turn_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      actualSegment: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_segment'],
      )!,
      multiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}multiplier'],
      )!,
      resultingScoreDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resulting_score_delta'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      landingRadius: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}landing_radius'],
      ),
      landingAngleDegrees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}landing_angle_degrees'],
      ),
      landingCoordVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}landing_coord_version'],
      ),
      intendedTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intended_target'],
      ),
    );
  }

  @override
  $ThrowsTable createAlias(String alias) {
    return $ThrowsTable(attachedDatabase, alias);
  }
}

class ThrowRow extends DataClass implements Insertable<ThrowRow> {
  final int id;
  final int turnId;
  final DateTime timestamp;
  final int actualSegment;
  final int multiplier;
  final int resultingScoreDelta;
  final String gameId;

  /// Stored as the enum's name (e.g. "manual"), not its index - so
  /// reordering the ThrowSource enum later can never silently misread old
  /// rows. Same reasoning as DartPosition.boardCoordinateSystemVersion.
  final String source;

  /// Flattened DartPosition (landingPosition on Throw). Always null for
  /// manual entry. Kept as plain columns rather than a JSON blob.
  final double? landingRadius;
  final double? landingAngleDegrees;
  final int? landingCoordVersion;

  /// Mirrors Throw.intendedTarget - added in schema version 2. Null
  /// everywhere except Round the Clock, which fills it in with the
  /// player's target at the moment they threw.
  final int? intendedTarget;
  const ThrowRow({
    required this.id,
    required this.turnId,
    required this.timestamp,
    required this.actualSegment,
    required this.multiplier,
    required this.resultingScoreDelta,
    required this.gameId,
    required this.source,
    this.landingRadius,
    this.landingAngleDegrees,
    this.landingCoordVersion,
    this.intendedTarget,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['turn_id'] = Variable<int>(turnId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['actual_segment'] = Variable<int>(actualSegment);
    map['multiplier'] = Variable<int>(multiplier);
    map['resulting_score_delta'] = Variable<int>(resultingScoreDelta);
    map['game_id'] = Variable<String>(gameId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || landingRadius != null) {
      map['landing_radius'] = Variable<double>(landingRadius);
    }
    if (!nullToAbsent || landingAngleDegrees != null) {
      map['landing_angle_degrees'] = Variable<double>(landingAngleDegrees);
    }
    if (!nullToAbsent || landingCoordVersion != null) {
      map['landing_coord_version'] = Variable<int>(landingCoordVersion);
    }
    if (!nullToAbsent || intendedTarget != null) {
      map['intended_target'] = Variable<int>(intendedTarget);
    }
    return map;
  }

  ThrowsCompanion toCompanion(bool nullToAbsent) {
    return ThrowsCompanion(
      id: Value(id),
      turnId: Value(turnId),
      timestamp: Value(timestamp),
      actualSegment: Value(actualSegment),
      multiplier: Value(multiplier),
      resultingScoreDelta: Value(resultingScoreDelta),
      gameId: Value(gameId),
      source: Value(source),
      landingRadius: landingRadius == null && nullToAbsent
          ? const Value.absent()
          : Value(landingRadius),
      landingAngleDegrees: landingAngleDegrees == null && nullToAbsent
          ? const Value.absent()
          : Value(landingAngleDegrees),
      landingCoordVersion: landingCoordVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(landingCoordVersion),
      intendedTarget: intendedTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(intendedTarget),
    );
  }

  factory ThrowRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThrowRow(
      id: serializer.fromJson<int>(json['id']),
      turnId: serializer.fromJson<int>(json['turnId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      actualSegment: serializer.fromJson<int>(json['actualSegment']),
      multiplier: serializer.fromJson<int>(json['multiplier']),
      resultingScoreDelta: serializer.fromJson<int>(
        json['resultingScoreDelta'],
      ),
      gameId: serializer.fromJson<String>(json['gameId']),
      source: serializer.fromJson<String>(json['source']),
      landingRadius: serializer.fromJson<double?>(json['landingRadius']),
      landingAngleDegrees: serializer.fromJson<double?>(
        json['landingAngleDegrees'],
      ),
      landingCoordVersion: serializer.fromJson<int?>(
        json['landingCoordVersion'],
      ),
      intendedTarget: serializer.fromJson<int?>(json['intendedTarget']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'turnId': serializer.toJson<int>(turnId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'actualSegment': serializer.toJson<int>(actualSegment),
      'multiplier': serializer.toJson<int>(multiplier),
      'resultingScoreDelta': serializer.toJson<int>(resultingScoreDelta),
      'gameId': serializer.toJson<String>(gameId),
      'source': serializer.toJson<String>(source),
      'landingRadius': serializer.toJson<double?>(landingRadius),
      'landingAngleDegrees': serializer.toJson<double?>(landingAngleDegrees),
      'landingCoordVersion': serializer.toJson<int?>(landingCoordVersion),
      'intendedTarget': serializer.toJson<int?>(intendedTarget),
    };
  }

  ThrowRow copyWith({
    int? id,
    int? turnId,
    DateTime? timestamp,
    int? actualSegment,
    int? multiplier,
    int? resultingScoreDelta,
    String? gameId,
    String? source,
    Value<double?> landingRadius = const Value.absent(),
    Value<double?> landingAngleDegrees = const Value.absent(),
    Value<int?> landingCoordVersion = const Value.absent(),
    Value<int?> intendedTarget = const Value.absent(),
  }) => ThrowRow(
    id: id ?? this.id,
    turnId: turnId ?? this.turnId,
    timestamp: timestamp ?? this.timestamp,
    actualSegment: actualSegment ?? this.actualSegment,
    multiplier: multiplier ?? this.multiplier,
    resultingScoreDelta: resultingScoreDelta ?? this.resultingScoreDelta,
    gameId: gameId ?? this.gameId,
    source: source ?? this.source,
    landingRadius: landingRadius.present
        ? landingRadius.value
        : this.landingRadius,
    landingAngleDegrees: landingAngleDegrees.present
        ? landingAngleDegrees.value
        : this.landingAngleDegrees,
    landingCoordVersion: landingCoordVersion.present
        ? landingCoordVersion.value
        : this.landingCoordVersion,
    intendedTarget: intendedTarget.present
        ? intendedTarget.value
        : this.intendedTarget,
  );
  ThrowRow copyWithCompanion(ThrowsCompanion data) {
    return ThrowRow(
      id: data.id.present ? data.id.value : this.id,
      turnId: data.turnId.present ? data.turnId.value : this.turnId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      actualSegment: data.actualSegment.present
          ? data.actualSegment.value
          : this.actualSegment,
      multiplier: data.multiplier.present
          ? data.multiplier.value
          : this.multiplier,
      resultingScoreDelta: data.resultingScoreDelta.present
          ? data.resultingScoreDelta.value
          : this.resultingScoreDelta,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      source: data.source.present ? data.source.value : this.source,
      landingRadius: data.landingRadius.present
          ? data.landingRadius.value
          : this.landingRadius,
      landingAngleDegrees: data.landingAngleDegrees.present
          ? data.landingAngleDegrees.value
          : this.landingAngleDegrees,
      landingCoordVersion: data.landingCoordVersion.present
          ? data.landingCoordVersion.value
          : this.landingCoordVersion,
      intendedTarget: data.intendedTarget.present
          ? data.intendedTarget.value
          : this.intendedTarget,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThrowRow(')
          ..write('id: $id, ')
          ..write('turnId: $turnId, ')
          ..write('timestamp: $timestamp, ')
          ..write('actualSegment: $actualSegment, ')
          ..write('multiplier: $multiplier, ')
          ..write('resultingScoreDelta: $resultingScoreDelta, ')
          ..write('gameId: $gameId, ')
          ..write('source: $source, ')
          ..write('landingRadius: $landingRadius, ')
          ..write('landingAngleDegrees: $landingAngleDegrees, ')
          ..write('landingCoordVersion: $landingCoordVersion, ')
          ..write('intendedTarget: $intendedTarget')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    turnId,
    timestamp,
    actualSegment,
    multiplier,
    resultingScoreDelta,
    gameId,
    source,
    landingRadius,
    landingAngleDegrees,
    landingCoordVersion,
    intendedTarget,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThrowRow &&
          other.id == this.id &&
          other.turnId == this.turnId &&
          other.timestamp == this.timestamp &&
          other.actualSegment == this.actualSegment &&
          other.multiplier == this.multiplier &&
          other.resultingScoreDelta == this.resultingScoreDelta &&
          other.gameId == this.gameId &&
          other.source == this.source &&
          other.landingRadius == this.landingRadius &&
          other.landingAngleDegrees == this.landingAngleDegrees &&
          other.landingCoordVersion == this.landingCoordVersion &&
          other.intendedTarget == this.intendedTarget);
}

class ThrowsCompanion extends UpdateCompanion<ThrowRow> {
  final Value<int> id;
  final Value<int> turnId;
  final Value<DateTime> timestamp;
  final Value<int> actualSegment;
  final Value<int> multiplier;
  final Value<int> resultingScoreDelta;
  final Value<String> gameId;
  final Value<String> source;
  final Value<double?> landingRadius;
  final Value<double?> landingAngleDegrees;
  final Value<int?> landingCoordVersion;
  final Value<int?> intendedTarget;
  const ThrowsCompanion({
    this.id = const Value.absent(),
    this.turnId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.actualSegment = const Value.absent(),
    this.multiplier = const Value.absent(),
    this.resultingScoreDelta = const Value.absent(),
    this.gameId = const Value.absent(),
    this.source = const Value.absent(),
    this.landingRadius = const Value.absent(),
    this.landingAngleDegrees = const Value.absent(),
    this.landingCoordVersion = const Value.absent(),
    this.intendedTarget = const Value.absent(),
  });
  ThrowsCompanion.insert({
    this.id = const Value.absent(),
    required int turnId,
    required DateTime timestamp,
    required int actualSegment,
    required int multiplier,
    required int resultingScoreDelta,
    required String gameId,
    required String source,
    this.landingRadius = const Value.absent(),
    this.landingAngleDegrees = const Value.absent(),
    this.landingCoordVersion = const Value.absent(),
    this.intendedTarget = const Value.absent(),
  }) : turnId = Value(turnId),
       timestamp = Value(timestamp),
       actualSegment = Value(actualSegment),
       multiplier = Value(multiplier),
       resultingScoreDelta = Value(resultingScoreDelta),
       gameId = Value(gameId),
       source = Value(source);
  static Insertable<ThrowRow> custom({
    Expression<int>? id,
    Expression<int>? turnId,
    Expression<DateTime>? timestamp,
    Expression<int>? actualSegment,
    Expression<int>? multiplier,
    Expression<int>? resultingScoreDelta,
    Expression<String>? gameId,
    Expression<String>? source,
    Expression<double>? landingRadius,
    Expression<double>? landingAngleDegrees,
    Expression<int>? landingCoordVersion,
    Expression<int>? intendedTarget,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (turnId != null) 'turn_id': turnId,
      if (timestamp != null) 'timestamp': timestamp,
      if (actualSegment != null) 'actual_segment': actualSegment,
      if (multiplier != null) 'multiplier': multiplier,
      if (resultingScoreDelta != null)
        'resulting_score_delta': resultingScoreDelta,
      if (gameId != null) 'game_id': gameId,
      if (source != null) 'source': source,
      if (landingRadius != null) 'landing_radius': landingRadius,
      if (landingAngleDegrees != null)
        'landing_angle_degrees': landingAngleDegrees,
      if (landingCoordVersion != null)
        'landing_coord_version': landingCoordVersion,
      if (intendedTarget != null) 'intended_target': intendedTarget,
    });
  }

  ThrowsCompanion copyWith({
    Value<int>? id,
    Value<int>? turnId,
    Value<DateTime>? timestamp,
    Value<int>? actualSegment,
    Value<int>? multiplier,
    Value<int>? resultingScoreDelta,
    Value<String>? gameId,
    Value<String>? source,
    Value<double?>? landingRadius,
    Value<double?>? landingAngleDegrees,
    Value<int?>? landingCoordVersion,
    Value<int?>? intendedTarget,
  }) {
    return ThrowsCompanion(
      id: id ?? this.id,
      turnId: turnId ?? this.turnId,
      timestamp: timestamp ?? this.timestamp,
      actualSegment: actualSegment ?? this.actualSegment,
      multiplier: multiplier ?? this.multiplier,
      resultingScoreDelta: resultingScoreDelta ?? this.resultingScoreDelta,
      gameId: gameId ?? this.gameId,
      source: source ?? this.source,
      landingRadius: landingRadius ?? this.landingRadius,
      landingAngleDegrees: landingAngleDegrees ?? this.landingAngleDegrees,
      landingCoordVersion: landingCoordVersion ?? this.landingCoordVersion,
      intendedTarget: intendedTarget ?? this.intendedTarget,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (turnId.present) {
      map['turn_id'] = Variable<int>(turnId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (actualSegment.present) {
      map['actual_segment'] = Variable<int>(actualSegment.value);
    }
    if (multiplier.present) {
      map['multiplier'] = Variable<int>(multiplier.value);
    }
    if (resultingScoreDelta.present) {
      map['resulting_score_delta'] = Variable<int>(resultingScoreDelta.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (landingRadius.present) {
      map['landing_radius'] = Variable<double>(landingRadius.value);
    }
    if (landingAngleDegrees.present) {
      map['landing_angle_degrees'] = Variable<double>(
        landingAngleDegrees.value,
      );
    }
    if (landingCoordVersion.present) {
      map['landing_coord_version'] = Variable<int>(landingCoordVersion.value);
    }
    if (intendedTarget.present) {
      map['intended_target'] = Variable<int>(intendedTarget.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThrowsCompanion(')
          ..write('id: $id, ')
          ..write('turnId: $turnId, ')
          ..write('timestamp: $timestamp, ')
          ..write('actualSegment: $actualSegment, ')
          ..write('multiplier: $multiplier, ')
          ..write('resultingScoreDelta: $resultingScoreDelta, ')
          ..write('gameId: $gameId, ')
          ..write('source: $source, ')
          ..write('landingRadius: $landingRadius, ')
          ..write('landingAngleDegrees: $landingAngleDegrees, ')
          ..write('landingCoordVersion: $landingCoordVersion, ')
          ..write('intendedTarget: $intendedTarget')
          ..write(')'))
        .toString();
  }
}

class $BotProfilesTable extends BotProfiles
    with TableInfo<$BotProfilesTable, BotProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BotProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sigmaMmMeta = const VerificationMeta(
    'sigmaMm',
  );
  @override
  late final GeneratedColumn<double> sigmaMm = GeneratedColumn<double>(
    'sigma_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAverageMeta = const VerificationMeta(
    'targetAverage',
  );
  @override
  late final GeneratedColumn<double> targetAverage = GeneratedColumn<double>(
    'target_average',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measuredCheckoutPercentMeta =
      const VerificationMeta('measuredCheckoutPercent');
  @override
  late final GeneratedColumn<double> measuredCheckoutPercent =
      GeneratedColumn<double>(
        'measured_checkout_percent',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isPresetMeta = const VerificationMeta(
    'isPreset',
  );
  @override
  late final GeneratedColumn<bool> isPreset = GeneratedColumn<bool>(
    'is_preset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preset" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sigmaMm,
    targetAverage,
    measuredCheckoutPercent,
    isPreset,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bot_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<BotProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sigma_mm')) {
      context.handle(
        _sigmaMmMeta,
        sigmaMm.isAcceptableOrUnknown(data['sigma_mm']!, _sigmaMmMeta),
      );
    } else if (isInserting) {
      context.missing(_sigmaMmMeta);
    }
    if (data.containsKey('target_average')) {
      context.handle(
        _targetAverageMeta,
        targetAverage.isAcceptableOrUnknown(
          data['target_average']!,
          _targetAverageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAverageMeta);
    }
    if (data.containsKey('measured_checkout_percent')) {
      context.handle(
        _measuredCheckoutPercentMeta,
        measuredCheckoutPercent.isAcceptableOrUnknown(
          data['measured_checkout_percent']!,
          _measuredCheckoutPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measuredCheckoutPercentMeta);
    }
    if (data.containsKey('is_preset')) {
      context.handle(
        _isPresetMeta,
        isPreset.isAcceptableOrUnknown(data['is_preset']!, _isPresetMeta),
      );
    } else if (isInserting) {
      context.missing(_isPresetMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BotProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BotProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sigmaMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sigma_mm'],
      )!,
      targetAverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_average'],
      )!,
      measuredCheckoutPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}measured_checkout_percent'],
      )!,
      isPreset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_preset'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BotProfilesTable createAlias(String alias) {
    return $BotProfilesTable(attachedDatabase, alias);
  }
}

class BotProfileRow extends DataClass implements Insertable<BotProfileRow> {
  final String id;
  final String name;
  final double sigmaMm;
  final double targetAverage;
  final double measuredCheckoutPercent;
  final bool isPreset;
  final DateTime createdAt;
  const BotProfileRow({
    required this.id,
    required this.name,
    required this.sigmaMm,
    required this.targetAverage,
    required this.measuredCheckoutPercent,
    required this.isPreset,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sigma_mm'] = Variable<double>(sigmaMm);
    map['target_average'] = Variable<double>(targetAverage);
    map['measured_checkout_percent'] = Variable<double>(
      measuredCheckoutPercent,
    );
    map['is_preset'] = Variable<bool>(isPreset);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BotProfilesCompanion toCompanion(bool nullToAbsent) {
    return BotProfilesCompanion(
      id: Value(id),
      name: Value(name),
      sigmaMm: Value(sigmaMm),
      targetAverage: Value(targetAverage),
      measuredCheckoutPercent: Value(measuredCheckoutPercent),
      isPreset: Value(isPreset),
      createdAt: Value(createdAt),
    );
  }

  factory BotProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BotProfileRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sigmaMm: serializer.fromJson<double>(json['sigmaMm']),
      targetAverage: serializer.fromJson<double>(json['targetAverage']),
      measuredCheckoutPercent: serializer.fromJson<double>(
        json['measuredCheckoutPercent'],
      ),
      isPreset: serializer.fromJson<bool>(json['isPreset']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sigmaMm': serializer.toJson<double>(sigmaMm),
      'targetAverage': serializer.toJson<double>(targetAverage),
      'measuredCheckoutPercent': serializer.toJson<double>(
        measuredCheckoutPercent,
      ),
      'isPreset': serializer.toJson<bool>(isPreset),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BotProfileRow copyWith({
    String? id,
    String? name,
    double? sigmaMm,
    double? targetAverage,
    double? measuredCheckoutPercent,
    bool? isPreset,
    DateTime? createdAt,
  }) => BotProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    sigmaMm: sigmaMm ?? this.sigmaMm,
    targetAverage: targetAverage ?? this.targetAverage,
    measuredCheckoutPercent:
        measuredCheckoutPercent ?? this.measuredCheckoutPercent,
    isPreset: isPreset ?? this.isPreset,
    createdAt: createdAt ?? this.createdAt,
  );
  BotProfileRow copyWithCompanion(BotProfilesCompanion data) {
    return BotProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sigmaMm: data.sigmaMm.present ? data.sigmaMm.value : this.sigmaMm,
      targetAverage: data.targetAverage.present
          ? data.targetAverage.value
          : this.targetAverage,
      measuredCheckoutPercent: data.measuredCheckoutPercent.present
          ? data.measuredCheckoutPercent.value
          : this.measuredCheckoutPercent,
      isPreset: data.isPreset.present ? data.isPreset.value : this.isPreset,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BotProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sigmaMm: $sigmaMm, ')
          ..write('targetAverage: $targetAverage, ')
          ..write('measuredCheckoutPercent: $measuredCheckoutPercent, ')
          ..write('isPreset: $isPreset, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sigmaMm,
    targetAverage,
    measuredCheckoutPercent,
    isPreset,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BotProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.sigmaMm == this.sigmaMm &&
          other.targetAverage == this.targetAverage &&
          other.measuredCheckoutPercent == this.measuredCheckoutPercent &&
          other.isPreset == this.isPreset &&
          other.createdAt == this.createdAt);
}

class BotProfilesCompanion extends UpdateCompanion<BotProfileRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> sigmaMm;
  final Value<double> targetAverage;
  final Value<double> measuredCheckoutPercent;
  final Value<bool> isPreset;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BotProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sigmaMm = const Value.absent(),
    this.targetAverage = const Value.absent(),
    this.measuredCheckoutPercent = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BotProfilesCompanion.insert({
    required String id,
    required String name,
    required double sigmaMm,
    required double targetAverage,
    required double measuredCheckoutPercent,
    required bool isPreset,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sigmaMm = Value(sigmaMm),
       targetAverage = Value(targetAverage),
       measuredCheckoutPercent = Value(measuredCheckoutPercent),
       isPreset = Value(isPreset),
       createdAt = Value(createdAt);
  static Insertable<BotProfileRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? sigmaMm,
    Expression<double>? targetAverage,
    Expression<double>? measuredCheckoutPercent,
    Expression<bool>? isPreset,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sigmaMm != null) 'sigma_mm': sigmaMm,
      if (targetAverage != null) 'target_average': targetAverage,
      if (measuredCheckoutPercent != null)
        'measured_checkout_percent': measuredCheckoutPercent,
      if (isPreset != null) 'is_preset': isPreset,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BotProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? sigmaMm,
    Value<double>? targetAverage,
    Value<double>? measuredCheckoutPercent,
    Value<bool>? isPreset,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BotProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sigmaMm: sigmaMm ?? this.sigmaMm,
      targetAverage: targetAverage ?? this.targetAverage,
      measuredCheckoutPercent:
          measuredCheckoutPercent ?? this.measuredCheckoutPercent,
      isPreset: isPreset ?? this.isPreset,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sigmaMm.present) {
      map['sigma_mm'] = Variable<double>(sigmaMm.value);
    }
    if (targetAverage.present) {
      map['target_average'] = Variable<double>(targetAverage.value);
    }
    if (measuredCheckoutPercent.present) {
      map['measured_checkout_percent'] = Variable<double>(
        measuredCheckoutPercent.value,
      );
    }
    if (isPreset.present) {
      map['is_preset'] = Variable<bool>(isPreset.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BotProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sigmaMm: $sigmaMm, ')
          ..write('targetAverage: $targetAverage, ')
          ..write('measuredCheckoutPercent: $measuredCheckoutPercent, ')
          ..write('isPreset: $isPreset, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $MatchesTable matches = $MatchesTable(this);
  late final $MatchPlayersTable matchPlayers = $MatchPlayersTable(this);
  late final $TurnsTable turns = $TurnsTable(this);
  late final $ThrowsTable throws = $ThrowsTable(this);
  late final $BotProfilesTable botProfiles = $BotProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    players,
    matches,
    matchPlayers,
    turns,
    throws,
    botProfiles,
  ];
}

typedef $$PlayersTableCreateCompanionBuilder =
    PlayersCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PlayersTableUpdateCompanionBuilder =
    PlayersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          PlayerRow,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (PlayerRow, BaseReferences<_$AppDatabase, $PlayersTable, PlayerRow>),
          PlayerRow,
          PrefetchHooks Function()
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      PlayerRow,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (PlayerRow, BaseReferences<_$AppDatabase, $PlayersTable, PlayerRow>),
      PlayerRow,
      PrefetchHooks Function()
    >;
typedef $$MatchesTableCreateCompanionBuilder =
    MatchesCompanion Function({
      required String id,
      required String gameName,
      Value<String?> winnerId,
      Value<String?> winnerName,
      required DateTime finishedAt,
      Value<String?> configJson,
      Value<int> rowid,
    });
typedef $$MatchesTableUpdateCompanionBuilder =
    MatchesCompanion Function({
      Value<String> id,
      Value<String> gameName,
      Value<String?> winnerId,
      Value<String?> winnerName,
      Value<DateTime> finishedAt,
      Value<String?> configJson,
      Value<int> rowid,
    });

class $$MatchesTableFilterComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameName => $composableBuilder(
    column: $table.gameName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winnerId => $composableBuilder(
    column: $table.winnerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winnerName => $composableBuilder(
    column: $table.winnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameName => $composableBuilder(
    column: $table.gameName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winnerId => $composableBuilder(
    column: $table.winnerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winnerName => $composableBuilder(
    column: $table.winnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gameName =>
      $composableBuilder(column: $table.gameName, builder: (column) => column);

  GeneratedColumn<String> get winnerId =>
      $composableBuilder(column: $table.winnerId, builder: (column) => column);

  GeneratedColumn<String> get winnerName => $composableBuilder(
    column: $table.winnerName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );
}

class $$MatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchesTable,
          MatchRow,
          $$MatchesTableFilterComposer,
          $$MatchesTableOrderingComposer,
          $$MatchesTableAnnotationComposer,
          $$MatchesTableCreateCompanionBuilder,
          $$MatchesTableUpdateCompanionBuilder,
          (MatchRow, BaseReferences<_$AppDatabase, $MatchesTable, MatchRow>),
          MatchRow,
          PrefetchHooks Function()
        > {
  $$MatchesTableTableManager(_$AppDatabase db, $MatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameName = const Value.absent(),
                Value<String?> winnerId = const Value.absent(),
                Value<String?> winnerName = const Value.absent(),
                Value<DateTime> finishedAt = const Value.absent(),
                Value<String?> configJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchesCompanion(
                id: id,
                gameName: gameName,
                winnerId: winnerId,
                winnerName: winnerName,
                finishedAt: finishedAt,
                configJson: configJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameName,
                Value<String?> winnerId = const Value.absent(),
                Value<String?> winnerName = const Value.absent(),
                required DateTime finishedAt,
                Value<String?> configJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchesCompanion.insert(
                id: id,
                gameName: gameName,
                winnerId: winnerId,
                winnerName: winnerName,
                finishedAt: finishedAt,
                configJson: configJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchesTable,
      MatchRow,
      $$MatchesTableFilterComposer,
      $$MatchesTableOrderingComposer,
      $$MatchesTableAnnotationComposer,
      $$MatchesTableCreateCompanionBuilder,
      $$MatchesTableUpdateCompanionBuilder,
      (MatchRow, BaseReferences<_$AppDatabase, $MatchesTable, MatchRow>),
      MatchRow,
      PrefetchHooks Function()
    >;
typedef $$MatchPlayersTableCreateCompanionBuilder =
    MatchPlayersCompanion Function({
      required String matchId,
      required String playerId,
      required String playerName,
      required int orderIndex,
      Value<String?> botProfileId,
      Value<int> rowid,
    });
typedef $$MatchPlayersTableUpdateCompanionBuilder =
    MatchPlayersCompanion Function({
      Value<String> matchId,
      Value<String> playerId,
      Value<String> playerName,
      Value<int> orderIndex,
      Value<String?> botProfileId,
      Value<int> rowid,
    });

class $$MatchPlayersTableFilterComposer
    extends Composer<_$AppDatabase, $MatchPlayersTable> {
  $$MatchPlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get botProfileId => $composableBuilder(
    column: $table.botProfileId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MatchPlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchPlayersTable> {
  $$MatchPlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get botProfileId => $composableBuilder(
    column: $table.botProfileId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatchPlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchPlayersTable> {
  $$MatchPlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get botProfileId => $composableBuilder(
    column: $table.botProfileId,
    builder: (column) => column,
  );
}

class $$MatchPlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchPlayersTable,
          MatchPlayerRow,
          $$MatchPlayersTableFilterComposer,
          $$MatchPlayersTableOrderingComposer,
          $$MatchPlayersTableAnnotationComposer,
          $$MatchPlayersTableCreateCompanionBuilder,
          $$MatchPlayersTableUpdateCompanionBuilder,
          (
            MatchPlayerRow,
            BaseReferences<_$AppDatabase, $MatchPlayersTable, MatchPlayerRow>,
          ),
          MatchPlayerRow,
          PrefetchHooks Function()
        > {
  $$MatchPlayersTableTableManager(_$AppDatabase db, $MatchPlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchPlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchPlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchPlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> matchId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<String> playerName = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String?> botProfileId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchPlayersCompanion(
                matchId: matchId,
                playerId: playerId,
                playerName: playerName,
                orderIndex: orderIndex,
                botProfileId: botProfileId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String matchId,
                required String playerId,
                required String playerName,
                required int orderIndex,
                Value<String?> botProfileId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchPlayersCompanion.insert(
                matchId: matchId,
                playerId: playerId,
                playerName: playerName,
                orderIndex: orderIndex,
                botProfileId: botProfileId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MatchPlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchPlayersTable,
      MatchPlayerRow,
      $$MatchPlayersTableFilterComposer,
      $$MatchPlayersTableOrderingComposer,
      $$MatchPlayersTableAnnotationComposer,
      $$MatchPlayersTableCreateCompanionBuilder,
      $$MatchPlayersTableUpdateCompanionBuilder,
      (
        MatchPlayerRow,
        BaseReferences<_$AppDatabase, $MatchPlayersTable, MatchPlayerRow>,
      ),
      MatchPlayerRow,
      PrefetchHooks Function()
    >;
typedef $$TurnsTableCreateCompanionBuilder =
    TurnsCompanion Function({
      Value<int> id,
      required String matchId,
      required String playerId,
      required String playerName,
      required int orderIndex,
      Value<int> legNumber,
      Value<int> setNumber,
    });
typedef $$TurnsTableUpdateCompanionBuilder =
    TurnsCompanion Function({
      Value<int> id,
      Value<String> matchId,
      Value<String> playerId,
      Value<String> playerName,
      Value<int> orderIndex,
      Value<int> legNumber,
      Value<int> setNumber,
    });

class $$TurnsTableFilterComposer extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get legNumber => $composableBuilder(
    column: $table.legNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TurnsTableOrderingComposer
    extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get legNumber => $composableBuilder(
    column: $table.legNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TurnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get legNumber =>
      $composableBuilder(column: $table.legNumber, builder: (column) => column);

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);
}

class $$TurnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TurnsTable,
          TurnRow,
          $$TurnsTableFilterComposer,
          $$TurnsTableOrderingComposer,
          $$TurnsTableAnnotationComposer,
          $$TurnsTableCreateCompanionBuilder,
          $$TurnsTableUpdateCompanionBuilder,
          (TurnRow, BaseReferences<_$AppDatabase, $TurnsTable, TurnRow>),
          TurnRow,
          PrefetchHooks Function()
        > {
  $$TurnsTableTableManager(_$AppDatabase db, $TurnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TurnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TurnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TurnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> matchId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<String> playerName = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> legNumber = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
              }) => TurnsCompanion(
                id: id,
                matchId: matchId,
                playerId: playerId,
                playerName: playerName,
                orderIndex: orderIndex,
                legNumber: legNumber,
                setNumber: setNumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String matchId,
                required String playerId,
                required String playerName,
                required int orderIndex,
                Value<int> legNumber = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
              }) => TurnsCompanion.insert(
                id: id,
                matchId: matchId,
                playerId: playerId,
                playerName: playerName,
                orderIndex: orderIndex,
                legNumber: legNumber,
                setNumber: setNumber,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TurnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TurnsTable,
      TurnRow,
      $$TurnsTableFilterComposer,
      $$TurnsTableOrderingComposer,
      $$TurnsTableAnnotationComposer,
      $$TurnsTableCreateCompanionBuilder,
      $$TurnsTableUpdateCompanionBuilder,
      (TurnRow, BaseReferences<_$AppDatabase, $TurnsTable, TurnRow>),
      TurnRow,
      PrefetchHooks Function()
    >;
typedef $$ThrowsTableCreateCompanionBuilder =
    ThrowsCompanion Function({
      Value<int> id,
      required int turnId,
      required DateTime timestamp,
      required int actualSegment,
      required int multiplier,
      required int resultingScoreDelta,
      required String gameId,
      required String source,
      Value<double?> landingRadius,
      Value<double?> landingAngleDegrees,
      Value<int?> landingCoordVersion,
      Value<int?> intendedTarget,
    });
typedef $$ThrowsTableUpdateCompanionBuilder =
    ThrowsCompanion Function({
      Value<int> id,
      Value<int> turnId,
      Value<DateTime> timestamp,
      Value<int> actualSegment,
      Value<int> multiplier,
      Value<int> resultingScoreDelta,
      Value<String> gameId,
      Value<String> source,
      Value<double?> landingRadius,
      Value<double?> landingAngleDegrees,
      Value<int?> landingCoordVersion,
      Value<int?> intendedTarget,
    });

class $$ThrowsTableFilterComposer
    extends Composer<_$AppDatabase, $ThrowsTable> {
  $$ThrowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get turnId => $composableBuilder(
    column: $table.turnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualSegment => $composableBuilder(
    column: $table.actualSegment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get multiplier => $composableBuilder(
    column: $table.multiplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resultingScoreDelta => $composableBuilder(
    column: $table.resultingScoreDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get landingRadius => $composableBuilder(
    column: $table.landingRadius,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get landingAngleDegrees => $composableBuilder(
    column: $table.landingAngleDegrees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get landingCoordVersion => $composableBuilder(
    column: $table.landingCoordVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intendedTarget => $composableBuilder(
    column: $table.intendedTarget,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThrowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ThrowsTable> {
  $$ThrowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get turnId => $composableBuilder(
    column: $table.turnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualSegment => $composableBuilder(
    column: $table.actualSegment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get multiplier => $composableBuilder(
    column: $table.multiplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resultingScoreDelta => $composableBuilder(
    column: $table.resultingScoreDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get landingRadius => $composableBuilder(
    column: $table.landingRadius,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get landingAngleDegrees => $composableBuilder(
    column: $table.landingAngleDegrees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get landingCoordVersion => $composableBuilder(
    column: $table.landingCoordVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intendedTarget => $composableBuilder(
    column: $table.intendedTarget,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThrowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThrowsTable> {
  $$ThrowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get turnId =>
      $composableBuilder(column: $table.turnId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get actualSegment => $composableBuilder(
    column: $table.actualSegment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get multiplier => $composableBuilder(
    column: $table.multiplier,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resultingScoreDelta => $composableBuilder(
    column: $table.resultingScoreDelta,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get landingRadius => $composableBuilder(
    column: $table.landingRadius,
    builder: (column) => column,
  );

  GeneratedColumn<double> get landingAngleDegrees => $composableBuilder(
    column: $table.landingAngleDegrees,
    builder: (column) => column,
  );

  GeneratedColumn<int> get landingCoordVersion => $composableBuilder(
    column: $table.landingCoordVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intendedTarget => $composableBuilder(
    column: $table.intendedTarget,
    builder: (column) => column,
  );
}

class $$ThrowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThrowsTable,
          ThrowRow,
          $$ThrowsTableFilterComposer,
          $$ThrowsTableOrderingComposer,
          $$ThrowsTableAnnotationComposer,
          $$ThrowsTableCreateCompanionBuilder,
          $$ThrowsTableUpdateCompanionBuilder,
          (ThrowRow, BaseReferences<_$AppDatabase, $ThrowsTable, ThrowRow>),
          ThrowRow,
          PrefetchHooks Function()
        > {
  $$ThrowsTableTableManager(_$AppDatabase db, $ThrowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThrowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThrowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThrowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> turnId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> actualSegment = const Value.absent(),
                Value<int> multiplier = const Value.absent(),
                Value<int> resultingScoreDelta = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double?> landingRadius = const Value.absent(),
                Value<double?> landingAngleDegrees = const Value.absent(),
                Value<int?> landingCoordVersion = const Value.absent(),
                Value<int?> intendedTarget = const Value.absent(),
              }) => ThrowsCompanion(
                id: id,
                turnId: turnId,
                timestamp: timestamp,
                actualSegment: actualSegment,
                multiplier: multiplier,
                resultingScoreDelta: resultingScoreDelta,
                gameId: gameId,
                source: source,
                landingRadius: landingRadius,
                landingAngleDegrees: landingAngleDegrees,
                landingCoordVersion: landingCoordVersion,
                intendedTarget: intendedTarget,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int turnId,
                required DateTime timestamp,
                required int actualSegment,
                required int multiplier,
                required int resultingScoreDelta,
                required String gameId,
                required String source,
                Value<double?> landingRadius = const Value.absent(),
                Value<double?> landingAngleDegrees = const Value.absent(),
                Value<int?> landingCoordVersion = const Value.absent(),
                Value<int?> intendedTarget = const Value.absent(),
              }) => ThrowsCompanion.insert(
                id: id,
                turnId: turnId,
                timestamp: timestamp,
                actualSegment: actualSegment,
                multiplier: multiplier,
                resultingScoreDelta: resultingScoreDelta,
                gameId: gameId,
                source: source,
                landingRadius: landingRadius,
                landingAngleDegrees: landingAngleDegrees,
                landingCoordVersion: landingCoordVersion,
                intendedTarget: intendedTarget,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThrowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThrowsTable,
      ThrowRow,
      $$ThrowsTableFilterComposer,
      $$ThrowsTableOrderingComposer,
      $$ThrowsTableAnnotationComposer,
      $$ThrowsTableCreateCompanionBuilder,
      $$ThrowsTableUpdateCompanionBuilder,
      (ThrowRow, BaseReferences<_$AppDatabase, $ThrowsTable, ThrowRow>),
      ThrowRow,
      PrefetchHooks Function()
    >;
typedef $$BotProfilesTableCreateCompanionBuilder =
    BotProfilesCompanion Function({
      required String id,
      required String name,
      required double sigmaMm,
      required double targetAverage,
      required double measuredCheckoutPercent,
      required bool isPreset,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BotProfilesTableUpdateCompanionBuilder =
    BotProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> sigmaMm,
      Value<double> targetAverage,
      Value<double> measuredCheckoutPercent,
      Value<bool> isPreset,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BotProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $BotProfilesTable> {
  $$BotProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sigmaMm => $composableBuilder(
    column: $table.sigmaMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetAverage => $composableBuilder(
    column: $table.targetAverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get measuredCheckoutPercent => $composableBuilder(
    column: $table.measuredCheckoutPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BotProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $BotProfilesTable> {
  $$BotProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sigmaMm => $composableBuilder(
    column: $table.sigmaMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetAverage => $composableBuilder(
    column: $table.targetAverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get measuredCheckoutPercent => $composableBuilder(
    column: $table.measuredCheckoutPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BotProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BotProfilesTable> {
  $$BotProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get sigmaMm =>
      $composableBuilder(column: $table.sigmaMm, builder: (column) => column);

  GeneratedColumn<double> get targetAverage => $composableBuilder(
    column: $table.targetAverage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get measuredCheckoutPercent => $composableBuilder(
    column: $table.measuredCheckoutPercent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPreset =>
      $composableBuilder(column: $table.isPreset, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BotProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BotProfilesTable,
          BotProfileRow,
          $$BotProfilesTableFilterComposer,
          $$BotProfilesTableOrderingComposer,
          $$BotProfilesTableAnnotationComposer,
          $$BotProfilesTableCreateCompanionBuilder,
          $$BotProfilesTableUpdateCompanionBuilder,
          (
            BotProfileRow,
            BaseReferences<_$AppDatabase, $BotProfilesTable, BotProfileRow>,
          ),
          BotProfileRow,
          PrefetchHooks Function()
        > {
  $$BotProfilesTableTableManager(_$AppDatabase db, $BotProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BotProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BotProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BotProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> sigmaMm = const Value.absent(),
                Value<double> targetAverage = const Value.absent(),
                Value<double> measuredCheckoutPercent = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BotProfilesCompanion(
                id: id,
                name: name,
                sigmaMm: sigmaMm,
                targetAverage: targetAverage,
                measuredCheckoutPercent: measuredCheckoutPercent,
                isPreset: isPreset,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double sigmaMm,
                required double targetAverage,
                required double measuredCheckoutPercent,
                required bool isPreset,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BotProfilesCompanion.insert(
                id: id,
                name: name,
                sigmaMm: sigmaMm,
                targetAverage: targetAverage,
                measuredCheckoutPercent: measuredCheckoutPercent,
                isPreset: isPreset,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BotProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BotProfilesTable,
      BotProfileRow,
      $$BotProfilesTableFilterComposer,
      $$BotProfilesTableOrderingComposer,
      $$BotProfilesTableAnnotationComposer,
      $$BotProfilesTableCreateCompanionBuilder,
      $$BotProfilesTableUpdateCompanionBuilder,
      (
        BotProfileRow,
        BaseReferences<_$AppDatabase, $BotProfilesTable, BotProfileRow>,
      ),
      BotProfileRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$MatchesTableTableManager get matches =>
      $$MatchesTableTableManager(_db, _db.matches);
  $$MatchPlayersTableTableManager get matchPlayers =>
      $$MatchPlayersTableTableManager(_db, _db.matchPlayers);
  $$TurnsTableTableManager get turns =>
      $$TurnsTableTableManager(_db, _db.turns);
  $$ThrowsTableTableManager get throws =>
      $$ThrowsTableTableManager(_db, _db.throws);
  $$BotProfilesTableTableManager get botProfiles =>
      $$BotProfilesTableTableManager(_db, _db.botProfiles);
}
