import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/car_model.dart';
import 'widgets/car_3d_viewer.dart';

class CarDetailPage extends StatefulWidget {
  final CarModel car;
  final VoidCallback? onBack;

  const CarDetailPage({super.key, required this.car, this.onBack});

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 16,
              ),
            ),
          ),
        ),
        title: Text(
          'Мой автомобиль',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // БЛОК 1: Изображение авто
              _buildCarImage(),
              const SizedBox(height: 20),

              // БЛОК 2: Название авто + кнопка
              _buildCarTitle(),
              const SizedBox(height: 20),

              // БЛОК 5: Список дел
              _buildTodoList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // БЛОК 1: Изображение авто на красном пъедестале
  Widget _buildCarImage() {
    return SizedBox(
      height: 450, // Увеличен размер с 320 до 450
      child: Stack(
        children: [
          // СЛОЙ 1: SVG эллипс пъедестала (внизу)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            height: 200,
            child: SvgPicture.asset(
              'assets/podium/podiumEllipse.svg',
              fit: BoxFit.fill,
            ),
          ),
          // СЛОЙ 2: 3D модель автомобиля
          Positioned(
            top: 50, // Опущена ниже с 0 до 50
            left: 0,
            right: 0,
            height: 350, // Увеличен с 200 до 350
            child: Car3DViewer(
              model3dUrl: widget.car.model3dUrl,
              fallbackImageUrl: widget.car.imageUrl,
              carName: widget.car.name,
              cameraOrbit: '0deg 75deg 105%',
              cameraControls: true, // Включаем прямое взаимодействие
            ),
          ),
          // СЛОЙ 3: Оранжевая иконка (декоративная)
          Positioned(
            bottom: 40, // У нижней границы эллипса пъедестала
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    'assets/podium/podiumIcon.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // БЛОК 2-4: Единый виджет (Название + Сетка + Информация)
  Widget _buildCarTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Название и кнопка (БЕЗ НОМЕРА)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.car.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 26),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Сетка 2x4 (8 карточек)
        // Ряд 1
        Row(
          children: [
            Expanded(child: _buildGridCard('Документы', Icons.description)),
            const SizedBox(width: 12),
            Expanded(child: _buildGridCard('Страховка', Icons.shield)),
          ],
        ),
        const SizedBox(height: 12),
        // Ряд 2
        Row(
          children: [
            Expanded(
              child: _buildGridCard('Сервисная\nкнижка', Icons.menu_book),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildGridCard('История', Icons.history)),
          ],
        ),
        const SizedBox(height: 12),
        // Ряд 3
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Пробег',
                widget.car.mileage != null
                    ? '${widget.car.mileage} км'
                    : 'Не указано',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard('Год выпуска', widget.car.year.toString()),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Ряд 4
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Топливо',
                widget.car.fuelType ?? 'Не указано',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Двигатель',
                widget.car.engineType ?? 'Не указано',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Блок "Информация об автомобиле" - отдельные карточки
        _buildDetailCard('Марка', '${widget.car.make} ${widget.car.model}'),
        const SizedBox(height: 12),
        _buildDetailCard('VIN', widget.car.vin ?? 'Не указано'),
        const SizedBox(height: 12),
        _buildDetailCard('Цвет', widget.car.color ?? 'Не указано'),
        const SizedBox(height: 12),
        _buildDetailCard('Коробка', widget.car.transmission ?? 'Не указано'),
        const SizedBox(height: 12),
        _buildDetailCard('Привод', widget.car.drivetrain ?? 'Не указано'),
        const SizedBox(height: 12),
        _buildDetailCard(
          'Номерной знак',
          widget.car.plateNumber ?? 'Не указано',
        ),
      ],
    );
  }

  // Карточка для информации об автомобиле (растянута по ширине)
  Widget _buildDetailCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF27292F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF8B92A3),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Карточка с иконкой и текстом (для первых 4)
  Widget _buildGridCard(String title, IconData icon) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF27292F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Карточка с информацией (для Пробег, Год, Топливо, Двигатель)
  Widget _buildInfoCard(String label, String value) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF27292F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8B92A3),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // БЛОК 5: Список дел (чеклист + кнопка)
  Widget _buildTodoList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Список дел',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildTodoItem('Замена масла до 50,000 км', false, (val) {}),
        const SizedBox(height: 16),
        _buildTodoItem('Продлить ОСАГО до 15 мая', false, (val) {}),
        const SizedBox(height: 16),
        _buildTodoItem('Заказать летнюю резину', true, (val) {}),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Добавить задачу',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Один элемент списка дел
  Widget _buildTodoItem(
    String title,
    bool isChecked,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: isChecked,
            onChanged: (val) => onChanged(val ?? false),
            checkColor: Colors.white,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
            side: const BorderSide(color: Color(0xFF8B92A3), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
