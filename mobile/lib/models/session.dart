import 'package:flutter/material.dart';

enum SessionType { classSession, masterySession, studyGroup, pslMeeting }

extension SessionTypeExtension on SessionType {
  String get displayName {
    switch (this) {
      case SessionType.classSession:
        return 'Class';
      case SessionType.masterySession:
        return 'Mastery Session';
      case SessionType.studyGroup:
        return 'Study Group';
      case SessionType.pslMeeting:
        return 'PSL Meeting';
    }
  }
}

class Session {
  final String id;
  final String name;
  final SessionType type;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool? isPresent;

  Session({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isPresent,
  });

  Session copyWith({
    String? id,
    String? name,
    SessionType? type,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isPresent,
    bool clearPresent = false,
  }) {
    return Session(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isPresent: clearPresent ? null : (isPresent ?? this.isPresent),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'date': date.toIso8601String(),
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'isPresent': isPresent,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      name: json['name'] as String,
      type: SessionType.values[json['type'] as int],
      date: DateTime.parse(json['date'] as String),
      startTime: TimeOfDay(
        hour: json['startHour'] as int,
        minute: json['startMinute'] as int,
      ),
      endTime: TimeOfDay(
        hour: json['endHour'] as int,
        minute: json['endMinute'] as int,
      ),
      isPresent: json['isPresent'] as bool?,
    );
  }

  String get timeRange {
    final startStr = _formatTime(startTime);
    final endStr = _formatTime(endTime);
    return '$startStr - $endStr';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
