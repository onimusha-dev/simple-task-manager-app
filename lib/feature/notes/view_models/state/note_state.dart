import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journal_app/domain/models/note_model.dart';

part 'note_state.freezed.dart';

@freezed
abstract class NoteState with _$NoteState{
  factory NoteState({
    @Default(false) bool isLoading,
    @Default([]) List<NoteModel> notes,
    String? error,
  }) = _NoteState;
}
