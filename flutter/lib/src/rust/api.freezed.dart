// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BackupConfig {
  String? get protectedBranch => throw _privateConstructorUsedError;

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupConfigCopyWith<BackupConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupConfigCopyWith<$Res> {
  factory $BackupConfigCopyWith(
          BackupConfig value, $Res Function(BackupConfig) then) =
      _$BackupConfigCopyWithImpl<$Res, BackupConfig>;
  @useResult
  $Res call({String? protectedBranch});
}

/// @nodoc
class _$BackupConfigCopyWithImpl<$Res, $Val extends BackupConfig>
    implements $BackupConfigCopyWith<$Res> {
  _$BackupConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? protectedBranch = freezed,
  }) {
    return _then(_value.copyWith(
      protectedBranch: freezed == protectedBranch
          ? _value.protectedBranch
          : protectedBranch // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BackupConfigImplCopyWith<$Res>
    implements $BackupConfigCopyWith<$Res> {
  factory _$$BackupConfigImplCopyWith(
          _$BackupConfigImpl value, $Res Function(_$BackupConfigImpl) then) =
      __$$BackupConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? protectedBranch});
}

/// @nodoc
class __$$BackupConfigImplCopyWithImpl<$Res>
    extends _$BackupConfigCopyWithImpl<$Res, _$BackupConfigImpl>
    implements _$$BackupConfigImplCopyWith<$Res> {
  __$$BackupConfigImplCopyWithImpl(
      _$BackupConfigImpl _value, $Res Function(_$BackupConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? protectedBranch = freezed,
  }) {
    return _then(_$BackupConfigImpl(
      protectedBranch: freezed == protectedBranch
          ? _value.protectedBranch
          : protectedBranch // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$BackupConfigImpl implements _BackupConfig {
  const _$BackupConfigImpl({this.protectedBranch});

  @override
  final String? protectedBranch;

  @override
  String toString() {
    return 'BackupConfig(protectedBranch: $protectedBranch)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupConfigImpl &&
            (identical(other.protectedBranch, protectedBranch) ||
                other.protectedBranch == protectedBranch));
  }

  @override
  int get hashCode => Object.hash(runtimeType, protectedBranch);

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupConfigImplCopyWith<_$BackupConfigImpl> get copyWith =>
      __$$BackupConfigImplCopyWithImpl<_$BackupConfigImpl>(this, _$identity);
}

abstract class _BackupConfig implements BackupConfig {
  const factory _BackupConfig({final String? protectedBranch}) =
      _$BackupConfigImpl;

  @override
  String? get protectedBranch;

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupConfigImplCopyWith<_$BackupConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Credentials {
  String get salt => throw _privateConstructorUsedError;
  String get pincodeHash => throw _privateConstructorUsedError;

  /// Create a copy of Credentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CredentialsCopyWith<Credentials> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialsCopyWith<$Res> {
  factory $CredentialsCopyWith(
          Credentials value, $Res Function(Credentials) then) =
      _$CredentialsCopyWithImpl<$Res, Credentials>;
  @useResult
  $Res call({String salt, String pincodeHash});
}

/// @nodoc
class _$CredentialsCopyWithImpl<$Res, $Val extends Credentials>
    implements $CredentialsCopyWith<$Res> {
  _$CredentialsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Credentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? salt = null,
    Object? pincodeHash = null,
  }) {
    return _then(_value.copyWith(
      salt: null == salt
          ? _value.salt
          : salt // ignore: cast_nullable_to_non_nullable
              as String,
      pincodeHash: null == pincodeHash
          ? _value.pincodeHash
          : pincodeHash // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CredentialsImplCopyWith<$Res>
    implements $CredentialsCopyWith<$Res> {
  factory _$$CredentialsImplCopyWith(
          _$CredentialsImpl value, $Res Function(_$CredentialsImpl) then) =
      __$$CredentialsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String salt, String pincodeHash});
}

/// @nodoc
class __$$CredentialsImplCopyWithImpl<$Res>
    extends _$CredentialsCopyWithImpl<$Res, _$CredentialsImpl>
    implements _$$CredentialsImplCopyWith<$Res> {
  __$$CredentialsImplCopyWithImpl(
      _$CredentialsImpl _value, $Res Function(_$CredentialsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Credentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? salt = null,
    Object? pincodeHash = null,
  }) {
    return _then(_$CredentialsImpl(
      salt: null == salt
          ? _value.salt
          : salt // ignore: cast_nullable_to_non_nullable
              as String,
      pincodeHash: null == pincodeHash
          ? _value.pincodeHash
          : pincodeHash // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CredentialsImpl extends _Credentials {
  const _$CredentialsImpl({required this.salt, required this.pincodeHash})
      : super._();

  @override
  final String salt;
  @override
  final String pincodeHash;

  @override
  String toString() {
    return 'Credentials(salt: $salt, pincodeHash: $pincodeHash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialsImpl &&
            (identical(other.salt, salt) || other.salt == salt) &&
            (identical(other.pincodeHash, pincodeHash) ||
                other.pincodeHash == pincodeHash));
  }

  @override
  int get hashCode => Object.hash(runtimeType, salt, pincodeHash);

  /// Create a copy of Credentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialsImplCopyWith<_$CredentialsImpl> get copyWith =>
      __$$CredentialsImplCopyWithImpl<_$CredentialsImpl>(this, _$identity);
}

abstract class _Credentials extends Credentials {
  const factory _Credentials(
      {required final String salt,
      required final String pincodeHash}) = _$CredentialsImpl;
  const _Credentials._() : super._();

  @override
  String get salt;
  @override
  String get pincodeHash;

  /// Create a copy of Credentials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CredentialsImplCopyWith<_$CredentialsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Interaction {
  String get id => throw _privateConstructorUsedError;
  InteractionKind get kind => throw _privateConstructorUsedError;
  String get from => throw _privateConstructorUsedError;
  List<String> get withMembers => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;
  bool get shared => throw _privateConstructorUsedError;

  /// Create a copy of Interaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InteractionCopyWith<Interaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InteractionCopyWith<$Res> {
  factory $InteractionCopyWith(
          Interaction value, $Res Function(Interaction) then) =
      _$InteractionCopyWithImpl<$Res, Interaction>;
  @useResult
  $Res call(
      {String id,
      InteractionKind kind,
      String from,
      List<String> withMembers,
      String note,
      String timestamp,
      bool shared});
}

/// @nodoc
class _$InteractionCopyWithImpl<$Res, $Val extends Interaction>
    implements $InteractionCopyWith<$Res> {
  _$InteractionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Interaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? from = null,
    Object? withMembers = null,
    Object? note = null,
    Object? timestamp = null,
    Object? shared = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as InteractionKind,
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String,
      withMembers: null == withMembers
          ? _value.withMembers
          : withMembers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      shared: null == shared
          ? _value.shared
          : shared // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InteractionImplCopyWith<$Res>
    implements $InteractionCopyWith<$Res> {
  factory _$$InteractionImplCopyWith(
          _$InteractionImpl value, $Res Function(_$InteractionImpl) then) =
      __$$InteractionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      InteractionKind kind,
      String from,
      List<String> withMembers,
      String note,
      String timestamp,
      bool shared});
}

/// @nodoc
class __$$InteractionImplCopyWithImpl<$Res>
    extends _$InteractionCopyWithImpl<$Res, _$InteractionImpl>
    implements _$$InteractionImplCopyWith<$Res> {
  __$$InteractionImplCopyWithImpl(
      _$InteractionImpl _value, $Res Function(_$InteractionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Interaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? from = null,
    Object? withMembers = null,
    Object? note = null,
    Object? timestamp = null,
    Object? shared = null,
  }) {
    return _then(_$InteractionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as InteractionKind,
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String,
      withMembers: null == withMembers
          ? _value._withMembers
          : withMembers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      shared: null == shared
          ? _value.shared
          : shared // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$InteractionImpl extends _Interaction {
  const _$InteractionImpl(
      {required this.id,
      required this.kind,
      required this.from,
      required final List<String> withMembers,
      required this.note,
      required this.timestamp,
      required this.shared})
      : _withMembers = withMembers,
        super._();

  @override
  final String id;
  @override
  final InteractionKind kind;
  @override
  final String from;
  final List<String> _withMembers;
  @override
  List<String> get withMembers {
    if (_withMembers is EqualUnmodifiableListView) return _withMembers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_withMembers);
  }

  @override
  final String note;
  @override
  final String timestamp;
  @override
  final bool shared;

  @override
  String toString() {
    return 'Interaction(id: $id, kind: $kind, from: $from, withMembers: $withMembers, note: $note, timestamp: $timestamp, shared: $shared)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InteractionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.from, from) || other.from == from) &&
            const DeepCollectionEquality()
                .equals(other._withMembers, _withMembers) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.shared, shared) || other.shared == shared));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      kind,
      from,
      const DeepCollectionEquality().hash(_withMembers),
      note,
      timestamp,
      shared);

  /// Create a copy of Interaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InteractionImplCopyWith<_$InteractionImpl> get copyWith =>
      __$$InteractionImplCopyWithImpl<_$InteractionImpl>(this, _$identity);
}

abstract class _Interaction extends Interaction {
  const factory _Interaction(
      {required final String id,
      required final InteractionKind kind,
      required final String from,
      required final List<String> withMembers,
      required final String note,
      required final String timestamp,
      required final bool shared}) = _$InteractionImpl;
  const _Interaction._() : super._();

  @override
  String get id;
  @override
  InteractionKind get kind;
  @override
  String get from;
  @override
  List<String> get withMembers;
  @override
  String get note;
  @override
  String get timestamp;
  @override
  bool get shared;

  /// Create a copy of Interaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InteractionImplCopyWith<_$InteractionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$KeyResult {
  String get description => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Create a copy of KeyResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeyResultCopyWith<KeyResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeyResultCopyWith<$Res> {
  factory $KeyResultCopyWith(KeyResult value, $Res Function(KeyResult) then) =
      _$KeyResultCopyWithImpl<$Res, KeyResult>;
  @useResult
  $Res call({String description, double progress, String? notes});
}

/// @nodoc
class _$KeyResultCopyWithImpl<$Res, $Val extends KeyResult>
    implements $KeyResultCopyWith<$Res> {
  _$KeyResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KeyResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? progress = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KeyResultImplCopyWith<$Res>
    implements $KeyResultCopyWith<$Res> {
  factory _$$KeyResultImplCopyWith(
          _$KeyResultImpl value, $Res Function(_$KeyResultImpl) then) =
      __$$KeyResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String description, double progress, String? notes});
}

/// @nodoc
class __$$KeyResultImplCopyWithImpl<$Res>
    extends _$KeyResultCopyWithImpl<$Res, _$KeyResultImpl>
    implements _$$KeyResultImplCopyWith<$Res> {
  __$$KeyResultImplCopyWithImpl(
      _$KeyResultImpl _value, $Res Function(_$KeyResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of KeyResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? progress = null,
    Object? notes = freezed,
  }) {
    return _then(_$KeyResultImpl(
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$KeyResultImpl extends _KeyResult {
  const _$KeyResultImpl(
      {required this.description, required this.progress, this.notes})
      : super._();

  @override
  final String description;
  @override
  final double progress;
  @override
  final String? notes;

  @override
  String toString() {
    return 'KeyResult(description: $description, progress: $progress, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeyResultImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, description, progress, notes);

  /// Create a copy of KeyResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeyResultImplCopyWith<_$KeyResultImpl> get copyWith =>
      __$$KeyResultImplCopyWithImpl<_$KeyResultImpl>(this, _$identity);
}

abstract class _KeyResult extends KeyResult {
  const factory _KeyResult(
      {required final String description,
      required final double progress,
      final String? notes}) = _$KeyResultImpl;
  const _KeyResult._() : super._();

  @override
  String get description;
  @override
  double get progress;
  @override
  String? get notes;

  /// Create a copy of KeyResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeyResultImplCopyWith<_$KeyResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LintingConfig {
  bool get enabled => throw _privateConstructorUsedError;
  String? get targetBranch => throw _privateConstructorUsedError;

  /// Create a copy of LintingConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LintingConfigCopyWith<LintingConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LintingConfigCopyWith<$Res> {
  factory $LintingConfigCopyWith(
          LintingConfig value, $Res Function(LintingConfig) then) =
      _$LintingConfigCopyWithImpl<$Res, LintingConfig>;
  @useResult
  $Res call({bool enabled, String? targetBranch});
}

/// @nodoc
class _$LintingConfigCopyWithImpl<$Res, $Val extends LintingConfig>
    implements $LintingConfigCopyWith<$Res> {
  _$LintingConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LintingConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? targetBranch = freezed,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      targetBranch: freezed == targetBranch
          ? _value.targetBranch
          : targetBranch // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LintingConfigImplCopyWith<$Res>
    implements $LintingConfigCopyWith<$Res> {
  factory _$$LintingConfigImplCopyWith(
          _$LintingConfigImpl value, $Res Function(_$LintingConfigImpl) then) =
      __$$LintingConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool enabled, String? targetBranch});
}

/// @nodoc
class __$$LintingConfigImplCopyWithImpl<$Res>
    extends _$LintingConfigCopyWithImpl<$Res, _$LintingConfigImpl>
    implements _$$LintingConfigImplCopyWith<$Res> {
  __$$LintingConfigImplCopyWithImpl(
      _$LintingConfigImpl _value, $Res Function(_$LintingConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of LintingConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? targetBranch = freezed,
  }) {
    return _then(_$LintingConfigImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      targetBranch: freezed == targetBranch
          ? _value.targetBranch
          : targetBranch // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LintingConfigImpl implements _LintingConfig {
  const _$LintingConfigImpl({required this.enabled, this.targetBranch});

  @override
  final bool enabled;
  @override
  final String? targetBranch;

  @override
  String toString() {
    return 'LintingConfig(enabled: $enabled, targetBranch: $targetBranch)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LintingConfigImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.targetBranch, targetBranch) ||
                other.targetBranch == targetBranch));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enabled, targetBranch);

  /// Create a copy of LintingConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LintingConfigImplCopyWith<_$LintingConfigImpl> get copyWith =>
      __$$LintingConfigImplCopyWithImpl<_$LintingConfigImpl>(this, _$identity);
}

abstract class _LintingConfig implements LintingConfig {
  const factory _LintingConfig(
      {required final bool enabled,
      final String? targetBranch}) = _$LintingConfigImpl;

  @override
  bool get enabled;
  @override
  String? get targetBranch;

  /// Create a copy of LintingConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LintingConfigImplCopyWith<_$LintingConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Member {
  String get email => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberCopyWith<Member> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberCopyWith<$Res> {
  factory $MemberCopyWith(Member value, $Res Function(Member) then) =
      _$MemberCopyWithImpl<$Res, Member>;
  @useResult
  $Res call({String email, String? name, String? bio, String? timezone});
}

/// @nodoc
class _$MemberCopyWithImpl<$Res, $Val extends Member>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? name = freezed,
    Object? bio = freezed,
    Object? timezone = freezed,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MemberImplCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$$MemberImplCopyWith(
          _$MemberImpl value, $Res Function(_$MemberImpl) then) =
      __$$MemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String? name, String? bio, String? timezone});
}

/// @nodoc
class __$$MemberImplCopyWithImpl<$Res>
    extends _$MemberCopyWithImpl<$Res, _$MemberImpl>
    implements _$$MemberImplCopyWith<$Res> {
  __$$MemberImplCopyWithImpl(
      _$MemberImpl _value, $Res Function(_$MemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? name = freezed,
    Object? bio = freezed,
    Object? timezone = freezed,
  }) {
    return _then(_$MemberImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$MemberImpl extends _Member {
  const _$MemberImpl({required this.email, this.name, this.bio, this.timezone})
      : super._();

  @override
  final String email;
  @override
  final String? name;
  @override
  final String? bio;
  @override
  final String? timezone;

  @override
  String toString() {
    return 'Member(email: $email, name: $name, bio: $bio, timezone: $timezone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, name, bio, timezone);

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberImplCopyWith<_$MemberImpl> get copyWith =>
      __$$MemberImplCopyWithImpl<_$MemberImpl>(this, _$identity);
}

abstract class _Member extends Member {
  const factory _Member(
      {required final String email,
      final String? name,
      final String? bio,
      final String? timezone}) = _$MemberImpl;
  const _Member._() : super._();

  @override
  String get email;
  @override
  String? get name;
  @override
  String? get bio;
  @override
  String? get timezone;

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberImplCopyWith<_$MemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MemberCredentials {
  String get email => throw _privateConstructorUsedError;
  Credentials get credentials => throw _privateConstructorUsedError;

  /// Create a copy of MemberCredentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberCredentialsCopyWith<MemberCredentials> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberCredentialsCopyWith<$Res> {
  factory $MemberCredentialsCopyWith(
          MemberCredentials value, $Res Function(MemberCredentials) then) =
      _$MemberCredentialsCopyWithImpl<$Res, MemberCredentials>;
  @useResult
  $Res call({String email, Credentials credentials});

  $CredentialsCopyWith<$Res> get credentials;
}

/// @nodoc
class _$MemberCredentialsCopyWithImpl<$Res, $Val extends MemberCredentials>
    implements $MemberCredentialsCopyWith<$Res> {
  _$MemberCredentialsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberCredentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? credentials = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      credentials: null == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as Credentials,
    ) as $Val);
  }

  /// Create a copy of MemberCredentials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CredentialsCopyWith<$Res> get credentials {
    return $CredentialsCopyWith<$Res>(_value.credentials, (value) {
      return _then(_value.copyWith(credentials: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MemberCredentialsImplCopyWith<$Res>
    implements $MemberCredentialsCopyWith<$Res> {
  factory _$$MemberCredentialsImplCopyWith(_$MemberCredentialsImpl value,
          $Res Function(_$MemberCredentialsImpl) then) =
      __$$MemberCredentialsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, Credentials credentials});

  @override
  $CredentialsCopyWith<$Res> get credentials;
}

/// @nodoc
class __$$MemberCredentialsImplCopyWithImpl<$Res>
    extends _$MemberCredentialsCopyWithImpl<$Res, _$MemberCredentialsImpl>
    implements _$$MemberCredentialsImplCopyWith<$Res> {
  __$$MemberCredentialsImplCopyWithImpl(_$MemberCredentialsImpl _value,
      $Res Function(_$MemberCredentialsImpl) _then)
      : super(_value, _then);

  /// Create a copy of MemberCredentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? credentials = null,
  }) {
    return _then(_$MemberCredentialsImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      credentials: null == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as Credentials,
    ));
  }
}

/// @nodoc

class _$MemberCredentialsImpl extends _MemberCredentials {
  const _$MemberCredentialsImpl(
      {required this.email, required this.credentials})
      : super._();

  @override
  final String email;
  @override
  final Credentials credentials;

  @override
  String toString() {
    return 'MemberCredentials(email: $email, credentials: $credentials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberCredentialsImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.credentials, credentials) ||
                other.credentials == credentials));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, credentials);

  /// Create a copy of MemberCredentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberCredentialsImplCopyWith<_$MemberCredentialsImpl> get copyWith =>
      __$$MemberCredentialsImplCopyWithImpl<_$MemberCredentialsImpl>(
          this, _$identity);
}

abstract class _MemberCredentials extends MemberCredentials {
  const factory _MemberCredentials(
      {required final String email,
      required final Credentials credentials}) = _$MemberCredentialsImpl;
  const _MemberCredentials._() : super._();

  @override
  String get email;
  @override
  Credentials get credentials;

  /// Create a copy of MemberCredentials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberCredentialsImplCopyWith<_$MemberCredentialsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Objective {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<KeyResult> get keyResults => throw _privateConstructorUsedError;
  OkrVisibility get visibility => throw _privateConstructorUsedError;
  String? get owner => throw _privateConstructorUsedError;
  String? get quarter => throw _privateConstructorUsedError;

  /// Create a copy of Objective
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ObjectiveCopyWith<Objective> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ObjectiveCopyWith<$Res> {
  factory $ObjectiveCopyWith(Objective value, $Res Function(Objective) then) =
      _$ObjectiveCopyWithImpl<$Res, Objective>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      List<KeyResult> keyResults,
      OkrVisibility visibility,
      String? owner,
      String? quarter});
}

/// @nodoc
class _$ObjectiveCopyWithImpl<$Res, $Val extends Objective>
    implements $ObjectiveCopyWith<$Res> {
  _$ObjectiveCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Objective
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? keyResults = null,
    Object? visibility = null,
    Object? owner = freezed,
    Object? quarter = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      keyResults: null == keyResults
          ? _value.keyResults
          : keyResults // ignore: cast_nullable_to_non_nullable
              as List<KeyResult>,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as OkrVisibility,
      owner: freezed == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as String?,
      quarter: freezed == quarter
          ? _value.quarter
          : quarter // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ObjectiveImplCopyWith<$Res>
    implements $ObjectiveCopyWith<$Res> {
  factory _$$ObjectiveImplCopyWith(
          _$ObjectiveImpl value, $Res Function(_$ObjectiveImpl) then) =
      __$$ObjectiveImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      List<KeyResult> keyResults,
      OkrVisibility visibility,
      String? owner,
      String? quarter});
}

/// @nodoc
class __$$ObjectiveImplCopyWithImpl<$Res>
    extends _$ObjectiveCopyWithImpl<$Res, _$ObjectiveImpl>
    implements _$$ObjectiveImplCopyWith<$Res> {
  __$$ObjectiveImplCopyWithImpl(
      _$ObjectiveImpl _value, $Res Function(_$ObjectiveImpl) _then)
      : super(_value, _then);

  /// Create a copy of Objective
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? keyResults = null,
    Object? visibility = null,
    Object? owner = freezed,
    Object? quarter = freezed,
  }) {
    return _then(_$ObjectiveImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      keyResults: null == keyResults
          ? _value._keyResults
          : keyResults // ignore: cast_nullable_to_non_nullable
              as List<KeyResult>,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as OkrVisibility,
      owner: freezed == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as String?,
      quarter: freezed == quarter
          ? _value.quarter
          : quarter // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ObjectiveImpl extends _Objective {
  const _$ObjectiveImpl(
      {required this.id,
      required this.title,
      this.description,
      required final List<KeyResult> keyResults,
      required this.visibility,
      this.owner,
      this.quarter})
      : _keyResults = keyResults,
        super._();

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  final List<KeyResult> _keyResults;
  @override
  List<KeyResult> get keyResults {
    if (_keyResults is EqualUnmodifiableListView) return _keyResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyResults);
  }

  @override
  final OkrVisibility visibility;
  @override
  final String? owner;
  @override
  final String? quarter;

  @override
  String toString() {
    return 'Objective(id: $id, title: $title, description: $description, keyResults: $keyResults, visibility: $visibility, owner: $owner, quarter: $quarter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ObjectiveImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._keyResults, _keyResults) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.owner, owner) || other.owner == owner) &&
            (identical(other.quarter, quarter) || other.quarter == quarter));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      const DeepCollectionEquality().hash(_keyResults),
      visibility,
      owner,
      quarter);

  /// Create a copy of Objective
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ObjectiveImplCopyWith<_$ObjectiveImpl> get copyWith =>
      __$$ObjectiveImplCopyWithImpl<_$ObjectiveImpl>(this, _$identity);
}

abstract class _Objective extends Objective {
  const factory _Objective(
      {required final String id,
      required final String title,
      final String? description,
      required final List<KeyResult> keyResults,
      required final OkrVisibility visibility,
      final String? owner,
      final String? quarter}) = _$ObjectiveImpl;
  const _Objective._() : super._();

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  List<KeyResult> get keyResults;
  @override
  OkrVisibility get visibility;
  @override
  String? get owner;
  @override
  String? get quarter;

  /// Create a copy of Objective
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ObjectiveImplCopyWith<_$ObjectiveImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PublishConfig {
  String? get manifesto => throw _privateConstructorUsedError;
  String? get vision => throw _privateConstructorUsedError;
  String? get okrs => throw _privateConstructorUsedError;

  /// Create a copy of PublishConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublishConfigCopyWith<PublishConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublishConfigCopyWith<$Res> {
  factory $PublishConfigCopyWith(
          PublishConfig value, $Res Function(PublishConfig) then) =
      _$PublishConfigCopyWithImpl<$Res, PublishConfig>;
  @useResult
  $Res call({String? manifesto, String? vision, String? okrs});
}

/// @nodoc
class _$PublishConfigCopyWithImpl<$Res, $Val extends PublishConfig>
    implements $PublishConfigCopyWith<$Res> {
  _$PublishConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublishConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? manifesto = freezed,
    Object? vision = freezed,
    Object? okrs = freezed,
  }) {
    return _then(_value.copyWith(
      manifesto: freezed == manifesto
          ? _value.manifesto
          : manifesto // ignore: cast_nullable_to_non_nullable
              as String?,
      vision: freezed == vision
          ? _value.vision
          : vision // ignore: cast_nullable_to_non_nullable
              as String?,
      okrs: freezed == okrs
          ? _value.okrs
          : okrs // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PublishConfigImplCopyWith<$Res>
    implements $PublishConfigCopyWith<$Res> {
  factory _$$PublishConfigImplCopyWith(
          _$PublishConfigImpl value, $Res Function(_$PublishConfigImpl) then) =
      __$$PublishConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? manifesto, String? vision, String? okrs});
}

/// @nodoc
class __$$PublishConfigImplCopyWithImpl<$Res>
    extends _$PublishConfigCopyWithImpl<$Res, _$PublishConfigImpl>
    implements _$$PublishConfigImplCopyWith<$Res> {
  __$$PublishConfigImplCopyWithImpl(
      _$PublishConfigImpl _value, $Res Function(_$PublishConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublishConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? manifesto = freezed,
    Object? vision = freezed,
    Object? okrs = freezed,
  }) {
    return _then(_$PublishConfigImpl(
      manifesto: freezed == manifesto
          ? _value.manifesto
          : manifesto // ignore: cast_nullable_to_non_nullable
              as String?,
      vision: freezed == vision
          ? _value.vision
          : vision // ignore: cast_nullable_to_non_nullable
              as String?,
      okrs: freezed == okrs
          ? _value.okrs
          : okrs // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PublishConfigImpl implements _PublishConfig {
  const _$PublishConfigImpl({this.manifesto, this.vision, this.okrs});

  @override
  final String? manifesto;
  @override
  final String? vision;
  @override
  final String? okrs;

  @override
  String toString() {
    return 'PublishConfig(manifesto: $manifesto, vision: $vision, okrs: $okrs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublishConfigImpl &&
            (identical(other.manifesto, manifesto) ||
                other.manifesto == manifesto) &&
            (identical(other.vision, vision) || other.vision == vision) &&
            (identical(other.okrs, okrs) || other.okrs == okrs));
  }

  @override
  int get hashCode => Object.hash(runtimeType, manifesto, vision, okrs);

  /// Create a copy of PublishConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublishConfigImplCopyWith<_$PublishConfigImpl> get copyWith =>
      __$$PublishConfigImplCopyWithImpl<_$PublishConfigImpl>(this, _$identity);
}

abstract class _PublishConfig implements PublishConfig {
  const factory _PublishConfig(
      {final String? manifesto,
      final String? vision,
      final String? okrs}) = _$PublishConfigImpl;

  @override
  String? get manifesto;
  @override
  String? get vision;
  @override
  String? get okrs;

  /// Create a copy of PublishConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublishConfigImplCopyWith<_$PublishConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Team {
  String get name => throw _privateConstructorUsedError;
  String? get manifesto => throw _privateConstructorUsedError;
  String? get vision => throw _privateConstructorUsedError;
  List<String> get leaders => throw _privateConstructorUsedError;
  List<String> get members => throw _privateConstructorUsedError;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamCopyWith<Team> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamCopyWith<$Res> {
  factory $TeamCopyWith(Team value, $Res Function(Team) then) =
      _$TeamCopyWithImpl<$Res, Team>;
  @useResult
  $Res call(
      {String name,
      String? manifesto,
      String? vision,
      List<String> leaders,
      List<String> members});
}

/// @nodoc
class _$TeamCopyWithImpl<$Res, $Val extends Team>
    implements $TeamCopyWith<$Res> {
  _$TeamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? manifesto = freezed,
    Object? vision = freezed,
    Object? leaders = null,
    Object? members = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      manifesto: freezed == manifesto
          ? _value.manifesto
          : manifesto // ignore: cast_nullable_to_non_nullable
              as String?,
      vision: freezed == vision
          ? _value.vision
          : vision // ignore: cast_nullable_to_non_nullable
              as String?,
      leaders: null == leaders
          ? _value.leaders
          : leaders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      members: null == members
          ? _value.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TeamImplCopyWith<$Res> implements $TeamCopyWith<$Res> {
  factory _$$TeamImplCopyWith(
          _$TeamImpl value, $Res Function(_$TeamImpl) then) =
      __$$TeamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? manifesto,
      String? vision,
      List<String> leaders,
      List<String> members});
}

/// @nodoc
class __$$TeamImplCopyWithImpl<$Res>
    extends _$TeamCopyWithImpl<$Res, _$TeamImpl>
    implements _$$TeamImplCopyWith<$Res> {
  __$$TeamImplCopyWithImpl(_$TeamImpl _value, $Res Function(_$TeamImpl) _then)
      : super(_value, _then);

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? manifesto = freezed,
    Object? vision = freezed,
    Object? leaders = null,
    Object? members = null,
  }) {
    return _then(_$TeamImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      manifesto: freezed == manifesto
          ? _value.manifesto
          : manifesto // ignore: cast_nullable_to_non_nullable
              as String?,
      vision: freezed == vision
          ? _value.vision
          : vision // ignore: cast_nullable_to_non_nullable
              as String?,
      leaders: null == leaders
          ? _value._leaders
          : leaders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      members: null == members
          ? _value._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$TeamImpl extends _Team {
  const _$TeamImpl(
      {required this.name,
      this.manifesto,
      this.vision,
      required final List<String> leaders,
      required final List<String> members})
      : _leaders = leaders,
        _members = members,
        super._();

  @override
  final String name;
  @override
  final String? manifesto;
  @override
  final String? vision;
  final List<String> _leaders;
  @override
  List<String> get leaders {
    if (_leaders is EqualUnmodifiableListView) return _leaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_leaders);
  }

  final List<String> _members;
  @override
  List<String> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  @override
  String toString() {
    return 'Team(name: $name, manifesto: $manifesto, vision: $vision, leaders: $leaders, members: $members)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.manifesto, manifesto) ||
                other.manifesto == manifesto) &&
            (identical(other.vision, vision) || other.vision == vision) &&
            const DeepCollectionEquality().equals(other._leaders, _leaders) &&
            const DeepCollectionEquality().equals(other._members, _members));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      manifesto,
      vision,
      const DeepCollectionEquality().hash(_leaders),
      const DeepCollectionEquality().hash(_members));

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamImplCopyWith<_$TeamImpl> get copyWith =>
      __$$TeamImplCopyWithImpl<_$TeamImpl>(this, _$identity);
}

abstract class _Team extends Team {
  const factory _Team(
      {required final String name,
      final String? manifesto,
      final String? vision,
      required final List<String> leaders,
      required final List<String> members}) = _$TeamImpl;
  const _Team._() : super._();

  @override
  String get name;
  @override
  String? get manifesto;
  @override
  String? get vision;
  @override
  List<String> get leaders;
  @override
  List<String> get members;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamImplCopyWith<_$TeamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TeamConfig {
  PublishConfig? get publish => throw _privateConstructorUsedError;
  WebhookConfig? get webhooks => throw _privateConstructorUsedError;
  LintingConfig? get linting => throw _privateConstructorUsedError;
  BackupConfig? get backup => throw _privateConstructorUsedError;

  /// Create a copy of TeamConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamConfigCopyWith<TeamConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamConfigCopyWith<$Res> {
  factory $TeamConfigCopyWith(
          TeamConfig value, $Res Function(TeamConfig) then) =
      _$TeamConfigCopyWithImpl<$Res, TeamConfig>;
  @useResult
  $Res call(
      {PublishConfig? publish,
      WebhookConfig? webhooks,
      LintingConfig? linting,
      BackupConfig? backup});

  $PublishConfigCopyWith<$Res>? get publish;
  $WebhookConfigCopyWith<$Res>? get webhooks;
  $LintingConfigCopyWith<$Res>? get linting;
  $BackupConfigCopyWith<$Res>? get backup;
}

/// @nodoc
class _$TeamConfigCopyWithImpl<$Res, $Val extends TeamConfig>
    implements $TeamConfigCopyWith<$Res> {
  _$TeamConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publish = freezed,
    Object? webhooks = freezed,
    Object? linting = freezed,
    Object? backup = freezed,
  }) {
    return _then(_value.copyWith(
      publish: freezed == publish
          ? _value.publish
          : publish // ignore: cast_nullable_to_non_nullable
              as PublishConfig?,
      webhooks: freezed == webhooks
          ? _value.webhooks
          : webhooks // ignore: cast_nullable_to_non_nullable
              as WebhookConfig?,
      linting: freezed == linting
          ? _value.linting
          : linting // ignore: cast_nullable_to_non_nullable
              as LintingConfig?,
      backup: freezed == backup
          ? _value.backup
          : backup // ignore: cast_nullable_to_non_nullable
              as BackupConfig?,
    ) as $Val);
  }

  /// Create a copy of TeamConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PublishConfigCopyWith<$Res>? get publish {
    if (_value.publish == null) {
      return null;
    }

    return $PublishConfigCopyWith<$Res>(_value.publish!, (value) {
      return _then(_value.copyWith(publish: value) as $Val);
    });
  }

  /// Create a copy of TeamConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WebhookConfigCopyWith<$Res>? get webhooks {
    if (_value.webhooks == null) {
      return null;
    }

    return $WebhookConfigCopyWith<$Res>(_value.webhooks!, (value) {
      return _then(_value.copyWith(webhooks: value) as $Val);
    });
  }

  /// Create a copy of TeamConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LintingConfigCopyWith<$Res>? get linting {
    if (_value.linting == null) {
      return null;
    }

    return $LintingConfigCopyWith<$Res>(_value.linting!, (value) {
      return _then(_value.copyWith(linting: value) as $Val);
    });
  }

  /// Create a copy of TeamConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BackupConfigCopyWith<$Res>? get backup {
    if (_value.backup == null) {
      return null;
    }

    return $BackupConfigCopyWith<$Res>(_value.backup!, (value) {
      return _then(_value.copyWith(backup: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeamConfigImplCopyWith<$Res>
    implements $TeamConfigCopyWith<$Res> {
  factory _$$TeamConfigImplCopyWith(
          _$TeamConfigImpl value, $Res Function(_$TeamConfigImpl) then) =
      __$$TeamConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PublishConfig? publish,
      WebhookConfig? webhooks,
      LintingConfig? linting,
      BackupConfig? backup});

  @override
  $PublishConfigCopyWith<$Res>? get publish;
  @override
  $WebhookConfigCopyWith<$Res>? get webhooks;
  @override
  $LintingConfigCopyWith<$Res>? get linting;
  @override
  $BackupConfigCopyWith<$Res>? get backup;
}

/// @nodoc
class __$$TeamConfigImplCopyWithImpl<$Res>
    extends _$TeamConfigCopyWithImpl<$Res, _$TeamConfigImpl>
    implements _$$TeamConfigImplCopyWith<$Res> {
  __$$TeamConfigImplCopyWithImpl(
      _$TeamConfigImpl _value, $Res Function(_$TeamConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of TeamConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publish = freezed,
    Object? webhooks = freezed,
    Object? linting = freezed,
    Object? backup = freezed,
  }) {
    return _then(_$TeamConfigImpl(
      publish: freezed == publish
          ? _value.publish
          : publish // ignore: cast_nullable_to_non_nullable
              as PublishConfig?,
      webhooks: freezed == webhooks
          ? _value.webhooks
          : webhooks // ignore: cast_nullable_to_non_nullable
              as WebhookConfig?,
      linting: freezed == linting
          ? _value.linting
          : linting // ignore: cast_nullable_to_non_nullable
              as LintingConfig?,
      backup: freezed == backup
          ? _value.backup
          : backup // ignore: cast_nullable_to_non_nullable
              as BackupConfig?,
    ));
  }
}

/// @nodoc

class _$TeamConfigImpl extends _TeamConfig {
  const _$TeamConfigImpl(
      {this.publish, this.webhooks, this.linting, this.backup})
      : super._();

  @override
  final PublishConfig? publish;
  @override
  final WebhookConfig? webhooks;
  @override
  final LintingConfig? linting;
  @override
  final BackupConfig? backup;

  @override
  String toString() {
    return 'TeamConfig(publish: $publish, webhooks: $webhooks, linting: $linting, backup: $backup)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamConfigImpl &&
            (identical(other.publish, publish) || other.publish == publish) &&
            (identical(other.webhooks, webhooks) ||
                other.webhooks == webhooks) &&
            (identical(other.linting, linting) || other.linting == linting) &&
            (identical(other.backup, backup) || other.backup == backup));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, publish, webhooks, linting, backup);

  /// Create a copy of TeamConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamConfigImplCopyWith<_$TeamConfigImpl> get copyWith =>
      __$$TeamConfigImplCopyWithImpl<_$TeamConfigImpl>(this, _$identity);
}

abstract class _TeamConfig extends TeamConfig {
  const factory _TeamConfig(
      {final PublishConfig? publish,
      final WebhookConfig? webhooks,
      final LintingConfig? linting,
      final BackupConfig? backup}) = _$TeamConfigImpl;
  const _TeamConfig._() : super._();

  @override
  PublishConfig? get publish;
  @override
  WebhookConfig? get webhooks;
  @override
  LintingConfig? get linting;
  @override
  BackupConfig? get backup;

  /// Create a copy of TeamConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamConfigImplCopyWith<_$TeamConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WebhookConfig {
  String? get discord => throw _privateConstructorUsedError;
  String? get slack => throw _privateConstructorUsedError;
  String? get signal => throw _privateConstructorUsedError;

  /// Create a copy of WebhookConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebhookConfigCopyWith<WebhookConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebhookConfigCopyWith<$Res> {
  factory $WebhookConfigCopyWith(
          WebhookConfig value, $Res Function(WebhookConfig) then) =
      _$WebhookConfigCopyWithImpl<$Res, WebhookConfig>;
  @useResult
  $Res call({String? discord, String? slack, String? signal});
}

/// @nodoc
class _$WebhookConfigCopyWithImpl<$Res, $Val extends WebhookConfig>
    implements $WebhookConfigCopyWith<$Res> {
  _$WebhookConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebhookConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discord = freezed,
    Object? slack = freezed,
    Object? signal = freezed,
  }) {
    return _then(_value.copyWith(
      discord: freezed == discord
          ? _value.discord
          : discord // ignore: cast_nullable_to_non_nullable
              as String?,
      slack: freezed == slack
          ? _value.slack
          : slack // ignore: cast_nullable_to_non_nullable
              as String?,
      signal: freezed == signal
          ? _value.signal
          : signal // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WebhookConfigImplCopyWith<$Res>
    implements $WebhookConfigCopyWith<$Res> {
  factory _$$WebhookConfigImplCopyWith(
          _$WebhookConfigImpl value, $Res Function(_$WebhookConfigImpl) then) =
      __$$WebhookConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? discord, String? slack, String? signal});
}

/// @nodoc
class __$$WebhookConfigImplCopyWithImpl<$Res>
    extends _$WebhookConfigCopyWithImpl<$Res, _$WebhookConfigImpl>
    implements _$$WebhookConfigImplCopyWith<$Res> {
  __$$WebhookConfigImplCopyWithImpl(
      _$WebhookConfigImpl _value, $Res Function(_$WebhookConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of WebhookConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discord = freezed,
    Object? slack = freezed,
    Object? signal = freezed,
  }) {
    return _then(_$WebhookConfigImpl(
      discord: freezed == discord
          ? _value.discord
          : discord // ignore: cast_nullable_to_non_nullable
              as String?,
      slack: freezed == slack
          ? _value.slack
          : slack // ignore: cast_nullable_to_non_nullable
              as String?,
      signal: freezed == signal
          ? _value.signal
          : signal // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$WebhookConfigImpl implements _WebhookConfig {
  const _$WebhookConfigImpl({this.discord, this.slack, this.signal});

  @override
  final String? discord;
  @override
  final String? slack;
  @override
  final String? signal;

  @override
  String toString() {
    return 'WebhookConfig(discord: $discord, slack: $slack, signal: $signal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebhookConfigImpl &&
            (identical(other.discord, discord) || other.discord == discord) &&
            (identical(other.slack, slack) || other.slack == slack) &&
            (identical(other.signal, signal) || other.signal == signal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, discord, slack, signal);

  /// Create a copy of WebhookConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebhookConfigImplCopyWith<_$WebhookConfigImpl> get copyWith =>
      __$$WebhookConfigImplCopyWithImpl<_$WebhookConfigImpl>(this, _$identity);
}

abstract class _WebhookConfig implements WebhookConfig {
  const factory _WebhookConfig(
      {final String? discord,
      final String? slack,
      final String? signal}) = _$WebhookConfigImpl;

  @override
  String? get discord;
  @override
  String? get slack;
  @override
  String? get signal;

  /// Create a copy of WebhookConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebhookConfigImplCopyWith<_$WebhookConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
