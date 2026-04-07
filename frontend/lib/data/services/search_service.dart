import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/search_models.dart';

class SearchService {
  final ApiClient _apiClient;

  SearchService(this._apiClient);

  Future<SearchResultModel?> search(String query) async {
    try {
      final response = await _apiClient.get(
        '/search',
        queryParameters: {'q': query},
      );
      if (response.data is! Map<String, dynamic>) {
        return null;
      }
      return SearchResultModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Не удалось выполнить поиск: $e');
      return null;
    }
  }
}
