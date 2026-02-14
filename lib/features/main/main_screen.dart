import 'package:flutter/material.dart';
import '../../data/models/car_model.dart';
import '../home/home_page.dart';
import '../finance/finance_page.dart';
import '../ai_agent/ai_agent_page.dart';
import '../market/market_page.dart';
import '../social/social_page.dart';
import '../car_detail/car_detail_page.dart';
import '../../shared/widgets/main_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentTabIndex;
  CarModel? _selectedCar;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
  }

  void navigateToCarDetail(CarModel car) {
    setState(() {
      _selectedCar = car;
      _currentTabIndex = 0;
    });
  }

  void _resetToHome() {
    setState(() {
      _selectedCar = null;
    });
  }

  Widget _getCurrentPage() {
    switch (_currentTabIndex) {
      case 0:
        return HomePageContent(onCarTap: navigateToCarDetail);
      case 1:
        return const FinancePage();
      case 2:
        return const AIAgentPage();
      default:
        return HomePageContent(onCarTap: navigateToCarDetail);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Если выбран автомобиль, показываем CarDetailPage вместо home
    Widget currentPage = _selectedCar != null
        ? CarDetailPage(car: _selectedCar!, onBack: _resetToHome)
        : _getCurrentPage();

    return Scaffold(
      body: currentPage,
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentTabIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    if (index == 3) {
      // Открываем Маркет как отдельную страницу
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const MarketPage()));
    } else if (index == 4) {
      // Открываем Соц сеть как отдельную страницу
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SocialPage()));
    } else {
      setState(() {
        _selectedCar = null; // Сбрасываем выбор авто
        _currentTabIndex = index;
      });
    }
  }
}
