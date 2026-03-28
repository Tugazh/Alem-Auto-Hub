import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final items = [
      _NavItem('Гараж', 'assets/icons/Navbar/garage.svg'),
      _NavItem('Финансы', 'assets/icons/Navbar/wallet.svg'),
      _NavItem('ИИ', 'assets/icons/Navbar/ai-agent.svg'),
      _NavItem('Маркет', 'assets/icons/Navbar/market.svg'),
      _NavItem('Соц', 'assets/icons/Navbar/social-network.svg'),
    ];

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SizedBox(
        height: kBottomNavigationBarHeight,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == currentIndex;

            return Expanded(
              child: InkResponse(
                onTap: () => onTap(index),
                radius: 28,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _navIcon(item.assetPath, selected),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.1,
                        color: selected
                            ? AppColors.textPrimary
                            : AppColors.iconGray,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _navIcon(String assetPath, bool selected) {
    return SizedBox.square(
      dimension: 20,
      child: SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          selected ? AppColors.textPrimary : AppColors.iconGray,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String assetPath;

  const _NavItem(this.label, this.assetPath);
}
