import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_auth_handling/modules/customers/customer_controller.dart';

class PaginationBar extends StatelessWidget {
  final CustomerController controller;
  const PaginationBar({super.key, required this.controller});

  Widget _pageButton({
    required int page,
    required int current,
    required VoidCallback onTap,
  }) {
    final bool isActive = (page == current);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.blue.shade200,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            '$page',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Obx(() {
      final currentPage = c.pageNo.value <= 0 ? 1 : c.pageNo.value;
      final total = c.totalPages.value;

      Widget buildButtons(int start, int end, int current, int totalPages) {
        final List<Widget> items = [];
        items.add(
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: current > 1 ? Colors.blue : Colors.grey.shade400,
            ),
            onPressed: current > 1
                ? () => c.fetchPageNumber(current - 1)
                : null,
          ),
        );

        if (start > 1) {
          items.add(
            _pageButton(
              page: 1,
              current: current,
              onTap: () => c.fetchPageNumber(1),
            ),
          );
        }
        if (start > 2) {
          items.add(
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text("...", style: TextStyle(fontSize: 16)),
            ),
          );
        }

        for (var p = start; p <= end; p++) {
          items.add(
            _pageButton(
              page: p,
              current: current,
              onTap: () => c.fetchPageNumber(p),
            ),
          );
        }

        if (end < totalPages) {
          items.add(
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text("...", style: TextStyle(fontSize: 16)),
            ),
          );
          items.add(
            _pageButton(
              page: totalPages,
              current: current,
              onTap: () => c.fetchPageNumber(totalPages),
            ),
          );
        }

        items.add(
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: current < totalPages ? Colors.blue : Colors.grey.shade400,
            ),
            onPressed: current < totalPages
                ? () => c.fetchPageNumber(current + 1)
                : null,
          ),
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items,
        );
      }

      if (total > 0) {
        const int window = 5;
        var start = currentPage - 2;
        if (start < 1) start = 1;
        var end = start + window - 1;
        if (end > total) {
          end = total;
          start = end - window + 1;
          if (start < 1) start = 1;
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: buildButtons(start, end, currentPage, total),
          ),
        );
      }

      final start = (currentPage - 2) > 1 ? (currentPage - 2) : 1;
      final end = start + 4;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: buildButtons(
            start,
            end,
            currentPage,
            c.hasMore.value ? end + 1 : end,
          ),
        ),
      );
    });
  }
}
