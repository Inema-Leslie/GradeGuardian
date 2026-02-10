import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';
import '../providers/student_provider.dart';
import '../services/course_service.dart';
import '../theme/app_theme.dart';

class AssignmentFormScreen extends StatefulWidget {
  final Assignment? assignment;

  const AssignmentFormScreen({super.key, this.assignment});

  @override
  State<AssignmentFormScreen> createState() => _AssignmentFormScreenState();
}

class _AssignmentFormScreenState extends State<AssignmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  String? _selectedCourse;
  late DateTime _dueDate;
  late Priority _priority;
  late AssignmentType _type;

  bool get isEditing => widget.assignment != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.assignment?.title ?? '',
    );
    _selectedCourse = widget.assignment?.course;
    _dueDate = widget.assignment?.dueDate ?? DateTime.now().add(
      const Duration(days: 7),
    );
    _priority = widget.assignment?.priority ?? Priority.medium;
    _type = widget.assignment?.type ?? AssignmentType.formative;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>().student;
    final courses = student != null
        ? CourseService.instance.getCoursesForStudent(
            year: student.year,
            semester: student.semester,
            specialization: student.specialization,
          )
        : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Assignment' : 'New Assignment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter assignment title',
                  prefixIcon: Icon(Icons.assignment),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildCourseDropdown(courses),
              const SizedBox(height: 16),
              _buildTypeDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildPriorityDropdown(),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAssignment,
                      child: Text(isEditing ? 'Update' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseDropdown(List<String> courses) {
    if (isEditing && _selectedCourse != null && 
        _selectedCourse!.isNotEmpty && !courses.contains(_selectedCourse)) {
      courses = [...courses, _selectedCourse!];
    }

    return DropdownButtonFormField<String>(
      value: _selectedCourse,
      decoration: const InputDecoration(
        labelText: 'Course',
        prefixIcon: Icon(Icons.book),
      ),
      hint: const Text('Select a course'),
      items: courses.map((course) {
        return DropdownMenuItem(
          value: course,
          child: Text(
            course,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a course';
        }
        return null;
      },
      onChanged: (value) {
        setState(() => _selectedCourse = value);
      },
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<AssignmentType>(
      value: _type,
      decoration: const InputDecoration(
        labelText: 'Type',
        prefixIcon: Icon(Icons.category),
      ),
      items: const [
        DropdownMenuItem(
          value: AssignmentType.formative,
          child: Text('Formative'),
        ),
        DropdownMenuItem(
          value: AssignmentType.summative,
          child: Text('Summative'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _type = value);
        }
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due Date',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM d, yyyy').format(_dueDate)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<Priority>(
      value: _priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        prefixIcon: Icon(Icons.flag),
      ),
      items: Priority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(_getPriorityText(priority)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _priority = value);
        }
      },
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _saveAssignment() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AssignmentProvider>();
    final assignment = Assignment(
      id: widget.assignment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      course: _selectedCourse ?? '',
      dueDate: _dueDate,
      priority: _priority,
      type: _type,
      isCompleted: widget.assignment?.isCompleted ?? false,
    );

    if (isEditing) {
      provider.updateAssignment(assignment);
    } else {
      provider.addAssignment(assignment);
    }

    Navigator.pop(context);
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return AppTheme.riskRed;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return AppTheme.safeGreen;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }
}
