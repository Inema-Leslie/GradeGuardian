import 'package:flutter/material.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';

class SessionListTile extends StatelessWidget {
  final Session session;
  final Function(bool) onAttendanceChanged;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const SessionListTile({
    super.key,
    required this.session,
    required this.onAttendanceChanged,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: _getTypeColor(),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor().withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            session.type.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getTypeColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          session.timeRange,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Text(
                    'Present',
                    style: TextStyle(fontSize: 12),
                  ),
                  Switch(
                    value: session.isPresent ?? false,
                    onChanged: onAttendanceChanged,
                    activeColor: AppTheme.safeGreen,
                    inactiveThumbColor: session.isPresent == null
                        ? Colors.grey
                        : AppTheme.riskRed,
                    inactiveTrackColor: session.isPresent == null
                        ? Colors.grey.withValues(alpha: 0.3)
                        : AppTheme.riskRed.withValues(alpha: 0.3),
                  ),
                ],
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.grey,
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (session.type) {
      case SessionType.classSession:
        return AppTheme.navyBlue;
      case SessionType.masterySession:
        return Colors.purple;
      case SessionType.studyGroup:
        return Colors.teal;
      case SessionType.pslMeeting:
        return AppTheme.gold;
    }
  }
}
