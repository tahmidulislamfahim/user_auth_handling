import 'dart:convert';
import 'package:get/get.dart';
import 'api_provider.dart';
import 'package:get_storage/get_storage.dart';

class AuthRepository extends GetxService {
  final ApiProvider _api = ApiProvider();
  final box = GetStorage();
  final tokenKey = 'auth_token';

  RxString token = ''.obs;

  Future<AuthRepository> init() async {
    token.value = box.read(tokenKey) ?? '';
    return this;
  }

  Map<String, String> get authHeaders {
    if (token.isNotEmpty) {
      return {'Authorization': 'Bearer ${token.value}'};
    }
    return {};
  }

  Future<void> login({
    required String username,
    required String password,
    required int comId,
  }) async {
    final endpoint = 'LogIn?UserName=$username&Password=$password&ComId=$comId';
    try {
      final result = await _api.get(endpoint);

      if (result == null) {
        throw Exception('Empty response from server');
      }

      if (result is Map && result.containsKey('Token')) {
        token.value = result['Token'].toString();
        await box.write(tokenKey, token.value);
      } else if (result is String) {
        token.value = result;
        await box.write(tokenKey, token.value);
      } else {
        token.value = '';
      }

      await box.write('last_login', jsonEncode(result));
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch list of companies (id + name) for login selection.
  /// Returns a list of maps: `{ 'id': int, 'name': String }`.
  Future<List<Map<String, dynamic>>> fetchCompanies() async {
    try {
      final result = await _api.get('GetCompanyList');
      if (result == null) return [];

      List<dynamic> extractList(dynamic r) {
        if (r is List) return List<dynamic>.from(r);
        if (r is Map) {
          // Common keys
          if (r.containsKey('CompanyList')) {
            return List<dynamic>.from(r['CompanyList'] ?? []);
          }
          if (r.containsKey('data')) return List<dynamic>.from(r['data'] ?? []);
          if (r.containsKey('Data')) return List<dynamic>.from(r['Data'] ?? []);
          for (final v in r.values) {
            final found = extractList(v);
            if (found.isNotEmpty) return found;
          }
        }
        return <dynamic>[];
      }

      final rawItems = extractList(result);
      final List<Map<String, dynamic>> out = [];
      for (final it in rawItems) {
        if (it is Map) {
          int? id;
          String? name;
          if (it.containsKey('ComId')) {
            id = int.tryParse(it['ComId']?.toString() ?? '');
          }
          if (id == null && it.containsKey('ComID')) {
            id = int.tryParse(it['ComID']?.toString() ?? '');
          }
          if (id == null && it.containsKey('Id')) {
            id = int.tryParse(it['Id']?.toString() ?? '');
          }

          if (it.containsKey('CompanyName')) {
            name = it['CompanyName']?.toString();
          }
          if (name == null && it.containsKey('Name')) {
            name = it['Name']?.toString();
          }
          if (name == null && it.containsKey('ComName')) {
            name = it['ComName']?.toString();
          }

          if (id != null) {
            out.add({'id': id, 'name': name ?? 'Company $id'});
          }
        }
      }
      return out;
    } catch (e) {
      return [];
    }
  }

  void logout() {
    token.value = '';
    box.remove(tokenKey);
  }
}
