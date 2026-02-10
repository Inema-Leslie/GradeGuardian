import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import '../services/course_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  int _selectedYear = 1;
  int _selectedSemester = 1;
  String? _selectedSpecialization;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _needsSpecialization =>
      CourseService.instance.needsSpecialization(_selectedYear, _selectedSemester);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navyBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildYearDropdown(),
                const SizedBox(height: 20),
                _buildSemesterDropdown(),
                if (_needsSpecialization) ...[
                  const SizedBox(height: 20),
                  _buildSpecializationDropdown(),
                ],
                const SizedBox(height: 32),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.gold,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 40,
            color: AppTheme.navyBlue,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome to GradeGuardian',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please enter your details to continue',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'ALU Email',
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        hintText: 'name@email.com',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        prefixIcon: Icon(Icons.email, color: Colors.white.withValues(alpha: 0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.orangeAccent),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        if (!Student.isValidEmail(value)) {
          return 'Please use your ALU student email';
        }
        return null;
      },
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedYear,
      dropdownColor: AppTheme.navyBlue,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Year',
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(Icons.calendar_today, color: Colors.white.withValues(alpha: 0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.gold, width: 2),
        ),
      ),
      items: [1, 2, 3].map((year) {
        return DropdownMenuItem(
          value: year,
          child: Text('Year $year'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedYear = value!;
          if (!_needsSpecialization) {
            _selectedSpecialization = null;
          }
        });
      },
    );
  }

  Widget _buildSemesterDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedSemester,
      dropdownColor: AppTheme.navyBlue,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Semester',
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(Icons.school, color: Colors.white.withValues(alpha: 0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.gold, width: 2),
        ),
      ),
      items: [1, 2, 3].map((semester) {
        return DropdownMenuItem(
          value: semester,
          child: Text('Semester $semester'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSemester = value!;
          if (!_needsSpecialization) {
            _selectedSpecialization = null;
          }
        });
      },
    );
  }

  Widget _buildSpecializationDropdown() {
    final specializations = CourseService.instance.getSpecializations();
    
    return DropdownButtonFormField<String>(
      value: _selectedSpecialization,
      dropdownColor: AppTheme.navyBlue,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Specialization',
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(Icons.psychology, color: Colors.white.withValues(alpha: 0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.gold, width: 2),
        ),
      ),
      hint: Text(
        'Select your track',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      ),
      items: specializations.map((spec) {
        return DropdownMenuItem(
          value: spec,
          child: Text(
            spec,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      validator: (value) {
        if (_needsSpecialization && (value == null || value.isEmpty)) {
          return 'Please select your specialization';
        }
        return null;
      },
      onChanged: (value) {
        setState(() => _selectedSpecialization = value);
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.gold,
        foregroundColor: AppTheme.navyBlue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.navyBlue,
              ),
            )
          : const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final student = Student(
      email: _emailController.text.trim().toLowerCase(),
      year: _selectedYear,
      semester: _selectedSemester,
      specialization: _selectedSpecialization,
    );

    await context.read<StudentProvider>().login(student);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
