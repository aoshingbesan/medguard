import 'package:flutter/material.dart';

/// Academic Disclaimer Widget
/// Displays "For Academic Demonstration Only" disclaimer on all screens
class AcademicDisclaimer extends StatelessWidget {
  const AcademicDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          top: BorderSide(color: Colors.orange.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            'For Academic Demonstration Only',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

