import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../data/models/market_product_model.dart';
import '../../shared/widgets/states/empty_state.dart';
import '../../shared/widgets/states/error_state.dart';
import '../../shared/widgets/states/loading_state.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Return to home - we'll handle this by changing main tab
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Маркет'),
        actions: [
          IconButton(icon: const Icon(Icons.receipt_long), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ProductsTab(),
                ServicesTab(),
                AnnouncementsTab(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(icon: Icon(Icons.shopping_bag), text: 'Товары'),
          Tab(icon: Icon(Icons.build), text: 'Услуги'),
          Tab(icon: Icon(Icons.description), text: 'Объявления'),
        ],
      ),
    );
  }
}

// Products Tab
class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  bool _isLoading = false;
  List<MarketProductModel> _products = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final marketService = ServiceLocator().marketService;
      final products = await marketService.getProducts();

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Ошибка загрузки: ${e.toString()}';
      });
      debugPrint('Error loading products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategories(),
            const SizedBox(height: 16),
            _buildMoreCategoriesButton(),
            const SizedBox(height: 24),
            _buildProductContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContent() {
    // Loading state
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LoadingState(message: 'Загрузка товаров...'),
      );
    }

    // Error state
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _loadProducts);
    }

    // Empty state
    if (_products.isEmpty) {
      return const EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'Нет товаров',
        message: 'Попробуйте изменить фильтры или зайдите позже',
      );
    }

    // Success state with real data
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(MarketProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Center(
              child: product.images.isNotEmpty
                  ? Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.shopping_bag,
                          size: 48,
                          color: AppColors.iconGray,
                        );
                      },
                    )
                  : const Icon(
                      Icons.shopping_bag,
                      size: 48,
                      color: AppColors.iconGray,
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '${product.price.toStringAsFixed(0)} ₸',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${product.viewCount} просмотров',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': '🔨', 'label': 'Инструменты'},
      {'icon': '🚗', 'label': 'Транспорт'},
      {'icon': '🔧', 'label': 'Запчасти'},
      {'icon': '🛞', 'label': 'Шины'},
      {'icon': '🛢️', 'label': 'Масла и\nжидкости'},
      {'icon': '🔋', 'label': 'Аккумуляторы'},
      {'icon': '💿', 'label': 'Диски'},
      {'icon': '🎨', 'label': 'Аксессуары'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryItem(
          categories[index]['icon']!,
          categories[index]['label']!,
        );
      },
    );
  }

  Widget _buildCategoryItem(String icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreCategoriesButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Больше категорий'),
      ),
    );
  }
}

// Services Tab
class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            const Text(
              'Авторисованные сервисы',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildServiceCategories(),
            const SizedBox(height: 16),
            _buildMoreServicesButton(),
            const SizedBox(height: 24),
            _buildServiceCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Поиск услуг',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tune),
        ),
      ],
    );
  }

  Widget _buildServiceCategories() {
    final categories = [
      {'icon': '🔧', 'label': 'Автосервис'},
      {'icon': '🧼', 'label': 'Автомойка'},
      {'icon': '🛢️', 'label': 'Пункт замены\nмасла'},
      {'icon': '🛡️', 'label': 'Авто-\nстрахование'},
      {'icon': '🔍', 'label': 'ТО'},
      {'icon': '🧽', 'label': 'Детейлинг'},
      {'icon': '🔩', 'label': 'Установка доп.\nоборудования'},
      {'icon': '🔧', 'label': 'Запчасти и\nрасходники'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryItem(
          categories[index]['icon']!,
          categories[index]['label']!,
        );
      },
    );
  }

  Widget _buildCategoryItem(String icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreServicesButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Другие автоуслуги'),
      ),
    );
  }

  Widget _buildServiceCards() {
    final services = [
      {
        'name': 'Химчистка салона',
        'address': 'Адрес',
        'rating': '4.8',
        'reviews': '(234)',
        'image': '🧼',
      },
      {
        'name': 'Автострахование',
        'address': 'Адрес',
        'rating': '4.8',
        'reviews': '(234)',
        'image': '🛡️',
      },
      {
        'name': 'Замена масла',
        'address': 'Адрес',
        'rating': '4.8',
        'reviews': '(234)',
        'image': '🛢️',
      },
      {
        'name': 'Детейлинг',
        'address': 'Адрес',
        'rating': '4.8',
        'reviews': '(234)',
        'image': '✨',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(services[index]);
      },
    );
  }

  Widget _buildServiceCard(Map<String, String> service) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 104,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                service['image']!,
                style: const TextStyle(fontSize: 44),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['name']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['address']!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.warning, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${service['rating']} ${service['reviews']}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Announcements Tab
class AnnouncementsTab extends StatelessWidget {
  const AnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [_buildAnnouncementGrid()]),
      ),
    );
  }

  Widget _buildAnnouncementGrid() {
    final announcements = [
      {
        'title': 'Зимняя шина',
        'price': '45 500 ₸',
        'date': '13.06.25',
        'location': 'г. Астана',
        'image': '🛞',
      },
      {
        'title': 'Зимняя шина',
        'price': '45 500 ₸',
        'date': '13.06.25',
        'location': 'г. Астана',
        'image': '🛞',
      },
      {
        'title': 'Зимняя шина',
        'price': '45 500 ₸',
        'date': '13.06.25',
        'location': 'г. Астана',
        'image': '🛞',
      },
      {
        'title': 'Зимняя шина',
        'price': '45 500 ₸',
        'date': '13.06.25',
        'location': 'г. Астана',
        'image': '🛞',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        return _buildAnnouncementCard(announcements[index]);
      },
    );
  }

  Widget _buildAnnouncementCard(Map<String, String> announcement) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                announcement['image']!,
                style: const TextStyle(fontSize: 64),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  announcement['price']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${announcement['date']}     ${announcement['location']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
