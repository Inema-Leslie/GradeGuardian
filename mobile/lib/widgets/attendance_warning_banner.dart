import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AttendanceWarningBanner extends StatelessWidget {
  final double attendancePercentage;

  const AttendanceWarningBanner({
    super.key,
    required this.attendancePercentage,
  });

  @override
  Widget build(BuildContext context) {
    if (attendancePercentage >= 75.0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.riskRed.withValues(alpha: 0.15),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.riskRed.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.riskRed,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Attendance at ${attendancePercentage.toStringAsFixed(1)}% - You are trailing behind',
              style: TextStyle(
                color: AppTheme.riskRed,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
