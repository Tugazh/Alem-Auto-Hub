import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/faq_model.dart';
import '../mock/mock_data.dart';

class FAQService {
  final ApiClient _apiClient;

  FAQService(this._apiClient);

  Future<List<FAQItemModel>> getFaq() async {
    try {
      final response = await _apiClient.get('/faq');
      if (response.data is! List) {
        return MockData.mockFaqItems;
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => FAQItemModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to load FAQ: $e, using mock data');
      return MockData.mockFaqItems;
    }
  }
}
