import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/expense_model.dart';

class FinanceService {
  final ApiClient _apiClient;

  FinanceService(this._apiClient);

  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final response = await _apiClient.get('/finance/expenses');
      if (response.data is! List) {
        return [];
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map(ExpenseModel.fromJson).toList();
    } catch (e) {
      debugPrint('Не удалось загрузить расходы: $e');
      return [];
    }
  }

  Future<ExpenseModel> createExpense({
    required String title,
    required String category,
    required double amount,
    required DateTime occurredAt,
    String description = '',
  }) async {
    try {
      final response = await _apiClient.post(
        '/finance/expenses',
        data: {
          'title': title,
          'category': category,
          'amount': amount,
          'occurredAt': occurredAt.toIso8601String(),
          'description': description,
        },
      );
      return ExpenseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return ExpenseModel(
        id: 'expense-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        category: category,
        amount: amount,
        occurredAt: occurredAt,
        description: description,
      );
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get('/finance/categories');
      if (response.data is! List) {
        return [];
      }
      return List<String>.from(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<String> exportExpenses() async {
    try {
      final response = await _apiClient.get('/finance/export');
      final data = response.data as Map<String, dynamic>;
      return data['url']?.toString() ?? '';
    } catch (_) {
      return 'https://storage.example.com/export/finance.csv';
    }
  }
}
