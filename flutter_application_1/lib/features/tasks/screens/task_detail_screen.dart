import 'package:flutter/material.dart';

import '../../../data/models/task_model.dart';
import '../task_controller.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.controller,
  });

  final Task task;
  final TaskController controller;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _task.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _task.status.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _InfoRow(label: 'Mata Kuliah', value: _task.courseName),
              _InfoRow(label: 'Deadline', value: _task.formattedDeadline),
              _InfoRow(label: 'Status', value: _task.status.label),
              _InfoRow(label: 'Keterangan', value: _task.description.isEmpty ? 'Tidak ada keterangan.' : _task.description),
              _InfoRow(
                label: 'Keadaan',
                value: _task.isOverdue
                    ? 'Deadline terlewat'
                    : _task.isDueSoon
                        ? 'Deadline mendekat'
                        : _task.relativeDeadlineText,
              ),
              const SizedBox(height: 20),
              Text(
                'Ubah Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskStatus>(
                segments: const [
                  ButtonSegment(value: TaskStatus.belumDikerjakan, label: Text('Belum Dikerjakan')),
                  ButtonSegment(value: TaskStatus.sedangDikerjakan, label: Text('Sedang Dikerjakan')),
                  ButtonSegment(value: TaskStatus.selesai, label: Text('Selesai')),
                ],
                selected: {_task.status},
                onSelectionChanged: (selection) async {
                  final newStatus = selection.first;
                  final updatedTask = _task.copyWith(status: newStatus, updatedAt: DateTime.now());
                  await widget.controller.updateTask(updatedTask);
                  if (!mounted) return;
                  setState(() {
                    _task = updatedTask;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _openEditScreen,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_rounded),
                      label: const Text('Hapus'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditScreen() async {
    final updated = await Navigator.of(context).push<Task?>(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          controller: widget.controller,
          task: _task,
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _task = updated;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus tugas?'),
        content: Text('Apakah Anda yakin ingin menghapus "${_task.title}"?'),
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
      await widget.controller.deleteTask(_task);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
