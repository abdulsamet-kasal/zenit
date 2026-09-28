import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
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
    final seffaf = Theme.of(context).extension<SeffafColors>();
    final StatusColor sc = switch (status) {
      ComplaintStatus.pending =>
        seffaf?.pending ?? const StatusColor(Color(0xFFFCF0D2), Color(0xFF7A5200)),
      ComplaintStatus.inReview =>
        seffaf?.reviewing ?? const StatusColor(Color(0xFFDDE9FB), Color(0xFF1B4DA0)),
      ComplaintStatus.resolved =>
        seffaf?.resolved ?? const StatusColor(Color(0xFFD9F0E1), Color(0xFF1B6B3C)),
      ComplaintStatus.rejected =>
        seffaf?.rejected ?? const StatusColor(Color(0xFFF9DEDA), Color(0xFF9E2A1F)),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: sc.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: sc.fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: sc.fg,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
