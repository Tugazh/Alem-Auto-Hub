import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/market_product_model.dart';

class WishlistPage extends StatelessWidget {
  final List<MarketProductModel> items;

  const WishlistPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('Избранное'),
      ),
      body: items.isEmpty
          ? const Center(child: Text('Избранных товаров нет'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: product.images.isNotEmpty
                            ? Image.network(product.images.first)
                            : const Icon(Icons.favorite),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(product.title)),
                      Text('${product.price.toStringAsFixed(0)} ₸'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
