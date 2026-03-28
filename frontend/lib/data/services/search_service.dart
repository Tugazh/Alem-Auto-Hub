import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/search_models.dart';
import '../mock/mock_data.dart';

class SearchService {
  final ApiClient _apiClient;

  SearchService(this._apiClient);

  Future<SearchResultModel> search(String query) async {
    try {
      final response = await _apiClient.get(
        '/search',
        queryParameters: {'q': query},
      );
      if (response.data is! Map<String, dynamic>) {
        return _fallbackResult(query);
      }
      return SearchResultModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ Failed to search: $e, using mock data');
      return _fallbackResult(query);
    }
  }

  SearchResultModel _fallbackResult(String query) {
    return MockData.mockSearchResult.copyWith(query: query);
  }
}
