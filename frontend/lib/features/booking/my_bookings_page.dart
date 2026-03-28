import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/booking_model.dart';
import 'booking_calendar_page.dart';
import 'booking_time_slots_page.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late Future<List<BookingModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ServiceLocator().bookingService.getBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('Мои записи'),
      ),
      body: FutureBuilder<List<BookingModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('Записей пока нет'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${booking.date.day}.${booking.date.month}.${booking.date.year}',
                        ),
                        const SizedBox(width: 12),
                        Text(booking.timeSlot),
                        const Spacer(),
                        Text(
                          booking.status == 'completed'
                              ? 'Завершено'
                              : booking.status == 'cancelled'
                              ? 'Отменено'
                              : 'Предстоит',
                          style: TextStyle(
                            color: booking.status == 'completed'
                                ? AppColors.success
                                : booking.status == 'cancelled'
                                ? AppColors.error
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: booking.status == 'upcoming'
                                ? () async {
                                    final navigator = Navigator.of(context);
                                    final date = await navigator.push<DateTime>(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const BookingCalendarPage(),
                                      ),
                                    );
                                    if (!mounted || date == null) return;
                                    final slot = await navigator.push<String>(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            BookingTimeSlotsPage(date: date),
                                      ),
                                    );
                                    if (!mounted || slot == null) return;
                                    await ServiceLocator().bookingService
                                        .rescheduleBooking(
                                          id: booking.id,
                                          date: date,
                                          timeSlot: slot,
                                        );
                                    if (!mounted) return;
                                    setState(() {
                                      _future = ServiceLocator().bookingService
                                          .getBookings();
                                    });
                                  }
                                : null,
                            child: const Text('Перенести'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: booking.status == 'upcoming'
                                ? () async {
                                    await ServiceLocator().bookingService
                                        .cancelBooking(booking.id);
                                    if (!mounted) return;
                                    setState(() {
                                      _future = ServiceLocator().bookingService
                                          .getBookings();
                                    });
                                  }
                                : null,
                            child: const Text('Отменить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
