import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:user_auth_handling/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const App());
}
