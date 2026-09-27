import 'package:flutter/material.dart';
import '../../core/constants/category_defaults.dart';

class CategoryBadge extends StatelessWidget {
  final String categoryId;
  final bool showIcon;

  const CategoryBadge({
    super.key,
    required this.categoryId,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final cat = CategoryDefaults.getById(categoryId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cat.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cat.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(cat.icon, size: 14, color: cat.color),
            const SizedBox(width: 4),
          ],
          Text(
            cat.name,
            style: TextStyle(
              color: cat.color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
