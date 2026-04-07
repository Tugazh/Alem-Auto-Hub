import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/booking_service.dart';
import 'booking_success_page.dart';

class BookingConfirmPage extends StatefulWidget {
  final String serviceName;
  final String address;
  final DateTime date;
  final String timeSlot;

  const BookingConfirmPage({
    super.key,
    required this.serviceName,
    required this.address,
    required this.date,
    required this.timeSlot,
  });

  @override
  State<BookingConfirmPage> createState() => _BookingConfirmPageState();
}

class _BookingConfirmPageState extends State<BookingConfirmPage> {
  bool _isSubmitting = false;

  Future<void> _confirm() async {
    setState(() => _isSubmitting = true);
    try {
      final BookingService bookingService = ServiceLocator().bookingService;
      // TODO: Обновить под новую структуру API (serviceCenterId, vehicleId, scheduledAt).
      await bookingService.createBooking(
        serviceCenterId: 'temp-service-center-id',
        vehicleId: 'temp-vehicle-id',
        scheduledAt: widget.date,
        notes: '${widget.serviceName} at ${widget.address}, ${widget.timeSlot}',
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BookingSuccessPage()),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('Подтверждение'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfo('Сервис', widget.serviceName),
            _buildInfo('Адрес', widget.address),
            _buildInfo(
              'Дата',
              '${widget.date.day}.${widget.date.month}.${widget.date.year}',
            ),
            _buildInfo('Время', widget.timeSlot),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Стоимость'),
                  Text(
                    '18 000 ₸',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Подтвердить запись'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
