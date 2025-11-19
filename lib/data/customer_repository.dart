import 'api_provider.dart';
import 'package:get/get.dart';
import 'auth_repository.dart';

class CustomerRepository extends GetxService {
  final ApiProvider _api = ApiProvider();
  final AuthRepository auth = Get.find();

  Future<List<dynamic>> fetchCustomers({
    required int pageNo,
    int pageSize = 20,
    String search = '',
    String sortBy = 'Balance',
  }) async {
    final endpoint =
        'GetCustomerList?$search&pageNo=$pageNo&pageSize=$pageSize&SortyBy=$sortBy';
    final headers = auth.authHeaders;
    final result = await _api.get(
      endpoint,
      headers: headers.isEmpty ? null : headers,
    );

    if (result == null) return [];

    // Helper: recursively search for the first List value inside nested maps
    List<dynamic> extractList(dynamic r) {
      if (r is List) return List<dynamic>.from(r);
      if (r is Map) {
        for (final v in r.values) {
          final found = extractList(v);
          if (found.isNotEmpty) return found;
        }
      }
      return <dynamic>[];
    }

    if (result is List) return List<dynamic>.from(result);

    if (result is Map) {
      // Common top-level keys
      if (result.containsKey('data')) {
        return List<dynamic>.from(result['data'] ?? []);
      }
      if (result.containsKey('Data')) {
        return List<dynamic>.from(result['Data'] ?? []);
      }
      if (result.containsKey('list')) {
        return List<dynamic>.from(result['list'] ?? []);
      }

      // Try to find a nested list in the response
      final found = extractList(result);

      if (found.isNotEmpty) return found;

      // No list found — return empty to avoid wrapping entire map as single item
      return <dynamic>[];
    }

    return <dynamic>[];
  }

  /// Returns both the list of items and any pageInfo map returned by the API.
  Future<Map<String, dynamic>> fetchCustomersWithPageInfo({
    required int pageNo,
    int pageSize = 20,
    String search = '',
    String sortBy = 'Balance',
  }) async {
    final endpoint =
        'GetCustomerList?$search&pageNo=$pageNo&pageSize=$pageSize&SortyBy=$sortBy';
    final headers = auth.authHeaders;
    final result = await _api.get(
      endpoint,
      headers: headers.isEmpty ? null : headers,
    );

    if (result == null) return {'items': <dynamic>[], 'pageInfo': null};

    Map<String, dynamic>? pageInfo;
    List<dynamic> items = <dynamic>[];

    if (result is Map) {
      // Try common keys
      if (result.containsKey('PageInfo')) {
        pageInfo = (result['PageInfo'] is Map)
            ? Map<String, dynamic>.from(result['PageInfo'])
            : null;
      }
      if (result.containsKey('CustomerList')) {
        items = List<dynamic>.from(result['CustomerList'] ?? []);
      }
    }

    // Fallback: try to find a nested list
    if (items.isEmpty) {
      List<dynamic> extractList(dynamic r) {
        if (r is List) return List<dynamic>.from(r);
        if (r is Map) {
          for (final v in r.values) {
            final found = extractList(v);
            if (found.isNotEmpty) return found;
          }
        }
        return <dynamic>[];
      }

      if (result is List) {
        items = List<dynamic>.from(result);
      } else {
        items = extractList(result);
      }
    }

    return {'items': items, 'pageInfo': pageInfo};
  }
}
