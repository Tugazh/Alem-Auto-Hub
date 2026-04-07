import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/warehouse_part_model.dart';
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
  List<WarehousePartModel> _items = [];
  late final Map<String, int> _quantities = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWarehouseParts();
  }

  Future<void> _loadWarehouseParts() async {
    setState(() => _isLoading = true);

    try {
      final parts = await ServiceLocator().warehouseService.getParts(
        inStock: true,
        limit: 20,
      );

      setState(() {
        _items = parts;
        // Инициализируем количество для каждой запчасти
        for (var part in parts) {
          _quantities[part.id] = 1;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load warehouse parts: $e');
      setState(() => _isLoading = false);
    }
  }

  int get _total {
    double sum = 0;
    for (var i = 0; i < _items.length; i++) {
      final price = _items[i].price ?? 0;
      final qty = _quantities[_items[i].id] ?? 1;
      sum += price * qty;
    }
    return sum.round();
  }

  int get _discount => 3000;

  void _updateQuantity(String id, int delta) {
    setState(() {
      final current = _quantities[id] ?? 1;
      final next = current + delta;
      _quantities[id] = next.clamp(1, 99);
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Склад пуст',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавьте запчасти в склад',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    itemBuilder: (context, index) => _buildItemCard(index),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
    final qty = _quantities[item.id] ?? 1;

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
              child: Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
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
                        item.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: 4),
                Text(
                  item.partNumber,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.priceFormatted,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQtyButton(
                      icon: Icons.remove,
                      onTap: () => _updateQuantity(item.id, -1),
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
                      onTap: () => _updateQuantity(item.id, 1),
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
