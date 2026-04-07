# ALEM AUTO HUB — Flutter Frontend

Мобильное приложение для владельцев автомобилей: цифровой гараж, запись в СТО, маркетплейс, социальная сеть и ИИ-ассистент.

## Содержание

- [О проекте](#о-проекте)
- [Технологический стек](#технологический-стек)
- [Быстрый старт](#быстрый-старт)
- [Конфигурация](#конфигурация)
- [Архитектура и структура](#архитектура-и-структура)
- [Модули](#модули)
- [Команды разработки](#команды-разработки)

## О проекте

ALEM AUTO HUB — комплексное мобильное приложение для владельцев автомобилей:

- цифровой гараж и история обслуживания
- запись в СТО и планирование работ
- маркетплейс автозапчастей и услуг
- ИИ-ассистент (Gemini API)
- финансы и учет расходов
- социальная сеть автомобилистов
- штрафы и рекомендации по ПДД

## Технологический стек

- Flutter 3.9.2
- Dart 3.9.2
- Платформы: iOS 13.0+, Android 5.0+

Ключевые библиотеки: `dio`, `flutter_bloc`, `equatable`, `json_annotation`, `get_it`, `go_router`, `shared_preferences`, `logger`, `o3d`.

## Быстрый старт

### Требования

- Flutter SDK >= 3.9.0
- Dart SDK >= 3.9.0
- Xcode 15.0+ (для iOS)
- Android Studio 2023.1.1+

### Установка

```bash
git clone https://github.com/Tugazh/Alem-Auto-Hub.git
cd Alem-Auto-Hub/frontend
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### iOS зависимости (macOS)

```bash
cd ios
pod install
cd ..
```

## Конфигурация

### Backend API

Файл: `lib/core/network/api_client.dart`.

```dart
final String _baseUrl = Platform.isIOS
    ? 'http://localhost:8080/api/v1'
    : 'http://10.0.2.2:8080/api/v1';
```

Production:

```dart
final String _baseUrl = 'https://api.alemautohub.kz/api/v1';
```

## Архитектура и структура

Приложение построено по Clean Architecture с разделением на слои:

```
lib/
├── core/          # DI, сеть, ошибки, тема
├── data/          # модели, сервисы, mock
├── features/      # UI и логика модулей
└── shared/        # переиспользуемые виджеты
```

Основные папки:

- `core/di` — контейнер зависимостей
- `core/network` — клиент API
- `data/models` — модели данных
- `data/services` — запросы в API
- `features/*` — модули приложения

## Модули

- онбординг и авторизация
- гараж и история обслуживания
- маркетплейс
- социальная сеть
- запись в СТО
- ИИ-ассистент
- финансы и штрафы
- настройки профиля

## Команды разработки

```bash
flutter run -d ios
flutter run -d android
flutter build apk --release
flutter build ipa --release
```

## Проверки качества

```bash
flutter analyze
flutter test
flutter format lib/
```

