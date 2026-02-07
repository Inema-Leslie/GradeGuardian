import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../theme/app_theme.dart';

class AssignmentListTile extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onToggleCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AssignmentListTile({
    super.key,
    required this.assignment,
    required this.onToggleCompleted,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = assignment.dueDate.isBefore(DateTime.now()) && 
                      !assignment.isCompleted;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: assignment.isCompleted,
                    onChanged: (_) => onToggleCompleted(),
                    activeColor: AppTheme.safeGreen,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: assignment.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: assignment.isCompleted
                            ? Colors.grey
                            : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (assignment.course.isNotEmpty)
                      Text(
                        assignment.course,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
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
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getPriorityText(),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getPriorityColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: isOverdue ? AppTheme.riskRed : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d').format(assignment.dueDate),
                          style: TextStyle(
                            color: isOverdue ? AppTheme.riskRed : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: isOverdue ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.grey,
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (assignment.priority) {
      case Priority.high:
        return AppTheme.riskRed;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return AppTheme.safeGreen;
    }
  }

  String _getPriorityText() {
    switch (assignment.priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }
}
