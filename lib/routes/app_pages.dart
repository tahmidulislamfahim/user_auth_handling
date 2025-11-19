import 'package:get/get.dart';
import 'package:user_auth_handling/modules/login/login_view.dart';
import 'package:user_auth_handling/modules/customers/customer_list_view.dart';

class AppRoutes {
  static const login = '/login';
  static const customers = '/customers';
}

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.customers, page: () => const CustomerListView()),
  ];
}
