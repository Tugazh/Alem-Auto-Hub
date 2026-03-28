import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AIOnboardingPage extends StatelessWidget {
  const AIOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('ИИ Агент — старт'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ваш AI помощник',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Диагностика проблем\n• План обслуживания\n• Советы по уходу\n• Быстрые ответы в дороге',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Начать чат'),
            ),
          ],
        ),
      ),
    );
  }
}
