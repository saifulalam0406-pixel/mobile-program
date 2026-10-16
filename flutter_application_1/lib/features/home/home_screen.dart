import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/task_model.dart';
import '../tasks/task_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final summary = controller.summary;
        final upcomingTasks = controller.upcomingTasks.take(3).toList();
        final overdueTasks = controller.overdueTasks.take(3).toList();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pantau semua tugas kuliah agar deadline tetap teratur.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.6,
                    children: [
                      _StatCard(
                        label: 'Total',
                        value: '${summary['total'] ?? 0}',
                        icon: Icons.assignment_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _StatCard(
                        label: 'Belum Dikerjakan',
                        value: '${summary['belumDikerjakan'] ?? 0}',
                        icon: Icons.pending_actions_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      _StatCard(
                        label: 'Sedang Dikerjakan',
                        value: '${summary['sedangDikerjakan'] ?? 0}',
                        icon: Icons.sync_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      _StatCard(
                        label: 'Selesai',
                        value: '${summary['selesai'] ?? 0}',
                        icon: Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Deadline Terdekat',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (upcomingTasks.isEmpty)
                    _EmptyInlineMessage(
                      message: 'Tidak ada tugas yang akan segera jatuh tempo.',
                    )
                  else
                    ...upcomingTasks.map((task) => _TaskMiniCard(task: task)),
                  const SizedBox(height: 28),
                  Text(
                    'Deadline Terlewat',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (overdueTasks.isEmpty)
                    _EmptyInlineMessage(
                      message: 'Tidak ada tugas yang melewati deadline.',
                    )
                  else
                    ...overdueTasks.map((task) => _TaskMiniCard(task: task, isOverdue: true)),
                  const SizedBox(height: 52),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskMiniCard extends StatelessWidget {
  const _TaskMiniCard({
    required this.task,
    this.isOverdue = false,
  });

  final Task task;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final statusColor = task.status == TaskStatus.selesai
        ? Theme.of(context).colorScheme.primary
        : task.status == TaskStatus.sedangDikerjakan
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.tertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: isOverdue ? Colors.red : statusColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.courseName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task.formattedDeadline,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              task.status.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInlineMessage extends StatelessWidget {
  const _EmptyInlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
