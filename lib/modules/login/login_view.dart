import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_auth_handling/modules/login/login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LoginController());
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: c.username,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: c.password,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            // Company selector
            Obx(() {
              final list = c.companies;
              if (list.isEmpty) {
                return const SizedBox.shrink();
              }
              return DropdownButtonFormField<int>(
                initialValue: c.selectedComId.value,
                decoration: const InputDecoration(
                  labelText: 'ComId',
                  prefixIcon: Icon(Icons.business),
                ),
                items: list
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e['id'] as int,
                        child: Text(
                          e['name']?.toString() ?? e['id'].toString(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) c.selectedComId.value = v;
                },
              );
            }),
            const SizedBox(height: 20),
            Obx(() {
              final disabled = c.isLoading.value || c.selectedComId.value != 1;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: disabled ? null : c.login,
                  child: c.isLoading.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
              );
            }),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Info',
                  content: const Text(
                    'Use admin@gmail.com / admin1234 (comId=1)',
                  ),
                );
              },
              child: const Text('Need help?'),
            ),
          ],
        ),
      ),
    );
  }
}
