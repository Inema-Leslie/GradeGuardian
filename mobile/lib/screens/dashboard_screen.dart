import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/assignment.dart';
import '../models/session.dart';
import '../providers/assignment_provider.dart';
import '../providers/session_provider.dart';
import '../providers/student_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_status_card.dart';
import '../widgets/session_list_tile.dart';
import 'log_past_session_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SessionProvider, AssignmentProvider>(
      builder: (context, sessionProvider, assignmentProvider, child) {
        final student = context.watch<StudentProvider>().student;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(),
              if (student != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Year ${student.year}, Semester ${student.semester}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildAcademicWeekCard(sessionProvider.currentAcademicWeek),
              const SizedBox(height: 16),
              RiskStatusCard(
                attendancePercentage: sessionProvider.attendancePercentage,
              ),
              const SizedBox(height: 16),
              _buildLogPastSessionButton(context),
              const SizedBox(height: 24),
              _buildThisWeekAssignmentsSection(assignmentProvider),
              const SizedBox(height: 24),
              _buildThisWeekSessionsSection(sessionProvider),
              const SizedBox(height: 24),
              _buildTodaySessionsSection(context, sessionProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    
    return Text(
      dateFormat.format(now),
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.navyBlue,
      ),
    );
  }

  Widget _buildAcademicWeekCard(int week) {
    return Card(
      color: AppTheme.gold,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month,
              color: AppTheme.navyBlue,
              size: 32,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Academic Week',
                  style: TextStyle(
                    color: AppTheme.navyBlue,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Week $week',
                  style: const TextStyle(
                    color: AppTheme.navyBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogPastSessionButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LogPastSessionScreen(),
          ),
        );
      },
      icon: const Icon(Icons.history),
      label: const Text('Log Past Session'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.navyBlue,
        side: const BorderSide(color: AppTheme.navyBlue),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget _buildThisWeekAssignmentsSection(AssignmentProvider provider) {
    final thisWeekAssignments = provider.thisWeekAssignments;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.assignment, size: 20, color: AppTheme.navyBlue),
            const SizedBox(width: 8),
            const Text(
              'Due This Week',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.navyBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${thisWeekAssignments.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.navyBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (thisWeekAssignments.isEmpty)
          _buildEmptyCard('No assignments due this week', Icons.check_circle_outline)
        else
          ...thisWeekAssignments.map((a) => _buildAssignmentCard(a)),
      ],
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    final isOverdue = assignment.dueDate.isBefore(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: assignment.type == AssignmentType.summative
                    ? Colors.purple.withValues(alpha: 0.15)
                    : Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                assignment.type == AssignmentType.summative ? 'S' : 'F',
                style: TextStyle(
                  fontSize: 11,
                  color: assignment.type == AssignmentType.summative
                      ? Colors.purple
                      : Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    assignment.course,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              DateFormat('EEE, MMM d').format(assignment.dueDate),
              style: TextStyle(
                fontSize: 12,
                color: isOverdue ? AppTheme.riskRed : Colors.grey[700],
                fontWeight: isOverdue ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThisWeekSessionsSection(SessionProvider provider) {
    final thisWeekSessions = provider.thisWeekSessions;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, size: 20, color: AppTheme.navyBlue),
            const SizedBox(width: 8),
            const Text(
              "This Week's Sessions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.navyBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${thisWeekSessions.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.navyBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (thisWeekSessions.isEmpty)
          _buildEmptyCard('No sessions scheduled this week', Icons.event_available)
        else
          ...thisWeekSessions.take(5).map((session) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getSessionColor(session.type),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          session.type.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('EEE').format(session.date),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (session.isPresent != null)
                        Icon(
                          session.isPresent! ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: session.isPresent! ? AppTheme.safeGreen : AppTheme.riskRed,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          )),
        if (thisWeekSessions.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${thisWeekSessions.length - 5} more sessions',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTodaySessionsSection(
    BuildContext context,
    SessionProvider provider,
  ) {
    final todaySessions = provider.todaySessions;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Sessions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${todaySessions.length} session${todaySessions.length != 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (todaySessions.isEmpty)
          _buildEmptyCard('No sessions scheduled for today', Icons.event_available)
        else
          ...todaySessions.map((session) => SessionListTile(
            session: session,
            onAttendanceChanged: (isPresent) {
              provider.toggleAttendance(session.id, isPresent);
            },
          )),
      ],
    );
  }

  Widget _buildEmptyCard(String message, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSessionColor(dynamic type) {
    switch (type.toString()) {
      case 'SessionType.classSession':
        return AppTheme.navyBlue;
      case 'SessionType.masterySession':
        return Colors.purple;
      case 'SessionType.studyGroup':
        return Colors.teal;
      case 'SessionType.pslMeeting':
        return Colors.orange;
      default:
        return AppTheme.navyBlue;
    }
  }
}
