import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  // Helper to check if two dates are same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(noteViewModelProvider);
    final allTasks = tasksState.notes;

    final totalTasks = allTasks.length;
    final totalCompleted = allTasks.where((t) => t.isCompleted).length;
    final totalPending = totalTasks - totalCompleted;

    final completionRate = totalTasks > 0
        ? (totalCompleted / totalTasks * 100).round()
        : 0;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate last 7 days metrics
    final now = DateTime.now();
    final List<_DailyStat> last7Days = List.generate(7, (index) {
      // 6 to 0
      final day = now.subtract(Duration(days: 6 - index));
      final tasksForDay = allTasks.where((t) {
        // Evaluate based on dueDate if present, otherwise createdAt
        final targetDate = t.dueDate ?? t.createdAt;
        return _isSameDay(targetDate, day);
      }).toList();

      final completed = tasksForDay.where((t) => t.isCompleted).length;
      return _DailyStat(
        date: day,
        total: tasksForDay.length,
        completed: completed,
      );
    });

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Analytics",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your productivity patterns & stats",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Highlight Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: "Total Tasks",
                    value: "$totalTasks",
                    icon: Icons.list_alt_rounded,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: "Completed",
                    value: "$totalCompleted",
                    icon: Icons.check_circle_rounded,
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: "Pending",
                    value: "$totalPending",
                    icon: Icons.pending_actions_rounded,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: "Finish Rate",
                    value: "$completionRate%",
                    icon: Icons.trending_up_rounded,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Bar Chart Section
            Text(
              "Activity (Last 7 Days)",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 300,
              padding: const EdgeInsets.only(
                top: 24,
                bottom: 12,
                left: 12,
                right: 24,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(last7Days),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => colorScheme.surface,

                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final stat = last7Days[groupIndex];
                        return BarTooltipItem(
                          rodIndex == 0
                              ? 'Total: ${stat.total}'
                              : 'Done: ${stat.completed}',
                          TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          if (val.toInt() < 0 ||
                              val.toInt() >= last7Days.length) {
                            return const SizedBox.shrink();
                          }
                          final date = last7Days[val.toInt()].date;
                          final isToday = _isSameDay(date, DateTime.now());

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              isToday
                                  ? 'Today'
                                  : DateFormat('EEE').format(date),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isToday
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (val, meta) {
                          if (val % 1 != 0) return const SizedBox.shrink();
                          return Text(
                            val.toInt().toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(last7Days.length, (index) {
                    final stat = last7Days[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        // Total tasks bar
                        BarChartRodData(
                          toY: stat.total.toDouble(),
                          color: colorScheme.outlineVariant,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        // Completed tasks bar
                        BarChartRodData(
                          toY: stat.completed.toDouble(),
                          color: colorScheme.primary,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendIndicator(
                  color: colorScheme.outlineVariant,
                  label: "Total Created",
                ),
                const SizedBox(width: 24),
                _LegendIndicator(
                  color: colorScheme.primary,
                  label: "Completed",
                ),
              ],
            ),
            const SizedBox(height: 100), // Navigation bar padding
          ],
        ),
      ),
    );
  }

  double _getMaxY(List<_DailyStat> stats) {
    if (stats.isEmpty) return 4;
    final maxTotal = stats.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    return maxTotal < 4 ? 4 : (maxTotal * 1.2).toDouble();
  }
}

class _DailyStat {
  final DateTime date;
  final int total;
  final int completed;

  _DailyStat({
    required this.date,
    required this.total,
    required this.completed,
  });
}

class _LegendIndicator extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendIndicator({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
