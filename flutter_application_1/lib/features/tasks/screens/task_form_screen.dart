import 'package:flutter/material.dart';

import '../../../data/models/task_model.dart';
import '../task_controller.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({
    super.key,
    required this.controller,
    this.task,
  });

  final TaskController controller;
  final Task? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _courseController;
  late final TextEditingController _descriptionController;

  late DateTime _deadline;
  late TaskStatus _status;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _courseController = TextEditingController(text: task?.courseName ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _deadline = task?.deadline ?? DateTime.now().add(const Duration(days: 1));
    _status = task?.status ?? TaskStatus.belumDikerjakan;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Tambah Tugas' : 'Edit Tugas'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task == null ? 'Tambah tugas baru' : 'Perbarui tugas',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nama tugas',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Nama tugas wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _courseController,
                  decoration: const InputDecoration(
                    labelText: 'Mata kuliah',
                    prefixIcon: Icon(Icons.school_rounded),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Mata kuliah wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Deadline: ${_deadline.day}/${_deadline.month}/${_deadline.year}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Jam: ${_deadline.hour.toString().padLeft(2, '0')}:${_deadline.minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<TaskStatus>(
                  segments: const [
                    ButtonSegment(value: TaskStatus.belumDikerjakan, label: Text('Belum Dikerjakan')),
                    ButtonSegment(value: TaskStatus.sedangDikerjakan, label: Text('Sedang Dikerjakan')),
                    ButtonSegment(value: TaskStatus.selesai, label: Text('Selesai')),
                  ],
                  selected: {_status},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _status = selection.first;
                    });
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saveTask,
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate != null) {
      setState(() {
        _deadline = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _deadline.hour,
          _deadline.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
    );

    if (pickedTime != null) {
      setState(() {
        _deadline = DateTime(
          _deadline.year,
          _deadline.month,
          _deadline.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final task = (widget.task ?? Task(
      title: '',
      courseName: '',
      deadline: _deadline,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )).copyWith(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      courseName: _courseController.text.trim(),
      deadline: _deadline,
      description: _descriptionController.text.trim(),
      status: _status,
      updatedAt: DateTime.now(),
    );

    if (widget.task == null) {
      await widget.controller.addTask(task);
    } else {
      await widget.controller.updateTask(task);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.task == null ? 'Tugas berhasil ditambahkan.' : 'Tugas berhasil diperbarui.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }
}
