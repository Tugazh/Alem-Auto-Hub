import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cart_item_model.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItemModel> items;

  const CheckoutPage({super.key, required this.items});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  double get _total => widget.items.fold(0, (sum, item) => sum + item.total);

  Future<void> _submitOrder() async {
    setState(() => _isSubmitting = true);
    try {
      await ServiceLocator().orderService.createOrder(items: widget.items);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
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
        title: const Text('Оформление заказа'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            _submitOrder();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          return Row(
            children: [
              ElevatedButton(
                onPressed: _isSubmitting ? null : details.onStepContinue,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_currentStep == 3 ? 'Оплатить' : 'Далее'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: details.onStepCancel,
                child: const Text('Назад'),
              ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Корзина'),
            content: Text('Товаров: ${widget.items.length}'),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Адрес доставки'),
            content: const Text('Алматы, пр. Абая 150'),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Способ доставки'),
            content: const Text('Курьер, 2-3 дня'),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Оплата'),
            content: Text('К оплате: ${_total.toStringAsFixed(0)} ₸'),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }
}
