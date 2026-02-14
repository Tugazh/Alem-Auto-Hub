import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.iconGray,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Мой гараж'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Кошелек'),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'ИИ агент',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Маркет',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Соц сеть',
          ),
        ],
      ),
    );
  }
}
