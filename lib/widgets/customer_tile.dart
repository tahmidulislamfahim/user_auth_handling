import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:user_auth_handling/data/api_provider.dart';
import 'package:user_auth_handling/widgets/customer_details.dart';

class CustomerTile extends StatelessWidget {
  final dynamic item;
  final String? token;

  const CustomerTile({super.key, required this.item, this.token});

  String? getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;
    return ApiProvider.imageBaseLink +
        relativePath.replaceFirst(RegExp(r'^/'), '');
  }

  Future<Uint8List?> fetchImageBytes(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Accept": "image/jpeg",
        },
      );
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name =
        item['Name'] ?? item['CustomerName'] ?? item['name'] ?? 'Unknown';

    dynamic rawBalance() {
      final candidates = [
        'TotalDue',
        'TotalDueAmount',
        'TotalDueAmt',
        'Balance',
        'balance',
        'Amount',
        'TotalCollection',
      ];
      for (final k in candidates) {
        if (item is Map && item.containsKey(k) && item[k] != null) {
          return item[k];
        }
      }
      return null;
    }

    String addCommas(String s) {
      final regex = RegExp(r"(\d+)(\d{3})");
      var str = s;
      while (regex.hasMatch(str)) {
        str = str.replaceAllMapped(regex, (m) => '${m[1]},${m[2]}');
      }
      return str;
    }

    String formatCurrency(dynamic v) {
      if (v == null) return '0';
      num? n;
      if (v is num) {
        n = v;
      } else {
        try {
          n = num.parse(v.toString());
        } catch (e) {
          return v.toString();
        }
      }
      final fixed = n.toStringAsFixed(2);
      final parts = fixed.split('.');
      final intPart = addCommas(parts[0]);
      return '$intPart.${parts[1]}';
    }

    final rawBal = rawBalance();
    final balance = formatCurrency(rawBal);
    final imagePath = item['Image'] ?? item['Photo'] ?? item['ImagePath'];
    final imageUrl = getFullImageUrl(imagePath);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          child: ClipOval(
            child: SizedBox(
              height: 60,
              width: 60,
              child: imageUrl != null
                  ? FutureBuilder<Uint8List?>(
                      future: fetchImageBytes(imageUrl),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        } else if (snapshot.hasError || snapshot.data == null) {
                          return const Icon(Icons.person);
                        } else {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        }
                      },
                    )
                  : const Icon(Icons.person),
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Balance: \$$balance'),
        trailing: const Icon(Icons.chevron_right),

        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            builder: (_) => CustomerDetails(
              item: item,
              name: name,
              balance: balance,
              imageUrl: imageUrl,
              fetchImageBytes: fetchImageBytes,
            ),
          );
        },
      ),
    );
  }
}
