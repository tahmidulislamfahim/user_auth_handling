import 'package:get/get.dart';
import 'package:user_auth_handling/data/auth_repository.dart';
import 'package:user_auth_handling/data/customer_repository.dart';

class CustomerController extends GetxController {
  final repo = Get.put(CustomerRepository());
  final auth = Get.find<AuthRepository>();

  final customers = <dynamic>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final pageNo = 1.obs;
  final pageSize = 20;
  final hasMore = true.obs;
  final totalPages = 0.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitial();
  }

  @override
  Future<void> refresh() async {
    await fetchInitial();
  }

  Future<void> fetchInitial() async {
    pageNo.value = 1;
    hasMore.value = true;
    customers.clear();
    await fetchPageNumber(1);
  }

  Future<void> fetchPage() async {
    // Fetch next page and append to existing list (used by infinite scroll)
    if (!hasMore.value) return;
    final nextPage = pageNo.value + 1;
    // If API reported total pages, don't request beyond that
    if (totalPages.value > 0 && nextPage > totalPages.value) {
      hasMore.value = false;
      return;
    }
    isMoreLoading.value = true;

    try {
      final resp = await repo.fetchCustomersWithPageInfo(
        pageNo: nextPage,
        pageSize: pageSize,
        search: searchQuery.value,
      );

      final list = (resp['items'] is List)
          ? List<dynamic>.from(resp['items'])
          : <dynamic>[];
      final pageInfo = resp['pageInfo'] as Map<String, dynamic>?;

      if (pageInfo != null && pageInfo.containsKey('PageCount')) {
        try {
          totalPages.value = int.parse(pageInfo['PageCount'].toString());
        } catch (_) {}
      }

      if (list.isEmpty) {
        hasMore.value = false;
      } else {
        customers.addAll(list);
        // update current page to the page we just loaded
        pageNo.value = nextPage;
        if (list.length < pageSize) hasMore.value = false;
        // If we now know totalPages, ensure hasMore reflects that
        if (totalPages.value > 0 && pageNo.value >= totalPages.value) {
          hasMore.value = false;
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      isMoreLoading.value = false;
    }
  }

  // Fetch a specific page (1-based). Clears current list and replaces with that page.
  Future<void> fetchPageNumber(int page) async {
    if (page < 1) return;
    isLoading.value = true;
    isMoreLoading.value = false;
    customers.clear();

    try {
      final resp = await repo.fetchCustomersWithPageInfo(
        pageNo: page,
        pageSize: pageSize,
        search: searchQuery.value,
      );

      final list = (resp['items'] is List)
          ? List<dynamic>.from(resp['items'])
          : <dynamic>[];
      final pageInfo = resp['pageInfo'] as Map<String, dynamic>?;

      // set current page
      pageNo.value = page;

      if (pageInfo != null && pageInfo.containsKey('PageCount')) {
        try {
          totalPages.value = int.parse(pageInfo['PageCount'].toString());
        } catch (_) {}
      }

      if (list.isEmpty) {
        hasMore.value = false;
      } else {
        customers.addAll(list);
        // If returned a full page, assume there may be more
        hasMore.value = list.length >= pageSize;
        if (totalPages.value > 0) {
          hasMore.value = page < totalPages.value;
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
