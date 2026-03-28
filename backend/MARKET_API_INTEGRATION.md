# Market API Integration Guide (Backend -> Flutter)

This document describes how frontend can integrate with the new backend market module.

Base URL:
- `http://localhost:8080/api/v1` (or emulator host mapping)

Auth:
- All market endpoints are protected.
- Send `Authorization: Bearer <jwt_token>`.

## Endpoints

### Products
- `GET /market/products?category=&search=&limit=&offset=`
- `POST /market/products`
- `GET /market/products/:id`
- `PUT /market/products/:id`
- `DELETE /market/products/:id`

### Services
- `GET /market/services?category=&search=&limit=&offset=`
- `POST /market/services`
- `GET /market/services/:id`
- `PUT /market/services/:id`
- `DELETE /market/services/:id`

### Ads
- `GET /market/ads?category=&search=&limit=&offset=`
- `POST /market/ads`
- `GET /market/ads/:id`
- `PUT /market/ads/:id`
- `DELETE /market/ads/:id`

## Request payloads

### Create (`POST`)
```json
{
  "title": "Michelin Primacy 4",
  "description": "Set of 4 tires, lightly used",
  "category": "tires",
  "price": 240000,
  "currency": "KZT"
}
```

Notes:
- `title`, `description`, `category`, `price` are required.
- `price` must be `> 0`.
- If `currency` is omitted, backend uses `KZT`.

### Update (`PUT`)
```json
{
  "title": "Michelin Primacy 4 (updated)",
  "description": "Set of 4 tires, almost new",
  "category": "tires",
  "price": 250000,
  "currency": "KZT",
  "available": true
}
```

All fields are optional for update.

## Response object

```json
{
  "id": "5c29f79f-31a1-4f58-a39d-8e9a19a9b000",
  "user_id": "11b53a20-3250-4de3-b45f-8658a9ba0000",
  "kind": "product",
  "title": "Michelin Primacy 4",
  "description": "Set of 4 tires, lightly used",
  "category": "tires",
  "price": 240000,
  "currency": "KZT",
  "available": true,
  "created_at": "2026-03-26T10:12:01Z",
  "updated_at": "2026-03-26T10:12:01Z"
}
```

## Status codes

- `200 OK` - list/get/update success
- `201 Created` - create success
- `204 No Content` - delete success
- `400 Bad Request` - validation error or bad UUID
- `401 Unauthorized` - missing/invalid token
- `404 Not Found` - entity not found for current user

## Integration notes for Flutter developer

- Replace old `/market` calls with segmented endpoints:
  - `/market/products`
  - `/market/services`
  - `/market/ads`
- Use query params:
  - `category` (exact match),
  - `search` (substring over title/description),
  - `limit` default `50`,
  - `offset` default `0`.
- Keep DTO field names exactly as backend JSON keys (`snake_case`).
