import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journal_app/data/db/app_database.dart';

part 'note_model.freezed.dart';

@freezed
abstract class NoteModel with _$NoteModel {
  factory NoteModel({
    @Default(0) int id,
    required String title,
    required String? description,
    required String? dueDate,
    required String createdAt,
    required String updatedAt,
  }) = _NoteModel;

  factory NoteModel.fromEntity(NoteTableData note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      description: note.description,
      dueDate: note.dueDate != null
          ? formatDateAndTimeDifference(note.dueDate!)
          : null,
      createdAt: formatDateAndTimeDifference(note.createdAt),
      updatedAt: formatDateAndTimeDifference(note.updatedAt),
    );
  }
}

String formatDateAndTimeDifference(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays > 0) {
    return '${diff.inDays}d ago';
  } else if (diff.inHours > 0) {
    return '${diff.inHours}h ago';
  } else if (diff.inMinutes > 0) {
    return '${diff.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}
