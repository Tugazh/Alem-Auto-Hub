import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/main_bottom_nav.dart';
import '../main/main_screen.dart';
import '../market/market_page.dart';
import '../social/social_page.dart';

class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key});

  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  final List<_WarehouseItem> _items = [
    _WarehouseItem(
      title: 'Зимняя шина\nна Toyota Camry',
      price: 45500,
      imageUrl:
          'https://images.unsplash.com/photo-1526724038726-3007ffb8025f?auto=format&fit=crop&w=400&q=80',
    ),
    _WarehouseItem(
      title: 'Varta Blue Dynamic E11\n74 Ач (правый+)',
      price: 90000,
      imageUrl:
          'https://images.unsplash.com/photo-1614955969241-73dd1ef86c57?auto=format&fit=crop&w=400&q=80',
    ),
    _WarehouseItem(
      title: 'Liqui Moly 5W-40\nМасло моторное,\nсинтетическое, 4 л',
      price: 28600,
      imageUrl:
          'https://images.unsplash.com/photo-1583211893325-4cc98f4a56ea?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  late final List<int> _quantities = List<int>.from([2, 1, 1]);

  int get _total {
    var sum = 0;
    for (var i = 0; i < _items.length; i++) {
      sum += _items[i].price * _quantities[i];
    }
    return sum;
  }

  int get _discount => 3000;

  void _updateQuantity(int index, int delta) {
    setState(() {
      final next = _quantities[index] + delta;
      _quantities[index] = next.clamp(1, 99);
    });
  }

  void _handleBottomNavTap(int index) {
    if (index == 3) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const MarketPage()));
      return;
    }
    if (index == 4) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SocialPage()));
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen(initialTabIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text('Склад'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              itemBuilder: (context, index) => _buildItemCard(index),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: _items.length,
            ),
          ),
          _buildSummary(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Добавить в маркет',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 0,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = _items[index];
    final qty = _quantities[index];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 110,
              height: 90,
              color: AppColors.background,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.textSecondary,
                      size: 28,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.iconGray,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ')} ₸',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQtyButton(
                      icon: Icons.remove,
                      onTap: () => _updateQuantity(index, -1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      qty.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildQtyButton(
                      icon: Icons.add,
                      onTap: () => _updateQuantity(index, 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Общая стоимость', _total),
          const SizedBox(height: 6),
          _buildSummaryRow('Скидка', _discount),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ' ',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          '$formatted ₸',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _WarehouseItem {
  final String title;
  final int price;
  final String imageUrl;

  const _WarehouseItem({
    required this.title,
    required this.price,
    required this.imageUrl,
  });
}
