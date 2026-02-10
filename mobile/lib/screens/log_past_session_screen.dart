import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/session.dart';
import '../providers/session_provider.dart';
import '../providers/student_provider.dart';
import '../services/course_service.dart';
import '../theme/app_theme.dart';

class LogPastSessionScreen extends StatefulWidget {
  const LogPastSessionScreen({super.key});

  @override
  State<LogPastSessionScreen> createState() => _LogPastSessionScreenState();
}

class _LogPastSessionScreenState extends State<LogPastSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCourse;
  late DateTime _date;
  late SessionType _type;
  bool _wasPresent = true;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now().subtract(const Duration(days: 1));
    _type = SessionType.classSession;
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
        title: const Text('Log Past Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.navyBlue),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Log sessions you attended previously to update your attendance tracking.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildCourseDropdown(courses),
              const SizedBox(height: 16),
              _buildTypeDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 24),
              _buildAttendanceToggle(),
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
                      child: const Text('Log Session'),
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
    return DropdownButtonFormField<String>(
      value: _selectedCourse,
      decoration: const InputDecoration(
        labelText: 'Course/Session Name',
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
            Text(DateFormat('EEEE, MMM d, yyyy').format(_date)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Were you present?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _wasPresent ? 'Marked as Present' : 'Marked as Absent',
                    style: TextStyle(
                      color: _wasPresent ? AppTheme.safeGreen : AppTheme.riskRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _wasPresent,
              onChanged: (value) {
                setState(() => _wasPresent = value);
              },
              activeColor: AppTheme.safeGreen,
              inactiveThumbColor: AppTheme.riskRed,
              inactiveTrackColor: AppTheme.riskRed.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _saveSession() {
    if (!_formKey.currentState!.validate()) return;

    final session = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _selectedCourse!,
      type: _type,
      date: _date,
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      isPresent: _wasPresent,
    );

    context.read<SessionProvider>().addSession(session);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Session logged as ${_wasPresent ? 'Present' : 'Absent'}',
        ),
        backgroundColor: _wasPresent ? AppTheme.safeGreen : AppTheme.riskRed,
      ),
    );
  }
}
