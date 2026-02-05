import 'package:flutter/foundation.dart';
import '../models/assignment.dart';
import '../services/storage_service.dart';

class AssignmentProvider with ChangeNotifier {
  List<Assignment> _assignments = [];
  final StorageService _storageService;

  AssignmentProvider(this._storageService) {
    _loadAssignments();
  }

  List<Assignment> get assignments => List.unmodifiable(_assignments);

  List<Assignment> get pendingAssignments =>
      _assignments.where((a) => !a.isCompleted).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<Assignment> get completedAssignments =>
      _assignments.where((a) => a.isCompleted).toList();

  List<Assignment> get thisWeekAssignments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));
    
    return _assignments.where((a) {
      if (a.isCompleted) return false;
      final dueDate = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
      return dueDate.isAfter(today.subtract(const Duration(days: 1))) &&
             dueDate.isBefore(weekEnd);
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  void _loadAssignments() {
    _assignments = _storageService.loadAssignments();
    notifyListeners();
  }

  Future<void> addAssignment(Assignment assignment) async {
    _assignments.add(assignment);
    await _storageService.saveAssignments(_assignments);
    notifyListeners();
  }

  Future<void> updateAssignment(Assignment assignment) async {
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      _assignments[index] = assignment;
      await _storageService.saveAssignments(_assignments);
      notifyListeners();
    }
  }

  Future<void> deleteAssignment(String id) async {
    _assignments.removeWhere((a) => a.id == id);
    await _storageService.saveAssignments(_assignments);
    notifyListeners();
  }

  Future<void> toggleCompleted(String id) async {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final assignment = _assignments[index];
      _assignments[index] = assignment.copyWith(
        isCompleted: !assignment.isCompleted,
      );
      await _storageService.saveAssignments(_assignments);
      notifyListeners();
    }
  }

  void clear() {
    _assignments = [];
    notifyListeners();
  }
}
