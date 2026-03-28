import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BookingTimeSlotsPage extends StatefulWidget {
  final DateTime date;

  const BookingTimeSlotsPage({super.key, required this.date});

  @override
  State<BookingTimeSlotsPage> createState() => _BookingTimeSlotsPageState();
}

class _BookingTimeSlotsPageState extends State<BookingTimeSlotsPage> {
  final List<String> _slots = const [
    '09:00',
    '10:30',
    '12:00',
    '14:30',
    '16:00',
  ];
  String? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('Время'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите слот',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _slots.map((slot) {
                final selected = _selectedSlot == slot;
                return InkWell(
                  onTap: () => setState(() => _selectedSlot = slot),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      slot,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedSlot == null
                    ? null
                    : () => Navigator.of(context).pop(_selectedSlot),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Продолжить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
