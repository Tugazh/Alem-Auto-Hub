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
      imageUrl: 'sample1',
    ),
    _WarehouseItem(
      title: 'Varta Blue Dynamic E11\n74 Ач (правый+)',
      price: 90000,
      imageUrl: 'sample2',
    ),
    _WarehouseItem(
      title: 'Liqui Moly 5W-40\nМасло моторное',
      price: 28600,
      imageUrl: 'sample3',
    ),
    _WarehouseItem(
      title: 'Тормозные колодки\nПередние',
      price: 15400,
      imageUrl: 'sample4',
    ),
    _WarehouseItem(
      title: 'Воздушный фильтр',
      price: 4500,
      imageUrl: 'sample5',
    ),
    _WarehouseItem(
      title: 'Масляный фильтр',
      price: 3200,
      imageUrl: 'sample6',
    ),
    _WarehouseItem(
      title: 'Свечи зажигания\nКомплект',
      price: 12000,
      imageUrl: 'sample7',
    ),
    _WarehouseItem(
      title: 'Антифриз G12+',
      price: 8500,
      imageUrl: 'sample8',
    ),
    _WarehouseItem(
      title: 'Летняя шина 17"',
      price: 42000,
      imageUrl: 'sample9',
    ),
  ];

  late final List<int> _quantities =
      List<int>.from([2, 1, 1, 4, 2, 2, 6, 1, 4]);

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
        title: const Text('Склад',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
            child: SizedBox(
              width: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: AppColors.textPrimary),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left vertical icon bar
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      _navIcon(Icons.directions_car, active: true),
                      const SizedBox(height: 12),
                      _navIcon(Icons.build_circle_outlined),
                      const SizedBox(height: 12),
                      _navIcon(Icons.handshake_outlined),
                      const SizedBox(height: 12),
                      _navIcon(Icons.bolt),
                      const SizedBox(height: 12),
                      _navIcon(Icons.local_shipping_outlined),
                      const SizedBox(height: 12),
                      _navIcon(Icons.invert_colors),
                      const SizedBox(height: 12),
                      _navIcon(Icons.more_horiz),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Grid area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        // Category chip
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text('Двигатель и обслуживание',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Grid of items
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.only(
                                bottom: 100), // padding for the bottom button
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _items.length,
                            itemBuilder: (context, index) =>
                                _buildGridCard(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom button hovering over everything
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Добавить в маркет',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 0,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _navIcon(IconData icon, {bool active = false}) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon,
          color: active ? AppColors.textPrimary : Colors.white54, size: 20),
    );
  }

  Widget _buildGridCard(int index) {
    final item = _items[index];
    // Pick a gradient by index to simulate categories
    final gradients = [
      RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          const Color(0xFF5A2012).withOpacity(0.9),
          const Color(0xFF1E1412),
        ],
      ),
      RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          const Color(0xFF1E3A20).withOpacity(0.9),
          const Color(0xFF101912),
        ],
      ),
      RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          const Color(0xFF1A1A3A).withOpacity(0.9),
          const Color(0xFF12121A),
        ],
      ),
      RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          const Color(0xFF3D3512).withOpacity(0.9),
          const Color(0xFF1E1C12),
        ],
      ),
      RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          const Color(0xFF381532).withOpacity(0.9),
          const Color(0xFF1C101A),
        ],
      ),
    ];
    final bgGradient = gradients[index % gradients.length];
    final sampleAsset = 'assets/images/samples/sample${(index % 9) + 1}.png';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => WarehouseDetailPage(item: item))),
      child: Container(
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Stack(
          children: [
            // Centered image
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  sampleAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white24,
                      size: 28),
                ),
              ),
            ),
            // small wrench icon bottom-left
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.build, size: 14, color: Colors.white70),
              ),
            ),
            // quantity badge bottom-right
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${_quantities[index]} x',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ),
            // small close icon top-right
            Positioned(
              right: 6,
              top: 6,
              child:
                  const Icon(Icons.close, size: 16, color: AppColors.iconGray),
            ),
          ],
        ),
      ),
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

class WarehouseDetailPage extends StatelessWidget {
  final _WarehouseItem item;

  const WarehouseDetailPage({super.key, required this.item});

  Color _priceColor() {
    // simple heuristic for example: cheap -> green, medium -> yellow, expensive -> red
    if (item.price < 50000) return const Color(0xFF1B7A3A);
    if (item.price < 200000) return const Color(0xFFF1C40F);
    return const Color(0xFFE74C3C);
  }

  @override
  Widget build(BuildContext context) {
    final formatted = item.price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
        );

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top image area
            Container(
              width: double.infinity,
              height: 280,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Color(0xFF2A2A3A),
                    Color(0xFF101015),
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Image.asset(
                    item.imageUrl.startsWith('sample')
                        ? 'assets/images/samples/${item.imageUrl}.png'
                        : 'assets/images/samples/sample1.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.white24),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Text(item.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('Кузов и внешний вид',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _priceColor(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$formatted ₸',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Описание:',
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text(
                      'Описание детали и условия продажи. Здесь показывается дополнительная информация о совместимости, состоянии и доставке.',
                      style: TextStyle(color: Colors.white60)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Добавить в маркет',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
