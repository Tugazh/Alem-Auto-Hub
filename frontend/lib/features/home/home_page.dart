import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../data/models/car_model.dart';
import '../../data/models/maintenance_model.dart';
import '../car_detail/widgets/car_3d_viewer.dart';
import '../warehouse/warehouse_page.dart';
import '../booking/booking_page.dart';
import '../../shared/widgets/states/empty_state.dart';
import '../../shared/widgets/states/error_state.dart';
import '../../shared/widgets/states/loading_state.dart';

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

class _HomePageContentState extends State<HomePageContent>
    with TickerProviderStateMixin {
  int _selectedCarIndex = 1; // Middle car is selected
  int _selectedMaintenanceTab = 0; // 0: error, 1: warning, 2: success
  late final PageController _carPageController;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
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
      viewportFraction: 0.65,
      initialPage: _selectedCarIndex,
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
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
    _glowController.dispose();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildHeader(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildQuickActions(),
              ),
              const SizedBox(height: 16),
              _buildCarCarousel(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildMapCard(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildMaintenancePlan(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildAlemAutoBox(),
              ),
              const SizedBox(height: 24),
            ],
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
            _buildHeaderIconButton(
              assetPath: 'assets/icons/qr-icon.svg',
              onTap: () {},
            ),
            const SizedBox(width: 12),
            _buildHeaderIconButton(
              assetPath: 'assets/icons/notifications.svg',
              onTap: _showNotificationsSheet,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIconButton({
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: SvgPicture.asset(
              assetPath,
              fit: BoxFit.contain,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ),
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
                'assets/icons/Vector.svg',
                () => _openQuickAction('Штрафы'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Расход',
                'assets/icons/expenses.svg',
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
                'Обслуживание',
                'assets/icons/maintenance.svg',
                () => _openQuickAction('Обслуживание'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Склад',
                'assets/icons/warehouse.svg',
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

  Widget _buildActionButton(
    String label,
    String iconPath,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 20,
              child: SvgPicture.asset(
                iconPath,
                fit: BoxFit.contain,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _openQuickAction(String title) {
    if (title == 'Обслуживание') {
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
    if (_isLoadingCars) {
      return const LoadingState(
        height: 380,
        message: 'Загрузка автомобиля...',
      );
    }

    if (_errorMessage != null) {
      return ErrorState(
        height: 380,
        message: _errorMessage!,
        onRetry: _loadCars,
      );
    }

    if (_cars.isEmpty) {
      return const EmptyState(
        height: 380,
        icon: Icons.directions_car_outlined,
        title: 'Нет автомобилей',
        message: 'Добавьте свой первый автомобиль',
      );
    }

    final safeIndex = _selectedCarIndex.clamp(0, _cars.length - 1);
    final car = _cars[safeIndex];

    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildCarCarouselBackground(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                '${car.make} ${car.model}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 26,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _carPageController,
                      builder: (context, child) {
                        final page = _carPageController.hasClients
                            ? _carPageController.page ??
                                _selectedCarIndex.toDouble()
                            : _selectedCarIndex.toDouble();

                        return Stack(
                          alignment: Alignment.center,
                          children: List.generate(_cars.length, (index) {
                            final rawDelta = (index - page);
                            final delta = rawDelta.clamp(-1.0, 1.0);
                            final scale = (1.0 - (delta.abs() * 0.35)) * 1.45;
                            final opacity = 1.0 - (delta.abs() * 0.65);
                            final rotateY = delta * 0.4;
                            final translateY = delta.abs() * 20.0;

                            final width = MediaQuery.of(context).size.width;
                            final translateX = rawDelta * width;

                            return Positioned(
                              left: translateX,
                              width: width,
                              height: 220,
                              child: Opacity(
                                opacity: opacity,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..translate(0.0, translateY, 0.0)
                                    ..rotateY(rotateY)
                                    ..scale(scale),
                                  child: _buildCarFanCard(
                                      _cars[index], index == safeIndex),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    PageView.builder(
                      controller: _carPageController,
                      itemCount: _cars.length,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedCarIndex = index;
                        });
                      },
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          if (widget.onCarTap != null) {
                            widget.onCarTap!(_cars[index]);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statPill(
                    car.mileage != null ? '${car.mileage} км' : '—',
                  ),
                  const SizedBox(width: 12),
                  _statPill(car.plateNumber ?? '—'),
                ],
              ),
              const Spacer(),
              if (_cars.length > 1) _buildCarouselDots(),
              const SizedBox(height: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarCarouselBackground() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.7 + (_glowAnimation.value * 0.3),
              child: Image.asset(
                'assets/images/ellipse.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCarouselDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _cars.length,
        (index) {
          final isActive = index == _selectedCarIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            width: isActive ? 40 : 28,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFDA562C) : Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarFanCard(CarModel car, bool isActive) {
    return IgnorePointer(
      child: Transform.scale(
        scaleX: -1, // Отзеркаливаем, чтобы машина смотрела влево
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Car3DViewer(
            key: ValueKey('home_3d_fan_${car.id}'),
            model3dUrl: car.model3dUrl,
            fallbackImageUrl: car.imageUrl,
            carName: car.name,
            cameraOrbit: '-45deg 75deg 105%',
            cameraControls: false,
            autoActivate: true,
          ),
        ),
      ),
    );
  }

  Widget _statPill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF181818).withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildMapCard() {
    Widget mapButton({required String iconPath, bool filled = false}) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              filled ? AppColors.primary : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/map.png',
                fit: BoxFit.cover,
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/search-loupe.svg',
                                  width: 18,
                                  height: 18,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Поиск',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    mapButton(
                      iconPath: 'assets/icons/full-screen.svg',
                      filled: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          const LoadingState(height: 150, message: 'Загрузка плана...'),
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
          ErrorState(
            height: 150,
            message: _maintenanceError!,
            onRetry: _loadMaintenance,
          ),
        ],
      );
    }

    if (_maintenanceItems.isEmpty) {
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
          const EmptyState(
            height: 150,
            icon: Icons.event_available_outlined,
            title: 'Нет записей ТО',
            message: 'Добавьте первое обслуживание',
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatMaintenanceDate(item),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Полная диагностика авто',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
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
