import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  (String, Color, Color) _style() {
    switch (status.toLowerCase()) {
      case 'completed':
        return ('completed', Color(0xFF0B6B52), Color(0xFFE4EFEA));
      case 'partially_refunded':
        return (
          'Partially_refunded',
          const Color(0xFF9A5B00),
          const Color(0xFFFFF4DD),
        );
      case 'refunded':
        return ('Refunded', const Color(0xFF4E5A54), const Color(0xFFE9ECEA));
      case 'failed':
        return ('Failed', const Color(0xFFA12626), const Color(0xFFFBE7E7));
      case 'pending':
      case 'processing':
      case 'created':
        return (
          'In Progress',
          const Color(0xFF9A5B00),
          const Color(0xFFFFF4DD),
        );
      default:
        return (status, const Color(0xFF4E5A54), const Color(0xFFE9ECEA));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, textColor, bgColor) = _style();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
