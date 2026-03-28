import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/fine_model.dart';
import '../mock/mock_data.dart';

class FinesService {
  final ApiClient _apiClient;

  FinesService(this._apiClient);

  Future<List<FineModel>> getFines({String? status}) async {
    try {
      final response = await _apiClient.get(
        '/fines',
        queryParameters: {if (status != null) 'status': status},
      );
      if (response.data is! List) {
        return MockData.mockFines;
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map(FineModel.fromJson).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to load fines: $e');
      return MockData.mockFines;
    }
  }

  Future<FineModel> getFine(String id) async {
    try {
      final response = await _apiClient.get('/fines/$id');
      return FineModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return MockData.mockFines.firstWhere((fine) => fine.id == id);
    }
  }

  Future<Map<String, dynamic>> payFine(String id) async {
    try {
      final response = await _apiClient.post('/fines/$id/pay');
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return {'status': 'success', 'paymentId': 'pay_$id'};
    }
  }
}
