import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

            // Raw Data Section
            const Text(
              "Raw API Data",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  (item is Map || item is List)
                      ? const JsonEncoder.withIndent('  ').convert(item)
                      : item.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
