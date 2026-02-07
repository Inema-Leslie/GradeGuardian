import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RiskStatusCard extends StatelessWidget {
  final double attendancePercentage;

  const RiskStatusCard({
    super.key,
    required this.attendancePercentage,
  });

  bool get isAtRisk => attendancePercentage < 75.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isAtRisk ? AppTheme.riskRed : AppTheme.safeGreen,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isAtRisk ? Icons.warning_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAtRisk ? 'AT RISK' : 'Good Standing',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Attendance: ${attendancePercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
