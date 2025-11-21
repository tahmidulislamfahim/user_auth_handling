import 'package:flutter/material.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
