import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment.dart';
import '../models/session.dart';
import '../models/student.dart';

class StorageService {
  static const String _assignmentsKey = 'assignments';
  static const String _sessionsKey = 'sessions';
  static const String _studentKey = 'student';

  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  Future<void> saveAssignments(List<Assignment> assignments) async {
    final jsonList = assignments.map((a) => a.toJson()).toList();
    await _prefs.setString(_assignmentsKey, jsonEncode(jsonList));
  }

  List<Assignment> loadAssignments() {
    final jsonString = _prefs.getString(_assignmentsKey);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => Assignment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSessions(List<Session> sessions) async {
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _prefs.setString(_sessionsKey, jsonEncode(jsonList));
  }

  List<Session> loadSessions() {
    final jsonString = _prefs.getString(_sessionsKey);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => Session.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveStudent(Student student) async {
    await _prefs.setString(_studentKey, jsonEncode(student.toJson()));
  }

  Student? loadStudent() {
    final jsonString = _prefs.getString(_studentKey);
    if (jsonString == null) return null;
    
    return Student.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  Future<void> clearStudent() async {
    await _prefs.remove(_studentKey);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_studentKey);
    await _prefs.remove(_assignmentsKey);
    await _prefs.remove(_sessionsKey);
  }
}

