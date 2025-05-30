// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lib.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DepositEventKind {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(MempoolEvent field0) mempool,
    required TResult Function(AwaitingConfsEvent field0) awaitingConfs,
    required TResult Function(ConfirmedEvent field0) confirmed,
    required TResult Function(ClaimedEvent field0) claimed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(MempoolEvent field0)? mempool,
    TResult? Function(AwaitingConfsEvent field0)? awaitingConfs,
    TResult? Function(ConfirmedEvent field0)? confirmed,
    TResult? Function(ClaimedEvent field0)? claimed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(MempoolEvent field0)? mempool,
    TResult Function(AwaitingConfsEvent field0)? awaitingConfs,
    TResult Function(ConfirmedEvent field0)? confirmed,
    TResult Function(ClaimedEvent field0)? claimed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DepositEventKind_Mempool value) mempool,
    required TResult Function(DepositEventKind_AwaitingConfs value)
    awaitingConfs,
    required TResult Function(DepositEventKind_Confirmed value) confirmed,
    required TResult Function(DepositEventKind_Claimed value) claimed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositEventKind_Mempool value)? mempool,
    TResult? Function(DepositEventKind_AwaitingConfs value)? awaitingConfs,
    TResult? Function(DepositEventKind_Confirmed value)? confirmed,
    TResult? Function(DepositEventKind_Claimed value)? claimed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositEventKind_Mempool value)? mempool,
    TResult Function(DepositEventKind_AwaitingConfs value)? awaitingConfs,
    TResult Function(DepositEventKind_Confirmed value)? confirmed,
    TResult Function(DepositEventKind_Claimed value)? claimed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DepositEventKindCopyWith<$Res> {
  factory $DepositEventKindCopyWith(
    DepositEventKind value,
    $Res Function(DepositEventKind) then,
  ) = _$DepositEventKindCopyWithImpl<$Res, DepositEventKind>;
}

/// @nodoc
class _$DepositEventKindCopyWithImpl<$Res, $Val extends DepositEventKind>
    implements $DepositEventKindCopyWith<$Res> {
  _$DepositEventKindCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DepositEventKind_MempoolImplCopyWith<$Res> {
  factory _$$DepositEventKind_MempoolImplCopyWith(
    _$DepositEventKind_MempoolImpl value,
    $Res Function(_$DepositEventKind_MempoolImpl) then,
  ) = __$$DepositEventKind_MempoolImplCopyWithImpl<$Res>;
  @useResult
  $Res call({MempoolEvent field0});
}

/// @nodoc
class __$$DepositEventKind_MempoolImplCopyWithImpl<$Res>
    extends _$DepositEventKindCopyWithImpl<$Res, _$DepositEventKind_MempoolImpl>
    implements _$$DepositEventKind_MempoolImplCopyWith<$Res> {
  __$$DepositEventKind_MempoolImplCopyWithImpl(
    _$DepositEventKind_MempoolImpl _value,
    $Res Function(_$DepositEventKind_MempoolImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$DepositEventKind_MempoolImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                as MempoolEvent,
      ),
    );
  }
}

/// @nodoc

class _$DepositEventKind_MempoolImpl extends DepositEventKind_Mempool {
  const _$DepositEventKind_MempoolImpl(this.field0) : super._();

  @override
  final MempoolEvent field0;

  @override
  String toString() {
    return 'DepositEventKind.mempool(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepositEventKind_MempoolImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DepositEventKind_MempoolImplCopyWith<_$DepositEventKind_MempoolImpl>
  get copyWith => __$$DepositEventKind_MempoolImplCopyWithImpl<
    _$DepositEventKind_MempoolImpl
  >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(MempoolEvent field0) mempool,
    required TResult Function(AwaitingConfsEvent field0) awaitingConfs,
    required TResult Function(ConfirmedEvent field0) confirmed,
    required TResult Function(ClaimedEvent field0) claimed,
  }) {
    return mempool(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(MempoolEvent field0)? mempool,
    TResult? Function(AwaitingConfsEvent field0)? awaitingConfs,
    TResult? Function(ConfirmedEvent field0)? confirmed,
    TResult? Function(ClaimedEvent field0)? claimed,
  }) {
    return mempool?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(MempoolEvent field0)? mempool,
    TResult Function(AwaitingConfsEvent field0)? awaitingConfs,
    TResult Function(ConfirmedEvent field0)? confirmed,
    TResult Function(ClaimedEvent field0)? claimed,
    required TResult orElse(),
  }) {
    if (mempool != null) {
      return mempool(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DepositEventKind_Mempool value) mempool,
    required TResult Function(DepositEventKind_AwaitingConfs value)
    awaitingConfs,
    required TResult Function(DepositEventKind_Confirmed value) confirmed,
    required TResult Function(DepositEventKind_Claimed value) claimed,
  }) {
    return mempool(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositEventKind_Mempool value)? mempool,
    TResult? Function(DepositEventKind_AwaitingConfs value)? awaitingConfs,
    TResult? Function(DepositEventKind_Confirmed value)? confirmed,
    TResult? Function(DepositEventKind_Claimed value)? claimed,
  }) {
    return mempool?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositEventKind_Mempool value)? mempool,
    TResult Function(DepositEventKind_AwaitingConfs value)? awaitingConfs,
    TResult Function(DepositEventKind_Confirmed value)? confirmed,
    TResult Function(DepositEventKind_Claimed value)? claimed,
    required TResult orElse(),
  }) {
    if (mempool != null) {
      return mempool(this);
    }
    return orElse();
  }
}

abstract class DepositEventKind_Mempool extends DepositEventKind {
  const factory DepositEventKind_Mempool(final MempoolEvent field0) =
      _$DepositEventKind_MempoolImpl;
  const DepositEventKind_Mempool._() : super._();

  @override
  MempoolEvent get field0;

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DepositEventKind_MempoolImplCopyWith<_$DepositEventKind_MempoolImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DepositEventKind_AwaitingConfsImplCopyWith<$Res> {
  factory _$$DepositEventKind_AwaitingConfsImplCopyWith(
    _$DepositEventKind_AwaitingConfsImpl value,
    $Res Function(_$DepositEventKind_AwaitingConfsImpl) then,
  ) = __$$DepositEventKind_AwaitingConfsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AwaitingConfsEvent field0});
}

/// @nodoc
class __$$DepositEventKind_AwaitingConfsImplCopyWithImpl<$Res>
    extends
        _$DepositEventKindCopyWithImpl<
          $Res,
          _$DepositEventKind_AwaitingConfsImpl
        >
    implements _$$DepositEventKind_AwaitingConfsImplCopyWith<$Res> {
  __$$DepositEventKind_AwaitingConfsImplCopyWithImpl(
    _$DepositEventKind_AwaitingConfsImpl _value,
    $Res Function(_$DepositEventKind_AwaitingConfsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$DepositEventKind_AwaitingConfsImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                as AwaitingConfsEvent,
      ),
    );
  }
}

/// @nodoc

class _$DepositEventKind_AwaitingConfsImpl
    extends DepositEventKind_AwaitingConfs {
  const _$DepositEventKind_AwaitingConfsImpl(this.field0) : super._();

  @override
  final AwaitingConfsEvent field0;

  @override
  String toString() {
    return 'DepositEventKind.awaitingConfs(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepositEventKind_AwaitingConfsImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DepositEventKind_AwaitingConfsImplCopyWith<
    _$DepositEventKind_AwaitingConfsImpl
  >
  get copyWith => __$$DepositEventKind_AwaitingConfsImplCopyWithImpl<
    _$DepositEventKind_AwaitingConfsImpl
  >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(MempoolEvent field0) mempool,
    required TResult Function(AwaitingConfsEvent field0) awaitingConfs,
    required TResult Function(ConfirmedEvent field0) confirmed,
    required TResult Function(ClaimedEvent field0) claimed,
  }) {
    return awaitingConfs(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(MempoolEvent field0)? mempool,
    TResult? Function(AwaitingConfsEvent field0)? awaitingConfs,
    TResult? Function(ConfirmedEvent field0)? confirmed,
    TResult? Function(ClaimedEvent field0)? claimed,
  }) {
    return awaitingConfs?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(MempoolEvent field0)? mempool,
    TResult Function(AwaitingConfsEvent field0)? awaitingConfs,
    TResult Function(ConfirmedEvent field0)? confirmed,
    TResult Function(ClaimedEvent field0)? claimed,
    required TResult orElse(),
  }) {
    if (awaitingConfs != null) {
      return awaitingConfs(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DepositEventKind_Mempool value) mempool,
    required TResult Function(DepositEventKind_AwaitingConfs value)
    awaitingConfs,
    required TResult Function(DepositEventKind_Confirmed value) confirmed,
    required TResult Function(DepositEventKind_Claimed value) claimed,
  }) {
    return awaitingConfs(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositEventKind_Mempool value)? mempool,
    TResult? Function(DepositEventKind_AwaitingConfs value)? awaitingConfs,
    TResult? Function(DepositEventKind_Confirmed value)? confirmed,
    TResult? Function(DepositEventKind_Claimed value)? claimed,
  }) {
    return awaitingConfs?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositEventKind_Mempool value)? mempool,
    TResult Function(DepositEventKind_AwaitingConfs value)? awaitingConfs,
    TResult Function(DepositEventKind_Confirmed value)? confirmed,
    TResult Function(DepositEventKind_Claimed value)? claimed,
    required TResult orElse(),
  }) {
    if (awaitingConfs != null) {
      return awaitingConfs(this);
    }
    return orElse();
  }
}

abstract class DepositEventKind_AwaitingConfs extends DepositEventKind {
  const factory DepositEventKind_AwaitingConfs(
    final AwaitingConfsEvent field0,
  ) = _$DepositEventKind_AwaitingConfsImpl;
  const DepositEventKind_AwaitingConfs._() : super._();

  @override
  AwaitingConfsEvent get field0;

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DepositEventKind_AwaitingConfsImplCopyWith<
    _$DepositEventKind_AwaitingConfsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DepositEventKind_ConfirmedImplCopyWith<$Res> {
  factory _$$DepositEventKind_ConfirmedImplCopyWith(
    _$DepositEventKind_ConfirmedImpl value,
    $Res Function(_$DepositEventKind_ConfirmedImpl) then,
  ) = __$$DepositEventKind_ConfirmedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ConfirmedEvent field0});
}

/// @nodoc
class __$$DepositEventKind_ConfirmedImplCopyWithImpl<$Res>
    extends
        _$DepositEventKindCopyWithImpl<$Res, _$DepositEventKind_ConfirmedImpl>
    implements _$$DepositEventKind_ConfirmedImplCopyWith<$Res> {
  __$$DepositEventKind_ConfirmedImplCopyWithImpl(
    _$DepositEventKind_ConfirmedImpl _value,
    $Res Function(_$DepositEventKind_ConfirmedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$DepositEventKind_ConfirmedImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                as ConfirmedEvent,
      ),
    );
  }
}

/// @nodoc

class _$DepositEventKind_ConfirmedImpl extends DepositEventKind_Confirmed {
  const _$DepositEventKind_ConfirmedImpl(this.field0) : super._();

  @override
  final ConfirmedEvent field0;

  @override
  String toString() {
    return 'DepositEventKind.confirmed(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepositEventKind_ConfirmedImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DepositEventKind_ConfirmedImplCopyWith<_$DepositEventKind_ConfirmedImpl>
  get copyWith => __$$DepositEventKind_ConfirmedImplCopyWithImpl<
    _$DepositEventKind_ConfirmedImpl
  >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(MempoolEvent field0) mempool,
    required TResult Function(AwaitingConfsEvent field0) awaitingConfs,
    required TResult Function(ConfirmedEvent field0) confirmed,
    required TResult Function(ClaimedEvent field0) claimed,
  }) {
    return confirmed(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(MempoolEvent field0)? mempool,
    TResult? Function(AwaitingConfsEvent field0)? awaitingConfs,
    TResult? Function(ConfirmedEvent field0)? confirmed,
    TResult? Function(ClaimedEvent field0)? claimed,
  }) {
    return confirmed?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(MempoolEvent field0)? mempool,
    TResult Function(AwaitingConfsEvent field0)? awaitingConfs,
    TResult Function(ConfirmedEvent field0)? confirmed,
    TResult Function(ClaimedEvent field0)? claimed,
    required TResult orElse(),
  }) {
    if (confirmed != null) {
      return confirmed(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DepositEventKind_Mempool value) mempool,
    required TResult Function(DepositEventKind_AwaitingConfs value)
    awaitingConfs,
    required TResult Function(DepositEventKind_Confirmed value) confirmed,
    required TResult Function(DepositEventKind_Claimed value) claimed,
  }) {
    return confirmed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositEventKind_Mempool value)? mempool,
    TResult? Function(DepositEventKind_AwaitingConfs value)? awaitingConfs,
    TResult? Function(DepositEventKind_Confirmed value)? confirmed,
    TResult? Function(DepositEventKind_Claimed value)? claimed,
  }) {
    return confirmed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositEventKind_Mempool value)? mempool,
    TResult Function(DepositEventKind_AwaitingConfs value)? awaitingConfs,
    TResult Function(DepositEventKind_Confirmed value)? confirmed,
    TResult Function(DepositEventKind_Claimed value)? claimed,
    required TResult orElse(),
  }) {
    if (confirmed != null) {
      return confirmed(this);
    }
    return orElse();
  }
}

abstract class DepositEventKind_Confirmed extends DepositEventKind {
  const factory DepositEventKind_Confirmed(final ConfirmedEvent field0) =
      _$DepositEventKind_ConfirmedImpl;
  const DepositEventKind_Confirmed._() : super._();

  @override
  ConfirmedEvent get field0;

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DepositEventKind_ConfirmedImplCopyWith<_$DepositEventKind_ConfirmedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DepositEventKind_ClaimedImplCopyWith<$Res> {
  factory _$$DepositEventKind_ClaimedImplCopyWith(
    _$DepositEventKind_ClaimedImpl value,
    $Res Function(_$DepositEventKind_ClaimedImpl) then,
  ) = __$$DepositEventKind_ClaimedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ClaimedEvent field0});
}

/// @nodoc
class __$$DepositEventKind_ClaimedImplCopyWithImpl<$Res>
    extends _$DepositEventKindCopyWithImpl<$Res, _$DepositEventKind_ClaimedImpl>
    implements _$$DepositEventKind_ClaimedImplCopyWith<$Res> {
  __$$DepositEventKind_ClaimedImplCopyWithImpl(
    _$DepositEventKind_ClaimedImpl _value,
    $Res Function(_$DepositEventKind_ClaimedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$DepositEventKind_ClaimedImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                as ClaimedEvent,
      ),
    );
  }
}

/// @nodoc

class _$DepositEventKind_ClaimedImpl extends DepositEventKind_Claimed {
  const _$DepositEventKind_ClaimedImpl(this.field0) : super._();

  @override
  final ClaimedEvent field0;

  @override
  String toString() {
    return 'DepositEventKind.claimed(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepositEventKind_ClaimedImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DepositEventKind_ClaimedImplCopyWith<_$DepositEventKind_ClaimedImpl>
  get copyWith => __$$DepositEventKind_ClaimedImplCopyWithImpl<
    _$DepositEventKind_ClaimedImpl
  >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(MempoolEvent field0) mempool,
    required TResult Function(AwaitingConfsEvent field0) awaitingConfs,
    required TResult Function(ConfirmedEvent field0) confirmed,
    required TResult Function(ClaimedEvent field0) claimed,
  }) {
    return claimed(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(MempoolEvent field0)? mempool,
    TResult? Function(AwaitingConfsEvent field0)? awaitingConfs,
    TResult? Function(ConfirmedEvent field0)? confirmed,
    TResult? Function(ClaimedEvent field0)? claimed,
  }) {
    return claimed?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(MempoolEvent field0)? mempool,
    TResult Function(AwaitingConfsEvent field0)? awaitingConfs,
    TResult Function(ConfirmedEvent field0)? confirmed,
    TResult Function(ClaimedEvent field0)? claimed,
    required TResult orElse(),
  }) {
    if (claimed != null) {
      return claimed(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DepositEventKind_Mempool value) mempool,
    required TResult Function(DepositEventKind_AwaitingConfs value)
    awaitingConfs,
    required TResult Function(DepositEventKind_Confirmed value) confirmed,
    required TResult Function(DepositEventKind_Claimed value) claimed,
  }) {
    return claimed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositEventKind_Mempool value)? mempool,
    TResult? Function(DepositEventKind_AwaitingConfs value)? awaitingConfs,
    TResult? Function(DepositEventKind_Confirmed value)? confirmed,
    TResult? Function(DepositEventKind_Claimed value)? claimed,
  }) {
    return claimed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositEventKind_Mempool value)? mempool,
    TResult Function(DepositEventKind_AwaitingConfs value)? awaitingConfs,
    TResult Function(DepositEventKind_Confirmed value)? confirmed,
    TResult Function(DepositEventKind_Claimed value)? claimed,
    required TResult orElse(),
  }) {
    if (claimed != null) {
      return claimed(this);
    }
    return orElse();
  }
}

abstract class DepositEventKind_Claimed extends DepositEventKind {
  const factory DepositEventKind_Claimed(final ClaimedEvent field0) =
      _$DepositEventKind_ClaimedImpl;
  const DepositEventKind_Claimed._() : super._();

  @override
  ClaimedEvent get field0;

  /// Create a copy of DepositEventKind
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DepositEventKind_ClaimedImplCopyWith<_$DepositEventKind_ClaimedImpl>
  get copyWith => throw _privateConstructorUsedError;
}
