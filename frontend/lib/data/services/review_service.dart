import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/review_model.dart';
import '../mock/mock_data.dart';

class ReviewService {
  final ApiClient _apiClient;

  ReviewService(this._apiClient);

  Future<List<ReviewModel>> getReviews(String productId) async {
    try {
      final response = await _apiClient.get(
        '/reviews',
        queryParameters: {'productId': productId},
      );
      if (response.data is! List) {
        return MockData.mockReviews
            .where((review) => review.productId == productId)
            .toList();
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map(ReviewModel.fromJson).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to load reviews: $e');
      return MockData.mockReviews
          .where((review) => review.productId == productId)
          .toList();
    }
  }

  Future<ReviewModel> createReview({
    required String productId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _apiClient.post(
        '/reviews',
        data: {
          'productId': productId,
          'userName': userName,
          'rating': rating,
          'comment': comment,
        },
      );
      return ReviewModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return ReviewModel(
        id: 'review-${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        userName: userName,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );
    }
  }
}
