import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_auth_handling/data/auth_repository.dart';
import 'package:user_auth_handling/modules/customers/customer_controller.dart';
import 'package:user_auth_handling/modules/search/customer_search.dart';
import 'package:user_auth_handling/modules/pagination/pagination_bar.dart';
import 'package:user_auth_handling/widgets/customer_tile.dart';

class CustomerListView extends StatelessWidget {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CustomerController());
    final auth = Get.find<AuthRepository>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Customers',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () {
              auth.logout();
              Get.offAllNamed('/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          CustomerSearch(controller: c),

          // Customer list
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.customers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (c.customers.isEmpty) {
                return const Center(child: Text('No customers found'));
              }

              return RefreshIndicator(
                onRefresh: c.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: c.customers.length,
                  itemBuilder: (context, index) {
                    final item = c.customers[index];
                    return CustomerTile(item: item);
                  },
                ),
              );
            }),
          ),

          // Pagination Bar
          PaginationBar(controller: c),
        ],
      ),
    );
  }
}
