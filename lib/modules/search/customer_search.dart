import 'package:flutter/material.dart';
import 'package:user_auth_handling/modules/customers/customer_controller.dart';

class CustomerSearch extends StatelessWidget {
  final CustomerController controller;
  const CustomerSearch({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search customers...',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (v) {
          final q = v.trim();
          if (q.isEmpty) {
            controller.searchQuery.value = '';
          } else {
            controller.searchQuery.value =
                'searchquery=${Uri.encodeQueryComponent(q)}';
          }
          controller.fetchPageNumber(1);
        },
      ),
    );
  }
}
