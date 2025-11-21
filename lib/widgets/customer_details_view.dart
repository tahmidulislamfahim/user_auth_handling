import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:user_auth_handling/widgets/detail_row.dart';

class CustomerDetails extends StatelessWidget {
  final dynamic item;
  final String name;
  final String balance;
  final String? imageUrl;
  final Future<Uint8List?> Function(String url) fetchImageBytes;

  const CustomerDetails({
    super.key,
    required this.item,
    required this.name,
    required this.balance,
    required this.imageUrl,
    required this.fetchImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // User Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 70,
                    width: 70,
                    child: imageUrl == null
                        ? Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 40),
                          )
                        : FutureBuilder<Uint8List?>(
                            future: fetchImageBytes(imageUrl!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  alignment: Alignment.center,
                                  color: Colors.grey[200],
                                  child: const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }

                              if (!snapshot.hasData) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.person, size: 40),
                                );
                              }

                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Name and Balance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Balance: \$$balance",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 8),

            DetailRow(label: 'ID', value: _pick(item, ['Id'])),
            const SizedBox(height: 8),
            DetailRow(label: 'Email', value: _pick(item, ['Email'])),
            const SizedBox(height: 8),
            DetailRow(label: 'Phone', value: _pick(item, ['Phone'])),
            const SizedBox(height: 8),
            DetailRow(
              label: 'Primary Address',
              value: _pick(item, ['PrimaryAddress']),
            ),
            const SizedBox(height: 8),
            DetailRow(
              label: 'Secondary Address',
              value: _pick(item, ['SecoundaryAddress']),
            ),
            const SizedBox(height: 8),
            DetailRow(
              label: 'Balance',
              value: _formatCurrency(_pick(item, ['Balance'])),
            ),
            const SizedBox(height: 8),
            DetailRow(
              label: 'TotalDue',
              value: _formatCurrency(_pick(item, ['TotalDue'])),
            ),
            const SizedBox(height: 8),
            DetailRow(
              label: 'Last Transaction',
              value: _pick(item, ['LastTransactionDate']),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _pick(dynamic item, List<String> keys) {
    if (item is Map) {
      for (final k in keys) {
        if (item.containsKey(k) && item[k] != null) {
          final s = item[k].toString();
          if (s.trim().isNotEmpty) return s;
        }
      }
    }
    return '';
  }

  String _formatCurrency(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '0.00';
    num? n;
    try {
      n = num.parse(raw.toString());
    } catch (_) {
      return raw;
    }
    final fixed = n.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final dec = parts.length > 1 ? parts[1] : '00';
    final regex = RegExp(r"(\d+)(\d{3})");
    var s = intPart;
    while (regex.hasMatch(s)) {
      s = s.replaceAllMapped(regex, (m) => '${m[1]},${m[2]}');
    }
    return '$s.$dec';
  }
}
