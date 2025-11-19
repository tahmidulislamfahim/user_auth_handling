import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_auth_handling/data/auth_repository.dart';
import 'package:user_auth_handling/routes/app_pages.dart';

class LoginController extends GetxController {
  final username = TextEditingController(text: 'admin@gmail.com');
  final password = TextEditingController(text: 'admin1234');
  final isLoading = false.obs;

  // Company selection: default comId = 1
  final companies = <Map<String, dynamic>>[].obs;
  final selectedComId = 1.obs;

  final auth = Get.put(AuthRepository());

  @override
  void onInit() {
    super.onInit();
    auth.init();
    _loadCompanies();
  }

  void _loadCompanies() async {
    final fetchedCompanies = await auth.fetchCompanies();
    if (fetchedCompanies.isNotEmpty) {
      companies.value = fetchedCompanies;
    } else {
      companies.value = [
        {'id': 1, 'name': 'User ComId1'},
        {'id': 2, 'name': 'Customer ComId2'},
        {'id': 3, 'name': 'Supplier ComId3'},
      ];
    }
    // Ensure default is 1
    if (!companies.any((c) => c['id'] == selectedComId.value)) {
      selectedComId.value = companies.first['id'] as int;
    }
  }

  Future<void> login() async {
    // Prevent login for comId 2 and 3
    if (selectedComId.value != 1) {
      Get.snackbar(
        'Login blocked',
        'Selected id is not allowed to login. Use comId=1.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
      );
      return;
    }

    isLoading.value = true;
    try {
      await auth.login(
        username: username.text.trim(),
        password: password.text.trim(),
        comId: selectedComId.value,
      );
      Get.offAllNamed(AppRoutes.customers);
      Get.snackbar(
        'Success',
        'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Login failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
