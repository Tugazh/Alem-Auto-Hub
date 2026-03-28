import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_data.dart';

class AIHistoryPage extends StatelessWidget {
  const AIHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = MockData.mockChatMessages;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('История диалогов'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = history[index];
          final role = entry['role']?.toString() ?? 'assistant';
          final content = entry['content']?.toString() ?? '';
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: role == 'user' ? AppColors.surface : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role == 'user' ? 'Вы' : 'AI',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(content),
              ],
            ),
          );
        },
      ),
    );
  }
}
