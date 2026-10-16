import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../task_controller.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.controller});

  final TaskController controller;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final tasks = widget.controller.filteredTasks;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Daftar Tugas',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: widget.controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Cari tugas atau mata kuliah',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              widget.controller.setSearchQuery('');
                            },
                            icon: const Icon(Icons.clear_rounded),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TaskStatusFilter>(
                        initialValue: widget.controller.statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter',
                          prefixIcon: Icon(Icons.filter_list_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: TaskStatusFilter.all,
                            child: Text('Semua'),
                          ),
                          DropdownMenuItem(
                            value: TaskStatusFilter.belumDikerjakan,
                            child: Text('Belum Dikerjakan'),
                          ),
                          DropdownMenuItem(
                            value: TaskStatusFilter.sedangDikerjakan,
                            child: Text('Sedang Dikerjakan'),
                          ),
                          DropdownMenuItem(
                            value: TaskStatusFilter.selesai,
                            child: Text('Selesai'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            widget.controller.setStatusFilter(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<TaskSort>(
                        initialValue: widget.controller.sort,
                        decoration: const InputDecoration(
                          labelText: 'Urutkan',
                          prefixIcon: Icon(Icons.sort_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: TaskSort.deadlineNearest,
                            child: Text('Deadline terdekat'),
                          ),
                          DropdownMenuItem(
                            value: TaskSort.deadlineFarthest,
                            child: Text('Deadline terjauh'),
                          ),
                          DropdownMenuItem(
                            value: TaskSort.titleAsc,
                            child: Text('Nama A-Z'),
                          ),
                          DropdownMenuItem(
                            value: TaskSort.titleDesc,
                            child: Text('Nama Z-A'),
                          ),
                          DropdownMenuItem(
                            value: TaskSort.courseAsc,
                            child: Text('Mata kuliah A-Z'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            widget.controller.setSort(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: tasks.isEmpty
                      ? SingleChildScrollView(
                          child: EmptyStateWidget(
                            title: AppConstants.emptyStateTitle,
                            message: AppConstants.emptyStateMessage,
                            actionLabel: '+ Tambah Tugas',
                            onActionPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TaskFormScreen(
                                    controller: widget.controller,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : ListView.separated(
                          itemCount: tasks.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TaskDetailScreen(
                                        task: task,
                                        controller: widget.controller,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  task.title,
                                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _statusColor(context, task.status).withValues(alpha: 0.18),
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              task.status.label,
                                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                color: _statusColor(context, task.status),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month_rounded,
                                            size: 18,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              task.formattedDeadline,
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ),
                                          if (task.isOverdue)
                                            const Icon(Icons.warning_amber_rounded, color: Colors.red),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            task.relativeDeadlineText,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: task.isOverdue
                                                  ? Colors.red
                                                  : Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => TaskFormScreen(
                                                        controller: widget.controller,
                                                        task: task,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.edit_rounded),
                                                tooltip: 'Edit',
                                              ),
                                              IconButton(
                                                onPressed: () => _deleteTask(context, task),
                                                icon: const Icon(Icons.delete_rounded),
                                                tooltip: 'Hapus',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus tugas?'),
        content: Text('Apakah Anda yakin ingin menghapus "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await widget.controller.deleteTask(task);
      if (mounted && messenger != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Tugas berhasil dihapus.')),
        );
      }
    }
  }

  Color _statusColor(BuildContext context, TaskStatus status) {
    switch (status) {
      case TaskStatus.belumDikerjakan:
        return Theme.of(context).colorScheme.tertiary;
      case TaskStatus.sedangDikerjakan:
        return Theme.of(context).colorScheme.secondary;
      case TaskStatus.selesai:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
