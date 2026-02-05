import 'package:flutter/foundation.dart';
import '../models/session.dart';
import '../services/storage_service.dart';

class SessionProvider with ChangeNotifier {
  List<Session> _sessions = [];
  final StorageService _storageService;

  SessionProvider(this._storageService) {
    _loadSessions();
  }

  List<Session> get sessions => List.unmodifiable(_sessions);

  List<Session> get todaySessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _sessions.where((s) {
      final sessionDate = DateTime(s.date.year, s.date.month, s.date.day);
      return sessionDate.isAtSameMomentAs(today);
    }).toList()
      ..sort((a, b) {
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });
  }

  List<Session> get thisWeekSessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    return _sessions.where((s) {
      final sessionDate = DateTime(s.date.year, s.date.month, s.date.day);
      return sessionDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             sessionDate.isBefore(weekEnd);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  double get attendancePercentage {
    final markedSessions = _sessions.where((s) => s.isPresent != null).toList();
    if (markedSessions.isEmpty) return 100.0;
    final presentCount = markedSessions.where((s) => s.isPresent == true).length;
    return (presentCount / markedSessions.length) * 100;
  }

  bool get isAtRisk => attendancePercentage < 75.0;

  int get currentAcademicWeek {
    final semesterStart = DateTime(2026, 1, 13);
    final now = DateTime.now();
    final difference = now.difference(semesterStart).inDays;
    if (difference < 0) return 1;
    return ((difference / 7).floor() + 1).clamp(1, 15);
  }

  void _loadSessions() {
    _sessions = _storageService.loadSessions();
    notifyListeners();
  }

  Future<void> addSession(Session session) async {
    _sessions.add(session);
    await _storageService.saveSessions(_sessions);
    notifyListeners();
  }

  Future<void> updateSession(Session session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
      await _storageService.saveSessions(_sessions);
      notifyListeners();
    }
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    await _storageService.saveSessions(_sessions);
    notifyListeners();
  }

  Future<void> toggleAttendance(String id, bool isPresent) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(isPresent: isPresent);
      await _storageService.saveSessions(_sessions);
      notifyListeners();
    }
  }

  void clear() {
    _sessions = [];
    notifyListeners();
  }
}
