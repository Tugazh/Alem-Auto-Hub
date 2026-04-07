import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/market_product_model.dart';
import '../../data/models/review_model.dart';

class ReviewsPage extends StatefulWidget {
  final MarketProductModel product;

  const ReviewsPage({super.key, required this.product});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late Future<List<ReviewModel>> _future;
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _future = ServiceLocator().reviewService.getReviews(widget.product.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ServiceLocator().reviewService.createReview(
      productId: widget.product.id,
      userName: 'Нуртуган',
      rating: _rating,
      comment: _commentController.text,
    );
    if (!mounted) return;
    setState(() {
      _commentController.clear();
      _future = ServiceLocator().reviewService.getReviews(widget.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('Отзывы'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<ReviewModel>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final reviews = snapshot.data ?? [];
                  if (reviews.isEmpty) {
                    return const Center(child: Text('Отзывов пока нет'));
                  }
                  return ListView.separated(
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  review.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text('Оценка: ${review.rating}'),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(review.comment),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildReviewForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                icon: Icon(
                  value <= _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => setState(() => _rating = value),
              );
            }),
          ),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Ваш отзыв',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Отправить'),
            ),
          ),
        ],
      ),
    );
  }
}
