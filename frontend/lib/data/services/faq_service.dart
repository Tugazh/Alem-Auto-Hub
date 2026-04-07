import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/faq_model.dart';

class FAQService {
  final ApiClient _apiClient;

  FAQService(this._apiClient);

  Future<List<FAQItemModel>> getFaq() async {
    try {
      final response = await _apiClient.get('/faq');
      if (response.data is! List) {
        return [];
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => FAQItemModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Не удалось загрузить FAQ: $e');
      return [];
    }
  }
}
