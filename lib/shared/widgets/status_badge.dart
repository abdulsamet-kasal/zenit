import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/complaint_status.dart';

class StatusBadge extends StatelessWidget {
  final ComplaintStatus status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;
    switch (status) {
      case ComplaintStatus.pending:
        color = AppColors.statusPending;
        textColor = const Color(0xFFB45309);
        break;
      case ComplaintStatus.inReview:
        color = AppColors.statusInReview;
        textColor = const Color(0xFF1D4ED8);
        break;
      case ComplaintStatus.resolved:
        color = AppColors.statusResolved;
        textColor = const Color(0xFF047857);
        break;
      case ComplaintStatus.rejected:
        color = AppColors.statusRejected;
        textColor = const Color(0xFFB91C1C);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: textColor,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
