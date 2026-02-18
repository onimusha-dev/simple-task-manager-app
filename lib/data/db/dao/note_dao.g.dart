// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_dao.dart';

// ignore_for_file: type=lint
mixin _$NoteDaoMixin on DatabaseAccessor<AppDatabase> {
  $NoteTableTable get noteTable => attachedDatabase.noteTable;
  NoteDaoManager get managers => NoteDaoManager(this);
}

class NoteDaoManager {
  final _$NoteDaoMixin _db;
  NoteDaoManager(this._db);
  $$NoteTableTableTableManager get noteTable =>
      $$NoteTableTableTableManager(_db.attachedDatabase, _db.noteTable);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(noteDaoProvider)
const noteDaoProviderProvider = NoteDaoProviderProvider._();

final class NoteDaoProviderProvider
    extends $FunctionalProvider<NoteDao, NoteDao, NoteDao>
    with $Provider<NoteDao> {
  const NoteDaoProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteDaoProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteDaoProviderHash();

  @$internal
  @override
  $ProviderElement<NoteDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoteDao create(Ref ref) {
    return noteDaoProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteDao>(value),
    );
  }
}

String _$noteDaoProviderHash() => r'a2b84270754aa55ce4f57dc1454c5c3b4093edf7';
