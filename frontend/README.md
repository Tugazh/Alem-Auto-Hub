# AUTO.ONE - Flutter Mobile Application# AUTO.ONE Flutter Client



Professional automotive management mobile application built with Flutter 3.35+ and Dart 3.9+.Мобильное приложение для AUTO.ONE, построенное на Flutter с Material Design 3.



## Features## 🏗️ Архитектура



### Core Features### Структура проекта

- **Garage Management** - Vehicle tracking, maintenance history, documents

- **Maintenance Scheduler** - Automated service reminders and scheduling```

- **Expense Tracking** - Fuel, repairs, insurance, and other costslib/

├── main.dart                      # Entry point

### Business Features├── core/                          # Core functionality

- **Auto Market** - Buy/sell parts and accessories│   ├── constants/

- **Service Finder** - Locate nearby auto service centers│   │   └── api_constants.dart     # API endpoints

- **Tender System** - Submit and browse service requests│   ├── network/

│   │   └── api_client.dart        # HTTP client (Dio)

### Engagement Features│   └── theme/

- **AI Assistant** - Chat-based automotive advice and diagnostics│       ├── app_colors.dart        # Colors

- **Social Feed** - Share photos, tips, and experiences│       └── app_theme.dart         # Theme

- **Community** - Connect with other car enthusiasts├── data/                          # Data layer

│   ├── models/                    # Data models

## Technical Stack│   ├── repositories/              # Repositories (TODO)

│   └── services/                  # API services

| Category | Technology |├── features/                      # Feature modules

|----------|-----------|│   ├── main/                      # Main navigation

| **Framework** | Flutter 3.35+ |│   ├── home/                      # Dashboard

| **Language** | Dart 3.9+ |│   ├── car_detail/                # Car details

| **State Management** | Provider (planned: Riverpod/Bloc) |│   ├── finance/                   # Finance tracking

| **HTTP Client** | Dio 5.4+ |│   ├── ai_agent/                  # AI chat

| **JSON Serialization** | json_serializable |│   ├── market/                    # Marketplace

| **Local Storage** | SharedPreferences, SecureStorage |│   └── social/                    # Social network

| **Navigation** | Flutter Navigator 2.0 |└── shared/                        # Shared widgets

```

## Project Structure

## 🎨 Design System

```

lib/**Colors**: #FF5722 (Primary), #1A1A1A (Background), #2A2A2A (Surface)  

├── core/                    # Core utilities**Font**: Inter (Google Fonts)  

│   ├── network/            # API client, interceptors**Theme**: Material Design 3 Dark

│   ├── theme/              # Colors, text styles

│   └── constants/          # App constants## 🔌 Backend Integration

├── data/                    # Data layer

│   ├── models/             # Data models (Car, Maintenance, etc.)### Status: ✅ READY TO TEST

│   ├── services/           # API services

│   └── mock/               # Mock data for development**Все сервисы активированы и готовы к работе с backend!**

└── features/               # Feature modules

    ├── home/               # Home dashboard### API Configuration

    ├── garage/             # Vehicle management- Base URL: `http://localhost:8080` (Development)

    ├── maintenance/        # Service tracking- Все endpoints в `api_constants.dart`

    ├── market/             # Auto marketplace- Models соответствуют backend структуре

    ├── social/             # Social network- ServiceLocator для dependency injection

    ├── ai_agent/           # AI assistant

    └── finance/            # Expense tracking### Готовые компоненты

```✅ **Models**: CarModel, MaintenanceModel, MarketProductModel, SocialPostModel  

✅ **Services**: GarageService (5/5 methods), AIService (1/3 methods)  

## Installation✅ **HTTP Client**: ApiClient с JWT и interceptors  

✅ **DI**: ServiceLocator (initialized in main.dart)  

### Prerequisites✅ **Test Page**: BackendTestPage для проверки API



- Flutter SDK 3.35+ ([Install Flutter](https://flutter.dev/docs/get-started/install))### Быстрый тест

- Dart SDK 3.9+

- Android Studio / Xcode (for mobile development)#### 1. Запустите backend:

- VS Code with Flutter extension (recommended)```bash

cd /Users/roomi/Desktop/Work/alem-auto

### Setupgo run cmd/api/main.go

```

```bash

# Clone repository#### 2. Запустите Flutter:

git clone <repository-url>```bash

cd alem-autocd client

flutter run

# Install dependencies```

flutter pub get

#### 3. Откройте тест:

# Run code generation (for JSON serialization)- В приложении нажмите кнопку **API** (FloatingActionButton справа внизу)

dart run build_runner build --delete-conflicting-outputs- Запустите тесты Health Check, Garage API, AI Chat



# Run the app📖 **Подробная документация**: [TESTING.md](TESTING.md)  

flutter run✅ ApiClient с JWT authentication  

```

## 📦 Установка

### Development Commands

```bash

```bash# 1. Установить зависимости

# Hot reload during developmentflutter pub get

flutter run

# 2. Запустить приложение

# Run testsflutter run

flutter test```



# Analyze code### Требуется добавить в pubspec.yaml:

flutter analyze```yaml

dependencies:

# Format code  dio: ^5.4.0              # HTTP client

flutter format lib/  flutter_bloc: ^8.1.3     # State management

  get_it: ^7.6.0           # DI

# Build APK (Android)  shared_preferences: ^2.2.2  # Storage

flutter build apk --release```



# Build IPA (iOS)## 🚀 Подключение к бэкенду

flutter build ios --release

1. Запустите бэкенд (см. `/README.md`)

# Generate JSON serialization2. Обновите `baseUrl` в `api_constants.dart`

flutter pub run build_runner watch --delete-conflicting-outputs3. Раскомментируйте API вызовы в сервисах

```4. Удалите mock данные



## Configuration## 📱 Статус функционала



### API Endpoints### ✅ Реализовано (UI)

- Main navigation (5 вкладок)

The app automatically detects the platform and configures the API base URL:- Home page (карусель авто)

- Car detail page (инфо + todo)

- **Android Emulator**: `http://10.0.2.2:8080/api/v1`- Finance page (графики)

- **iOS Simulator**: `http://localhost:8080/api/v1`- AI Agent (chat UI)

- **Production**: Configure in `lib/core/network/api_client.dart`- Market (товары + фильтры)

- Social network (лента + сообщества)

### Mock Data

### 🔄 Требует подключения

Currently, the app uses mock data for development (see `lib/data/mock/mock_data.dart`). The app will automatically fallback to mock data if the backend is unavailable.- [ ] Auth (JWT)

- [ ] Реальные данные API

## Architecture- [ ] AI OpenAI integration

- [ ] Image upload (MinIO)

The application follows **Clean Architecture** principles with three main layers:- [ ] WebSockets (Tenders)

- [ ] Push notifications

1. **Core Layer** (`lib/core/`)

   - Network configuration## 🔧 TODO Senior Level

   - Theme and styling

   - Constants and utilities### Архитектура

- [ ] BLoC/Cubit для state management

2. **Data Layer** (`lib/data/`)- [ ] GetIt dependency injection

   - Data models with JSON serialization- [ ] Repository pattern

   - API service implementations- [ ] Error handling + retry

   - Mock data providers- [ ] Offline-first (Hive/Drift)



3. **Presentation Layer** (`lib/features/`)### Производительность

   - Feature-based UI modules- [ ] Lazy loading

   - State management (Provider)- [ ] Image caching

   - Navigation logic- [ ] Const optimization

- [ ] Pagination

## Features Documentation

### Тестирование

### Garage Module- [ ] Unit tests (services)

Manage your vehicle fleet with detailed information:- [ ] Widget tests (UI)

- Add/edit/delete vehicles- [ ] Integration tests

- Track mileage and fuel consumption- [ ] Golden tests

- Store vehicle documents

- Maintenance history## 📚 Backend соответствие



### Maintenance Module| Module | Frontend | Status |

Never miss a service with automated reminders:|--------|----------|--------|

- Schedule maintenance tasks| Auth | API ready | ⏳ UI needed |

- Set recurring reminders| Garage | ✅ Models + Service | ⏳ Connect |

- Track service history| Market | ✅ UI + Models | ⏳ Connect |

- View upcoming maintenance| AI | ✅ UI + Service | ⏳ Connect |

| Social | ✅ UI + Models | ⏳ Connect |

### Market Module

Buy and sell automotive parts:## 📄 Docs

- Browse products by category

- Search and filter**Version**: 1.0.0  

- Product details with images**Flutter**: 3.35.7  

- (Future: Purchase flow)**Dart**: 3.9.2  

**Updated**: 2026-01-24

### Social Module
Connect with the automotive community:
- Post photos and updates
- Like and comment on posts
- Follow other users
- Share automotive tips

### AI Agent Module
Get intelligent assistance:
- Chat-based interface
- Vehicle diagnostics help
- Maintenance recommendations
- (Future: OpenAI integration)

## Backend Integration

This is a **frontend-only** repository. The backend API is developed separately.

Expected backend endpoints:
- `GET /api/v1/garage` - List vehicles
- `GET /api/v1/maintenance` - List maintenance records
- `GET /api/v1/market` - List marketplace products
- `GET /api/v1/social/posts` - List social posts
- `POST /api/v1/ai/chat` - AI assistant chat

See `lib/data/services/` for complete API service implementations.

## Development

### Code Style

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).

Run formatter before committing:
```bash
flutter format lib/
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Debugging

1. Use Flutter DevTools for debugging
2. Check API logs in `lib/core/network/api_client.dart`
3. Mock data warnings appear in console with `⚠️` prefix

## Deployment

### Android

```bash
# Build release APK
flutter build apk --release

# Build App Bundle (for Google Play)
flutter build appbundle --release
```

### iOS

```bash
# Build release IPA
flutter build ios --release

# Archive for App Store
# Use Xcode: Product → Archive
```

## Roadmap

- [ ] Implement state management (Riverpod/Bloc)
- [ ] Add offline support with local database (Drift/Hive)
- [ ] Integrate real backend API
- [ ] Add push notifications
- [ ] Implement in-app purchases
- [ ] Add biometric authentication
- [ ] Multi-language support (i18n)
- [ ] Dark mode support
- [ ] Unit and integration tests
- [ ] CI/CD pipeline

## License

Private project. All rights reserved.

## Support

For questions or issues, contact the development team.
