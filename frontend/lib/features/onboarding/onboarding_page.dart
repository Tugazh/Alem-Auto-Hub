import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/language_selection_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      image: 'assets/images/onboarding/car.png',
      backgroundImage: 'assets/images/onboarding/paper.png',
      title: 'Централизация\nфункций =\nверифицированная\nистория автомобиля',
      description:
          'Объединив все ключевые операции автовладельца в одной экосистеме, мы создаем не просто журнал расходов, а полноценную верифицированную историю эксплуатации автомобиля. Это повышает прозрачность, доверие и будущую стоимость авто.',
    ),
    OnboardingSlide(
      image: 'assets/images/onboarding/hand.png',
      title: 'Что фиксирует\nAlem Auto Hub',
      description:
          'Alem Auto Hub фиксирует все операции по автомобилю — от замены расходников и обслуживания до покупок запчастей, диагностики и любых выполненных работ.',
    ),
    OnboardingSlide(
      image: 'assets/images/onboarding/wallet.png',
      title: 'Подтверждение\nв каждой записи',
      description:
          'Все чеки, фото и работы — в одном месте. Партнерские СТО могут верифицировать записи, формируя подтверждённую историю автомобиля.',
    ),
    OnboardingSlide(
      image: 'assets/images/onboarding/masters.png',
      title: 'Свобода выбора\nмастеров',
      description:
          'Вы сами выбираете мастеров, а приложение остаётся вашим инструментом: учитывайте расходы, фиксируйте работы и храните всю историю авто в одном месте — даже без верификации это полноценный личный архив.',
    ),
    OnboardingSlide(
      image: 'assets/images/onboarding/tick.png',
      title: 'Основные ценности\nAlem Auto Hub это',
      description:
          'Прозрачная история авто, честные рекомендации и меньше расходов на обслуживание. Все автосервисы в одном месте и сообщество, которому можно доверять.',
      isLast: true,
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LanguageSelectionPage()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Alem Auto',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isLast)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        'Пропустить',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLast
                            ? AppColors.primary
                            : AppColors.surface.withValues(alpha: 0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isLast ? 'Войти' : 'Далее',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (isLast) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LanguageSelectionPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.surface.withValues(
                            alpha: 0.8,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Создать аккаунт',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (slide.backgroundImage != null)
                    Positioned(
                      top: 10,
                      child: Image.asset(
                        slide.backgroundImage!,
                        height: 190,
                        fit: BoxFit.contain,
                      ),
                    ),
                  Image.asset(slide.image, height: 220, fit: BoxFit.contain),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              slide.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingSlide {
  final String image;
  final String? backgroundImage;
  final String title;
  final String description;
  final bool isLast;

  const OnboardingSlide({
    required this.image,
    this.backgroundImage,
    required this.title,
    required this.description,
    this.isLast = false,
  });
}
