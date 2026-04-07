# Flutter <-> Backend API Integration

Этот документ описывает интеграцию Flutter фронтенда с новыми backend модулями из коммитов `7993b0c` и `7409fe7`.

## 📦 Обновленные модули

### 1. Market API ✅

**Backend Endpoints:**
- `GET /market/products` - список товаров
- `GET /market/services` - список услуг
- `GET /market/ads` - список объявлений
- `POST /market/{kind}` - создать товар/услугу/объявление
- `GET /market/{kind}/:id` - получить по ID
- `PUT /market/{kind}/:id` - обновить
- `DELETE /market/{kind}/:id` - удалить

**Flutter Integration:**
- ✅ Модель: `MarketProductModel` обновлена под backend структуру
- ✅ Сервис: `MarketService` переписан с правильными endpoints
- ✅ Поля: `id`, `user_id`, `kind`, `title`, `description`, `price`, `currency`, `category`, `available`

**Использование:**
```dart
final marketService = getIt<MarketService>();

// Получить список товаров
final products = await marketService.getProducts(
  category: 'tires',
  search: 'michelin',
  limit: 20,
);

// Создать новый товар
final product = await marketService.createProduct(
  title: 'Michelin Primacy 4',
  description: 'Комплект из 4 шин',
  price: 240000,
  category: 'tires',
);
```

---

### 2. Booking API ✅

**Backend Endpoints:**
- `POST /bookings` - создать бронирование
- `GET /bookings` - список с фильтрами
- `GET /bookings/:id` - получить по ID
- `PUT /bookings/:id` - обновить статус/заметки
- `DELETE /bookings/:id` - удалить

**Flutter Integration:**
- ✅ Модель: `BookingModel` обновлена под backend
- ✅ Сервис: `BookingService` переписан
- ✅ Поля: `id`, `service_center_id`, `vehicle_id`, `user_id`, `scheduled_at`, `status`, `notes`
- ✅ Статусы: `scheduled`, `completed`, `cancelled`, `no_show`

**Использование:**
```dart
final bookingService = getIt<BookingService>();

// Получить список бронирований
final bookings = await bookingService.getBookings(
  vehicleId: 'vehicle-uuid',
  status: 'scheduled',
);

// Создать бронирование
final booking = await bookingService.createBooking(
  serviceCenterId: 'center-uuid',
  vehicleId: 'vehicle-uuid',
  scheduledAt: DateTime(2026, 4, 15, 10, 0),
  notes: 'Замена масла',
);

// Отменить
await bookingService.cancelBooking(booking.id);
```

---

### 3. Fines API ✅

**Backend Endpoints:**
- `POST /fines` - создать штраф
- `GET /fines` - список с фильтрами
- `GET /fines/:id` - получить по ID
- `PUT /fines/:id` - обновить (отметить оплаченным)
- `DELETE /fines/:id` - удалить

**Flutter Integration:**
- ✅ Модель: `FineModel` обновлена под backend
- ✅ Сервис: `FinesService` переписан
- ✅ Поля: `id`, `user_id`, `vehicle_id`, `amount`, `currency`, `article`, `description`, `issued_at`, `paid_at`, `status`
- ✅ Статусы: `pending`, `paid`, `disputed`

**Использование:**
```dart
final finesService = getIt<FinesService>();

// Получить неоплаченные штрафы
final unpaidFines = await finesService.getFines(status: 'pending');

// Оплатить штраф
await finesService.payFine(fine.id);

// Создать штраф (для admin)
await finesService.createFine(
  vehicleId: 'vehicle-uuid',
  amount: 20000,
  article: 'КоАП 590',
  description: 'Превышение скорости',
  issuedAt: DateTime.now(),
);
```

---

### 4. Warehouse API ✅ (NEW)

**Backend Endpoints:**
- `GET /warehouse/parts` - список запчастей
- `POST /warehouse/parts` - создать запчасть
- `GET /warehouse/parts/:id` - получить по ID
- `PUT /warehouse/parts/:id` - обновить
- `POST /warehouse/parts/:id/check` - проверить наличие
- `POST /warehouse/parts/:id/stock` - обновить остаток
- `DELETE /warehouse/parts/:id` - удалить

**Flutter Integration:**
- ✅ Модель: `WarehousePartModel` создана
- ✅ Сервис: `WarehouseService` создан
- ✅ Поля: `id`, `name`, `part_number`, `category`, `manufacturer`, `description`, `price`, `quantity_in_stock`, `min_stock_level`
- ✅ Категории: `engine`, `transmission`, `suspension`, `brakes`, `electrical`, `body`, `accessories`, `other`

**Использование:**
```dart
final warehouseService = getIt<WarehouseService>();

// Получить список запчастей двигателя
final engineParts = await warehouseService.getParts(
  category: 'engine',
  inStock: true,
);

// Проверить наличие
final availability = await warehouseService.checkAvailability(
  partId,
  quantity: 2,
);

// Обновить остаток (добавить 10 штук)
await warehouseService.updateStock(
  id: partId,
  quantity: 10,
  operation: 'add',
);
```

---

## 🔧 Необходимые действия

### 1. Запустить код генератор

```bash
cd frontend
flutter pub run build_runner build --delete-conflicting-outputs
```

Это сгенерирует `.g.dart` файлы для всех моделей:
- `market_product_model.g.dart`
- `booking_model.g.dart`
- `fine_model.g.dart`
- `warehouse_part_model.g.dart`

### 2. Обновить Service Locator

Добавить `WarehouseService` в `service_locator.dart`:

```dart
// В функции setupServiceLocator()
getIt.registerLazySingleton(() => WarehouseService(getIt<ApiClient>()));
```

### 3. Обновить существующие экраны

Файлы, которые нужно обновить для совместимости с новыми моделями:

**Market:**
- `lib/features/market/market_page.dart` - использует старую структуру `MarketProductModel`
- Нужно обновить обращения к полям: `sellerId` → `userId`, добавить `kind`, `currency`

**Bookings:**
- Файлы, использующие `BookingModel` нужно обновить:
  - `serviceName`, `address`, `date`, `timeSlot`, `price` → новая структура с `service_center_id`, `vehicle_id`, `scheduled_at`

**Fines:**
- Файлы, использующие `FineModel`:
  - `title` → `article` (или вычисляемый getter)
  - `location` теперь опциональное поле только для UI

### 4. Убрать моки (если нужно)

После успешного подключения к backend можно убрать fallback на `MockData` в:
- Не требуется, так как новые сервисы уже не используют моки

---

## 📊 Соответствие Backend ↔ Flutter

| Backend Field | Flutter Field | Type | Notes |
|---------------|---------------|------|-------|
| **Market** |
| `id` | `id` | String | UUID |
| `user_id` | `userId` | String | UUID продавца |
| `kind` | `kind` | String | product/service/ad |
| `title` | `title` | String | |
| `description` | `description` | String | |
| `price` | `price` | double | |
| `currency` | `currency` | String | Обычно "KZT" |
| `category` | `category` | String | |
| `available` | `available` | bool | |
| **Booking** |
| `id` | `id` | String | UUID |
| `service_center_id` | `serviceCenterId` | String | UUID |
| `vehicle_id` | `vehicleId` | String | UUID |
| `user_id` | `userId` | String | UUID |
| `scheduled_at` | `scheduledAt` | DateTime | |
| `status` | `status` | String | scheduled/completed/cancelled/no_show |
| `notes` | `notes` | String? | |
| **Fines** |
| `id` | `id` | String | UUID |
| `user_id` | `userId` | String | UUID |
| `vehicle_id` | `vehicleId` | String? | UUID (optional) |
| `amount` | `amount` | double | |
| `currency` | `currency` | String | Обычно "KZT" |
| `article` | `article` | String? | Статья КоАП |
| `description` | `description` | String | |
| `issued_at` | `issuedAt` | DateTime | |
| `paid_at` | `paidAt` | DateTime? | |
| `status` | `status` | String | pending/paid/disputed |
| **Warehouse** |
| `id` | `id` | String | UUID |
| `name` | `name` | String | |
| `part_number` | `partNumber` | String | Артикул |
| `category` | `category` | String | engine/transmission/etc |
| `manufacturer` | `manufacturer` | String? | |
| `description` | `description` | String? | |
| `price` | `price` | double? | |
| `quantity_in_stock` | `quantityInStock` | int | |
| `min_stock_level` | `minStockLevel` | int | |

---

## ✅ Статус интеграции

- ✅ **Market API** - модели и сервисы обновлены
- ✅ **Booking API** - модели и сервисы обновлены
- ✅ **Fines API** - модели и сервисы обновлены
- ✅ **Warehouse API** - модели и сервисы созданы
- ⏳ **Код генерация** - требуется запустить `build_runner`
- ⏳ **UI обновление** - требуется обновить экраны под новую структуру
- ⏳ **Service Locator** - добавить `WarehouseService`

---

## 🎯 Следующие шаги

1. Запустить `flutter pub run build_runner build --delete-conflicting-outputs`
2. Добавить `WarehouseService` в DI
3. Обновить экраны Market, Booking, Fines под новую структуру данных
4. Протестировать с запущенным backend
5. Убрать старые mock данные (опционально)

---

**Дата создания:** 28 марта 2026  
**Автор:** GitHub Copilot  
**Статус:** ✅ API интеграция завершена, требуется код генерация
