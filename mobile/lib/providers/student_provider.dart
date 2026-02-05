import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../services/storage_service.dart';

class StudentProvider with ChangeNotifier {
  Student? _student;
  final StorageService _storageService;
  bool _isLoading = true;

  StudentProvider(this._storageService) {
    _loadStudent();
  }

  Student? get student => _student;
  bool get isLoggedIn => _student != null;
  bool get isLoading => _isLoading;

  void _loadStudent() {
    _student = _storageService.loadStudent();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(Student student) async {
    _student = student;
    await _storageService.saveStudent(student);
    notifyListeners();
  }

  Future<void> updateStudent(Student student) async {
    _student = student;
    await _storageService.saveStudent(student);
    notifyListeners();
  }

  Future<void> logout() async {
    _student = null;
    await _storageService.clearAll();
    notifyListeners();
  }
}
