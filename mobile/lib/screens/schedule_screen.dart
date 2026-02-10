import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/session.dart';
import '../providers/session_provider.dart';
import '../widgets/session_list_tile.dart';
import 'session_form_screen.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, child) {
        final sessions = provider.sessions;
        
        if (sessions.isEmpty) {
          return _buildEmptyState(context);
        }
        
        final groupedSessions = _groupSessionsByDate(sessions);
        final sortedDates = groupedSessions.keys.toList()
          ..sort((a, b) => b.compareTo(a));
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final dateSessions = groupedSessions[date]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(date),
                ...dateSessions.map((session) => SessionListTile(
                  session: session,
                  onAttendanceChanged: (isPresent) {
                    provider.toggleAttendance(session.id, isPresent);
                  },
                  onTap: () => _navigateToForm(context, session: session),
                  onDelete: () => _confirmDelete(context, provider, session.id),
                )),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first session',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (sessionDate.isAtSameMomentAs(today)) {
      dateText = 'Today';
    } else if (sessionDate.isAtSameMomentAs(tomorrow)) {
      dateText = 'Tomorrow';
    } else {
      dateText = DateFormat('EEEE, MMM d').format(date);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        dateText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Map<DateTime, List<Session>> _groupSessionsByDate(List<Session> sessions) {
    final grouped = <DateTime, List<Session>>{};
    
    for (final session in sessions) {
      final date = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(session);
    }
    
    for (final sessions in grouped.values) {
      sessions.sort((a, b) {
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });
    }
    
    return grouped;
  }

  void _navigateToForm(BuildContext context, {Session? session}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionFormScreen(session: session),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SessionProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteSession(id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
