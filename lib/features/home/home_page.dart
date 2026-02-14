import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../data/models/car_model.dart';
import '../../data/models/maintenance_model.dart';
import '../car_detail/widgets/car_3d_viewer.dart';
import '../warehouse/warehouse_page.dart';
import '../booking/booking_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const HomePageContent();
  }
}

// Content without bottom navigation
class HomePageContent extends StatefulWidget {
  final Function(CarModel)? onCarTap;

  const HomePageContent({super.key, this.onCarTap});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int _selectedCarIndex = 1; // Middle car is selected
  int _selectedMaintenanceTab = 0; // 0: error, 1: warning, 2: success
  late final PageController _carPageController;
  Timer? _pageChangeDebounce;
  final List<String> _cities = const [
    'Астана',
    'Алматы',
    'Шымкент',
    'Актобе',
    'Караганда',
    'Тараз',
    'Павлодар',
    'Усть-Каменогорск',
    'Костанай',
    'Кызылорда',
    'Атырау',
    'Актау',
  ];
  String _selectedCity = 'Астана';
  final List<String> _notifications = const [
    'Замена масла до 50,000 км',
    'Продлить ОСАГО до 15 мая',
    'Плановое ТО через 12 дней',
  ];

  // Backend integration states
  bool _isLoadingCars = false;
  List<CarModel> _cars = [];
  String? _errorMessage;

  bool _isLoadingMaintenance = false;
  List<MaintenanceModel> _maintenanceItems = [];
  String? _maintenanceError;

  @override
  void initState() {
    super.initState();
    _carPageController = PageController(
      viewportFraction: 0.75,
      initialPage: _selectedCarIndex,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  @override
  void dispose() {
    _pageChangeDebounce?.cancel();
    _carPageController.dispose();
    super.dispose();
  }

  /// Загрузка всех данных
  Future<void> _loadData() async {
    await _loadCars();
    if (_cars.isNotEmpty) {
      await _loadMaintenance();
    }
  }

  /// Загрузка автомобилей из backend
  Future<void> _loadCars() async {
    setState(() {
      _isLoadingCars = true;
      _errorMessage = null;
    });

    try {
      final garageService = ServiceLocator().garageService;
      final cars = await garageService.getGarages();

      setState(() {
        _cars = cars;
        _isLoadingCars = false;
        if (_cars.isNotEmpty && _selectedCarIndex >= _cars.length) {
          _selectedCarIndex = 0;
        }
      });
      if (_cars.isNotEmpty && _carPageController.hasClients) {
        final targetIndex = _selectedCarIndex.clamp(0, _cars.length - 1);
        _carPageController.jumpToPage(targetIndex);
      }
    } catch (e) {
      setState(() {
        _isLoadingCars = false;
        _errorMessage = 'Ошибка загрузки: ${e.toString()}';
      });
      debugPrint('Error loading cars: $e');
    }
  }

  /// Загрузка записей технического обслуживания
  Future<void> _loadMaintenance() async {
    setState(() {
      _isLoadingMaintenance = true;
      _maintenanceError = null;
    });

    try {
      // Ждем пока загрузятся машины, чтобы получить garageId
      if (_cars.isEmpty) {
        setState(() {
          _isLoadingMaintenance = false;
        });
        return;
      }

      final maintenanceService = ServiceLocator().maintenanceService;
      // Используем ID первой машины
      final items = await maintenanceService.getMaintenanceList(
        garageId: _cars.first.id,
      );

      setState(() {
        _maintenanceItems = items;
        _isLoadingMaintenance = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMaintenance = false;
        _maintenanceError = 'Ошибка загрузки ТО: ${e.toString()}';
      });
      debugPrint('Error loading maintenance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildQuickActions(),
                const SizedBox(height: 16),
                _buildCarCarousel(),
                const SizedBox(height: 16),
                _buildMaintenancePlan(),
                const SizedBox(height: 16),
                _buildAlemAutoBox(),
                const SizedBox(height: 80), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Привет, Nurtugan!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              _buildCitySelector(),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _showNotificationsSheet,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Штрафы',
                Icons.description_outlined,
                () => _openQuickAction('Штрафы'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Расход',
                Icons.local_gas_station_outlined,
                () => _openQuickAction('Расход'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Запись',
                Icons.calendar_today_outlined,
                () => _openQuickAction('Запись'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Склад',
                Icons.inventory_2_outlined,
                () => _openQuickAction('Склад'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCitySelector() {
    return InkWell(
      onTap: _showCityPicker,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_selectedCity, Казахстан',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }

  void _showCityPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Выберите город',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ..._cities.map(
              (city) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('$city, Казахстан'),
                trailing: city == _selectedCity
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedCity = city;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Уведомления',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._notifications.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _openQuickAction(String title) {
    if (title == 'Запись') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const BookingPage()));
      return;
    }

    if (title == 'Склад') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const WarehousePage()));
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => _QuickActionPage(title: title)),
    );
  }

  Widget _buildCarCarousel() {
    // Loading state
    if (_isLoadingCars) {
      return Column(
        children: [
          SizedBox(
            height: 340,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Загрузка автомобилей...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Column(
        children: [
          Container(
            height: 340,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadCars,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      );
    }

    // Empty state
    if (_cars.isEmpty) {
      return Column(
        children: [
          Container(
            height: 340,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 64,
                      color: AppColors.iconGray,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Нет автомобилей',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Добавьте свой первый автомобиль',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      );
    }

    // Success state with real data
    return Column(
      children: [
        SizedBox(
          height: 340,
          child: Stack(
            children: [
              PageView.builder(
                controller: _carPageController,
                onPageChanged: (index) {
                  _pageChangeDebounce?.cancel();
                  _pageChangeDebounce = Timer(
                    const Duration(milliseconds: 350),
                    () {
                      if (!mounted) return;
                      if (_selectedCarIndex == index) return;
                      setState(() {
                        _selectedCarIndex = index;
                      });
                    },
                  );
                },
                itemCount: _cars.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedCarIndex;
                  final isRouteActive =
                      ModalRoute.of(context)?.isCurrent ?? true;
                  final car = _cars[index];

                  return Transform.scale(
                    scale: isSelected ? 1.0 : 0.88,
                    child: Opacity(
                      opacity: isSelected ? 1.0 : 0.4,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    car.name,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (widget.onCarTap != null) {
                                      widget.onCarTap!(car);
                                    }
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.background.withValues(
                                    alpha: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: isSelected && isRouteActive
                                    ? Car3DViewer(
                                        key: ValueKey('home_3d_${car.id}'),
                                        model3dUrl: car.model3dUrl,
                                        fallbackImageUrl: car.imageUrl,
                                        carName: car.name,
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.directions_car,
                                          size: 80,
                                          color: AppColors.iconGray.withValues(
                                            alpha: 0.15,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (car.mileage != null)
                                  Text(
                                    '${car.mileage} км',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                if (car.mileage == null) const SizedBox(),
                                Text(
                                  car.plateNumber ?? '',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // Красная кнопка с точками на всю ширину
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _cars.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                width: _selectedCarIndex == index ? 24 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _selectedCarIndex == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenancePlan() {
    // Loading state
    if (_isLoadingMaintenance) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'План обслуживания',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ],
      );
    }

    // Error state
    if (_maintenanceError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'План обслуживания',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 40),
                const SizedBox(height: 8),
                Text(
                  _maintenanceError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Фильтруем данные по статусам
    final overdueItems = _maintenanceItems
        .where((item) => item.status == MaintenanceStatus.overdue)
        .toList();
    final pendingItems = _maintenanceItems
        .where((item) => item.status == MaintenanceStatus.pending)
        .toList();
    final completedItems = _maintenanceItems
        .where((item) => item.status == MaintenanceStatus.completed)
        .toList();

    final statusGroups = [overdueItems, pendingItems, completedItems];
    final currentItems = statusGroups[_selectedMaintenanceTab];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'План обслуживания',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        // Табы с иконками
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final colors = [
                const Color(0xFFFF3B30), // красный для overdue
                const Color(0xFFFFCC00), // желтый для pending
                const Color(0xFF34C759), // зеленый для completed
              ];
              final icons = [
                'assets/icons/status_error.svg',
                'assets/icons/status_warning.svg',
                'assets/icons/status_success.svg',
              ];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMaintenanceTab = index;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _selectedMaintenanceTab == index
                        ? colors[index]
                        : AppColors.iconGray.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      icons[index],
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        // Empty state для текущей вкладки
        if (currentItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Нет записей',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        // Список записей ТО
        if (currentItems.isNotEmpty)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Column(
              key: ValueKey<int>(_selectedMaintenanceTab),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: currentItems.take(2).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getMaintenanceTypeLabel(item.type),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatMaintenanceDate(item),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.iconGray,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String _getMaintenanceTypeLabel(String type) {
    switch (type) {
      case 'oil_change':
        return 'Замена масла';
      case 'tire_rotation':
        return 'Ротация шин';
      case 'brake_inspection':
        return 'Проверка тормозов';
      case 'engine_check':
        return 'Проверка двигателя';
      case 'general_service':
        return 'Общее обслуживание';
      case 'other':
        return 'Другое';
      default:
        return type;
    }
  }

  String _formatMaintenanceDate(MaintenanceModel item) {
    if (item.status == MaintenanceStatus.completed &&
        item.completedDate != null) {
      return 'Завершено ${_formatDate(item.completedDate!)}';
    }
    return 'Запланировано на ${_formatDate(item.scheduledDate)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildAlemAutoBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ALEM AUTO BOX',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Полная диагностика авто',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Комплексная диагностика с автоматической записью в сервисную книжку',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Цена: от 15 000 ₸',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Время: ~2 часа',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Записаться',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionPage extends StatelessWidget {
  final String title;

  const _QuickActionPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '$title — страница в разработке',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
