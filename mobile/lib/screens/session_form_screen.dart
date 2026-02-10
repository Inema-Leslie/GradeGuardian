import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/session.dart';
import '../providers/session_provider.dart';
import '../providers/student_provider.dart';
import '../services/course_service.dart';
import '../theme/app_theme.dart';

class SessionFormScreen extends StatefulWidget {
  final Session? session;

  const SessionFormScreen({super.key, this.session});

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCourse;
  late SessionType _type;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  bool get isEditing => widget.session != null;

  @override
  void initState() {
    super.initState();
    _selectedCourse = widget.session?.name;
    _type = widget.session?.type ?? SessionType.classSession;
    _date = widget.session?.date ?? DateTime.now();
    _startTime = widget.session?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.session?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
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
        title: Text(isEditing ? 'Edit Session' : 'New Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCourseDropdown(courses),
              const SizedBox(height: 16),
              _buildTypeDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTimePicker('Start Time', _startTime, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimePicker('End Time', _endTime, false)),
                ],
              ),
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
                      onPressed: _saveSession,
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
    if (isEditing && _selectedCourse != null && !courses.contains(_selectedCourse)) {
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
    return DropdownButtonFormField<SessionType>(
      value: _type,
      decoration: const InputDecoration(
        labelText: 'Session Type',
        prefixIcon: Icon(Icons.category),
      ),
      items: SessionType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
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
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM d, yyyy').format(_date)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, bool isStart) {
    return InkWell(
      onTap: () => _selectTime(isStart),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatTime(time)),
            const Icon(Icons.access_time, color: AppTheme.navyBlue),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveSession() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SessionProvider>();
    final session = Session(
      id: widget.session?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _selectedCourse!,
      type: _type,
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      isPresent: widget.session?.isPresent,
    );

    if (isEditing) {
      provider.updateSession(session);
    } else {
      provider.addSession(session);
    }

    Navigator.pop(context);
  }
}
