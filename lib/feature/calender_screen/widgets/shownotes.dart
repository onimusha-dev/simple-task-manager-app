import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/data/db/tables/note_table.dart';
import 'package:fuck_your_todos/feature/notes/view_models/task_category_view_model.dart';
import 'package:fuck_your_todos/feature/notes/widgets/task_edit_options.dart';
import 'package:intl/intl.dart';

class Shownotes extends ConsumerStatefulWidget {
  const Shownotes({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.dueTime,
    required this.priority,
    required this.tags,
    required this.isCompleted,
    this.taskType,
  });

  final int id;
  final String title;
  final String description;
  final DateTime dueTime;
  final bool isCompleted;
  final Priority priority;
  final List<String> tags;
  final int? taskType;

  @override
  ConsumerState<Shownotes> createState() => _ShownotesState();
}

class _ShownotesState extends ConsumerState<Shownotes> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(taskCategoryViewModelProvider);

    // Precise colors from the image
    Color cardColor;
    Color tagColor;
    Color textColor = widget.isCompleted
        ? Colors.grey
        : const Color(0xFF212121);

    final colorMapping = {
      Priority.high: const Color(0xFFF7F1FF), // Lavender/Purple
      Priority.medium: const Color(0xFFEDF8FF), // Blue
      Priority.low: const Color(0xFFF0FAF5), // Green
      Priority.none: const Color(0xFFFBFBFB),
    };

    final tagColorMapping = {
      Priority.high: const Color(0xFFE9D8FF),
      Priority.medium: const Color(0xFFD6EEFF),
      Priority.low: const Color(0xFFDAF6E9),
      Priority.none: const Color(0xFFF0F0F0),
    };

    cardColor = colorMapping[widget.priority] ?? const Color(0xFFFBFBFB);
    tagColor = tagColorMapping[widget.priority] ?? const Color(0xFFF0F0F0);

    if (widget.isCompleted) {
      cardColor = Colors.grey.shade100;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Column
          SizedBox(
            width: 64,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Continuous Line
                Positioned.fill(
                  child: CustomPaint(
                    painter: DottedLinePainter(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                // Time label
                Positioned(
                  top: 12,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 4,
                    ),
                    child: Text(
                      DateFormat('H:mm').format(widget.dueTime),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Task Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 12, top: 20),
              child: GestureDetector(
                onLongPress: () => showTaskOptions(
                  context,
                  ref,
                  widget.id,
                  widget.isCompleted,
                ),
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.01),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: textColor,
                                letterSpacing: -0.3,
                                decoration: widget.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (widget.isCompleted)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: textColor.withOpacity(0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Due ${DateFormat('h:mm a').format(widget.dueTime)}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: textColor.withOpacity(0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Priority: ${widget.priority.name[0].toUpperCase()}${widget.priority.name.substring(1)}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      categoriesState.maybeWhen(
                        data: (cats) {
                          final match =
                              cats
                                  .where((c) => c.id == widget.taskType)
                                  .firstOrNull ??
                              cats.firstOrNull;
                          if (match == null) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              match.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color.lerp(tagColor, Colors.black, 0.6),
                              ),
                            ),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),

                      if (isExpanded && widget.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// it is used to draw the dotted line in the timeline
/// [color] is the color of the dotted line
class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double dashHeight = 5, dashSpace = 3, startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// it is used to draw the footer of the timeline
/// [time] is the time of the footer
class TimelineFooter extends StatelessWidget {
  final DateTime time;
  const TimelineFooter({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: DottedLinePainter(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 4,
                    ),
                    child: Text(
                      DateFormat('H:mm').format(time),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
