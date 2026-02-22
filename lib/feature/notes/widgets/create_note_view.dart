import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/data/db/tables/note_table.dart';
import 'package:fuck_your_todos/domain/models/note_model.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';

/// Bottom-sheet widget for creating or editing a note.
///
/// Usage (create):
///   showModalBottomSheet(builder: (_) => const CreateNoteView());
///
/// Usage (edit):
///   showModalBottomSheet(builder: (_) => CreateNoteView(noteToEdit: note));
class CreateNoteView extends ConsumerStatefulWidget {
  /// Optional note for edit mode. If null, creates a new note.
  final NoteModel? noteToEdit;

  /// Optional date to pre-populate the due-date field.
  /// Pass [CalendarScreen]'s selected date when launching from the calendar tab.
  /// If null, no due date is pre-filled.
  final DateTime? initialDate;

  const CreateNoteView({super.key, this.noteToEdit, this.initialDate});

  @override
  ConsumerState<CreateNoteView> createState() => _CreateNoteViewState();
}

class _CreateNoteViewState extends ConsumerState<CreateNoteView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _selectedDateTime;
  Priority _selectedPriority = Priority.none;

  // Key lets us programmatically open the priority popup
  final _priorityMenuKey = GlobalKey<PopupMenuButtonState<Priority>>();

  bool get _isEditMode => widget.noteToEdit != null;

  // Rebuild save-button reactively when title changes
  bool get _canSave {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    return title.isNotEmpty && title.length <= 50 && description.length <= 200;
  }

  @override
  void initState() {
    super.initState();
    final note = widget.noteToEdit;
    _titleController = TextEditingController(text: note?.title ?? '')
      ..addListener(_onTitleChanged);
    _descriptionController = TextEditingController(
      text: note?.description ?? '',
    );
    // Edit mode: use the note's saved due date.
    // Create mode: use initialDate (from calendar) if provided, else null.
    _selectedDateTime = note?.dueDate ?? widget.initialDate;
    _selectedPriority = note?.priority ?? Priority.none;
  }

  void _onTitleChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ─── Priority helpers ──────────────────────────────────────────────────────

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.high:
        return Colors.redAccent;
      case Priority.medium:
        return Colors.orangeAccent;
      case Priority.low:
        return Colors.lightBlueAccent;
      case Priority.none:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _priorityLabel(Priority p) {
    switch (p) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
      case Priority.none:
        return 'Priority';
    }
  }

  IconData _priorityIcon(Priority p) {
    switch (p) {
      case Priority.high:
        return Icons.flag_rounded;
      case Priority.medium:
        return Icons.flag_outlined;
      case Priority.low:
        return Icons.outlined_flag;
      case Priority.none:
        return Icons.outlined_flag;
    }
  }

  // ─── Date / time ──────────────────────────────────────────────────────────

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isTomorrow =
        dt.year == now.year && dt.month == now.month && dt.day == now.day + 1;

    final dateStr = isToday
        ? 'Today'
        : isTomorrow
        ? 'Tomorrow'
        : '${dt.day}/${dt.month}/${dt.year}';

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dateStr  ${hour.toString().padLeft(2, '0')}:$min $period';
  }

  Future<void> _pickDateTime() async {
    // --- Pick date ---
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;

    // --- Pick time ---
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDateTime!)
          : TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final dueDateStr = _selectedDateTime?.toIso8601String();

    if (_isEditMode) {
      final note = widget.noteToEdit!;
      bool isSameDt(DateTime? a, DateTime? b) {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        return a.isAtSameMomentAs(b);
      }

      final hasChanges =
          title != note.title ||
          description != (note.description ?? '') ||
          !isSameDt(_selectedDateTime, note.dueDate) ||
          _selectedPriority != note.priority;

      if (hasChanges) {
        await ref
            .read(noteViewModelProvider.notifier)
            .updateNote(note.id, title, description, dueDateStr);

        // Update priority separately if changed
        if (_selectedPriority != note.priority) {
          await ref
              .read(noteViewModelProvider.notifier)
              .updateNotePriority(note.id, _selectedPriority);
        }
      }
    } else {
      await ref
          .read(noteViewModelProvider.notifier)
          .insertNote(title, description, dueDateStr, _selectedPriority);
    }

    if (mounted) Navigator.pop(context);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: keyboardHeight > 0 ? keyboardHeight + 16 : bottomPadding + 24,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ──
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isEditMode ? Icons.edit_note_rounded : Icons.add_task,
                  color: cs.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isEditMode ? 'Edit Note' : 'New Note',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Title ──
          _buildTextField(
            controller: _titleController,
            hint: 'Note title…',
            cs: cs,
            type: TextFieldType.title,
          ),
          const SizedBox(height: 12),

          // ── Description ──
          _buildTextField(
            controller: _descriptionController,
            hint: 'Description (optional)',
            cs: cs,
            maxLines: 3,
            type: TextFieldType.description,
          ),
          const SizedBox(height: 20),

          // ── Action chips ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Date/time chip
              _NoteChip(
                icon: Icons.schedule_rounded,
                label: _selectedDateTime != null
                    ? _formatDateTime(_selectedDateTime!)
                    : 'Set time',
                color: _selectedDateTime != null ? cs.primary : cs.outline,
                onTap: _pickDateTime,
                onClear: _selectedDateTime != null
                    ? () => setState(() => _selectedDateTime = null)
                    : null,
              ),

              // Priority chip — tap to open menu (when none); tap to clear (when set)
              PopupMenuButton<Priority>(
                key: _priorityMenuKey,
                onSelected: (p) => setState(() => _selectedPriority = p),
                offset: const Offset(0, -120),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: cs.surfaceContainerHighest,
                itemBuilder: (_) =>
                    [Priority.high, Priority.medium, Priority.low].map((p) {
                      final isSelected = _selectedPriority == p;
                      return PopupMenuItem<Priority>(
                        value: p,
                        child: Row(
                          children: [
                            Icon(
                              _priorityIcon(p),
                              color: _priorityColor(p),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _priorityLabel(p),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: cs.onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: _priorityColor(p),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                child: _NoteChip(
                  icon: _priorityIcon(_selectedPriority),
                  label: _priorityLabel(_selectedPriority),
                  color: _priorityColor(_selectedPriority),
                  // If a priority is set: clear it. If none: open the menu.
                  onTap: () {
                    if (_selectedPriority != Priority.none) {
                      setState(() => _selectedPriority = Priority.none);
                    } else {
                      _priorityMenuKey.currentState?.showButtonMenu();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Save button ──
          SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton.icon(
                onPressed: _canSave ? _save : null,
                icon: Icon(
                  _isEditMode
                      ? Icons.check_circle_outline
                      : Icons.add_circle_outline,
                  size: 20,
                ),
                label: Text(
                  _isEditMode ? 'Update Note' : 'Create Note',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor: cs.surfaceContainerHigh,
                  disabledForegroundColor: cs.outline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required ColorScheme cs,
    required TextFieldType type,
    int maxLines = 1,
  }) {
    final maxLength = type == TextFieldType.title ? 50 : 200;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final length = value.text.length;
        final isOverLimit = length > maxLength;

        final borderColor = isOverLimit ? cs.error : cs.primary;
        final counterColor = isOverLimit ? cs.error : cs.outline;

        return TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.none, // allow overflow
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: cs.onSurface),
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: cs.outline),
            filled: true,
            fillColor: cs.surfaceContainerHigh,

            // 👇 dynamic border
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isOverLimit
                    ? cs.error.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            // ⭐ floating counter top-left
            label: length < 35
                ? null
                : Text(
                    '$length/$maxLength',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: counterColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

            floatingLabelBehavior: FloatingLabelBehavior.always,

            // ❌ remove bottom counter
            counterText: '',
          ),
        );
      },
    );
  }
}

// ─── Reusable chip ─────────────────────────────────────────────────────────

class _NoteChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  /// If non-null, shows a small ✕ button to clear the value.
  final VoidCallback? onClear;

  const _NoteChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(
          left: 12,
          right: onClear != null ? 4 : 12,
          top: 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 14, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum TextFieldType { description, title }
