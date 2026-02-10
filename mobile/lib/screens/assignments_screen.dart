import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/assignment_list_tile.dart';
import 'assignment_form_screen.dart';

enum AssignmentFilter { all, formative, summative }

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  AssignmentFilter _filter = AssignmentFilter.all;

  @override
  Widget build(BuildContext context) {
    return Consumer<AssignmentProvider>(
      builder: (context, provider, child) {
        final allAssignments = provider.assignments;
        
        // Filter by type
        final filteredAssignments = allAssignments.where((a) {
          switch (_filter) {
            case AssignmentFilter.all:
              return true;
            case AssignmentFilter.formative:
              return a.type == AssignmentType.formative;
            case AssignmentFilter.summative:
              return a.type == AssignmentType.summative;
          }
        }).toList();

        // Split into pending and completed
        final pendingAssignments = filteredAssignments
            .where((a) => !a.isCompleted)
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        final completedAssignments = filteredAssignments
            .where((a) => a.isCompleted)
            .toList();
        
        return Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: pendingAssignments.isEmpty && completedAssignments.isEmpty
                  ? _buildEmptyState(context)
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        if (pendingAssignments.isNotEmpty) ...[
                          _buildSectionHeader('Pending', pendingAssignments.length),
                          ...pendingAssignments.map((assignment) => AssignmentListTile(
                            assignment: assignment,
                            onToggleCompleted: () => provider.toggleCompleted(assignment.id),
                            onTap: () => _navigateToForm(context, assignment: assignment),
                            onDelete: () => _confirmDelete(context, provider, assignment.id),
                          )),
                        ],
                        if (completedAssignments.isNotEmpty) ...[
                          _buildSectionHeader('Completed', completedAssignments.length),
                          ...completedAssignments.map((assignment) => AssignmentListTile(
                            assignment: assignment,
                            onToggleCompleted: () => provider.toggleCompleted(assignment.id),
                            onTap: () => _navigateToForm(context, assignment: assignment),
                            onDelete: () => _confirmDelete(context, provider, assignment.id),
                          )),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip('All', AssignmentFilter.all),
          const SizedBox(width: 8),
          _buildChip('Formative', AssignmentFilter.formative),
          const SizedBox(width: 8),
          _buildChip('Summative', AssignmentFilter.summative),
        ],
      ),
    );
  }

  Widget _buildChip(String label, AssignmentFilter filter) {
    final isSelected = _filter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = filter),
      selectedColor: AppTheme.navyBlue.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.navyBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.navyBlue : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    String message;
    switch (_filter) {
      case AssignmentFilter.all:
        message = 'No assignments yet';
        break;
      case AssignmentFilter.formative:
        message = 'No formative assignments';
        break;
      case AssignmentFilter.summative:
        message = 'No summative assignments';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first assignment',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, {dynamic assignment}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignmentFormScreen(assignment: assignment),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AssignmentProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure you want to delete this assignment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAssignment(id);
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
