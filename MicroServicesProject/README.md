# Trendyol Go Clone – API Request / Response Dokümantasyonu

Bu doküman Trendyol Go benzeri bir mikroservis mimarisinde bulunan tüm servisler için **örnek Request ve Response JSON yapılarını** içerir. Tüm örnekler mobil uygulama ile backend servisleri arasındaki veri iletişimini göstermek amacıyla hazırlanmıştır.

---

# Standard Error Response Format

Gerçek mikroservis mimarilerinde tüm servisler, olası hatalar durumunda (4xx ve 5xx HTTP status kodlarıyla birlikte) istemciye ortak, standartlaşmış bir hata formatı dönerler. Tüm API'lerin genel hata yapısı aşağıdaki gibidir:

### Response (Örnek: 404 Not Found)

```json
{
  "error": {
    "code": "ADDRESS_NOT_FOUND",
    "message": "Address not found",
    "status": 404
  }
}
```

---

# 1. Authentication Service

## POST /api/v1/auth/login

### Request

```json
{
  "email": "sametbilgin@gmail.com",
  "password": "123456"
}
```

### Response

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR...",
  "expires_in": 3600,
  "user": {
    "id": "user_123",
    "name": "Samet",
    "surname": "Bilgin",
    "email": "sametbilgin@gmail.com",
    "phone_number": "+905551234567"
  }
}
```

---

## POST /api/v1/auth/register

### Request

```json
{
  "name": "Samet",
  "surname": "Bilgin",
  "email": "sametbilgin@gmail.com",
  "phone_number": "+905551234567",
  "password": "123456"
}
```

### Response

```json
{
  "message": "User registered successfully",
  "user_id": "user_123"
}
```

---

## POST /api/v1/auth/refresh-token

### Request

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR..."
}
```

### Response

```json
{
  "access_token": "new_access_token_here",
  "expires_in": 3600
}
```

---

## POST /api/v1/auth/logout

### Request

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR..."
}
```

### Response

```json
{
  "message": "Logged out successfully"
}
```

---

# 2. User Service

## GET /api/v1/users/me

### Response

```json
{
  "id": "user_123",
  "name": "Samet",
  "surname": "Bilgin",
  "email": "sametbilgin@gmail.com",
  "phone_number": "+905551234567",
  "loyalty_points": 420,
  "notification_preferences": {
    "push_enabled": true,
    "sms_enabled": false,
    "email_enabled": true
  }
}
```

---

## POST /api/v1/users/me/device

### Request

```json
{
  "device_token": "fcm_device_token_123",
  "platform": "ios"
}
```

### Response

```json
{
  "message": "Device registered successfully"
}
```

---

## GET /api/v1/users/me/addresses

### Response

```json
[
  {
    "id": "addr_1",
    "address_title": "Ev",
    "city": "Antalya",
    "district": "Kepez",
    "neighborhood": "Kültür Mah",
    "street": "3818 Sokak",
    "building_no": "8",
    "floor": "3",
    "apartment_no": "6",
    "address_description": "Kapı zili çalışmıyor",
    "phone": "05555555555",
    "location": {
      "lat": 36.884804,
      "lng": 30.704044
    },
    "masked_phone": "555*****55",
    "shows_map_preview": true,
    "is_current": true
  }
]
```

---

## POST /api/v1/users/me/addresses

### Request

```json
{
  "address_title": "İş",
  "city": "Antalya",
  "district": "Muratpaşa",
  "neighborhood": "Lara",
  "street": "2050 Sokak",
  "building_no": "10",
  "floor": "5",
  "apartment_no": "12",
  "address_description": "Güvenliğe bırakabilirsiniz",
  "phone": "05555555555",
  "location": {
    "lat": 36.884804,
    "lng": 30.704044
  }
}
```

### Response

```json
{
  "id": "addr_2",
  "address_title": "İş",
  "city": "Antalya",
  "district": "Muratpaşa",
  "neighborhood": "Lara",
  "street": "2050 Sokak",
  "building_no": "10",
  "floor": "5",
  "apartment_no": "12",
  "address_description": "Güvenliğe bırakabilirsiniz",
  "phone": "05555555555",
  "location": {
    "lat": 36.884804,
    "lng": 30.704044
  }
}
```

---

## PUT /api/v1/users/me/addresses/{id}

### Request

```json
{
  "address_title": "Ofis",
  "street": "2055 Sokak",
  "location": {
    "lat": 36.884810,
    "lng": 30.704050
  }
}
```

### Response

```json
{
  "id": "addr_2",
  "address_title": "Ofis",
  "city": "Antalya",
  "district": "Muratpaşa",
  "neighborhood": "Lara",
  "street": "2055 Sokak",
  "building_no": "10",
  "floor": "5",
  "apartment_no": "12",
  "address_description": "Güvenliğe bırakabilirsiniz",
  "phone": "05555555555",
  "location": {
    "lat": 36.884810,
    "lng": 30.704050
  }
}
```

---

## DELETE /api/v1/users/me/addresses/{id}

### Response

```json
{
  "message": "Address deleted"
}
```

---

## GET /api/v1/users/me/favorites?page=1&limit=20

### Response

```json
{
  "page": 1,
  "limit": 20,
  "total": 15,
  "data": [
    {
      "vendor_id": "vendor_101",
      "name": "Burger Point",
      "image_url": "https://cdn.app.com/burger.jpg"
    }
  ]
}
```

---

## POST /api/v1/users/me/favorites/{vendor_id}

### Response

```json
{
  "message": "Vendor added to favorites"
}
```

---

## DELETE /api/v1/users/me/favorites/{vendor_id}

### Response

```json
{
  "message": "Vendor removed from favorites"
}
```

---

# 3. Gateway / BFF

## GET /api/v1/home/discover

### Response

```json
{
  "active_order": {
    "id": "order_555",
    "vendor_name": "Burger Point",
    "status": "DELIVERING",
    "status_label": "Siparişin Hazırlanıyor"
  },
  "hero_banners": [
    {
      "id": "banner_1",
      "title": "300 TL üzeri",
      "subtitle": "40 TL indirim",
      "image_url": "https://cdn.app.com/banner1.png"
    }
  ],
  "primary_categories": [
    {
      "id": "food",
      "name": "Yemek",
      "icon_url": "https://cdn.app.com/icons/food.png"
    }
  ],
  "mini_services": [
    {
      "id": "petshop",
      "name": "Petshop",
      "icon_url": "https://cdn.app.com/icons/pet.png"
    }
  ],
  "featured_vendors": [
    {
      "id": "vendor_101",
      "name": "Burger Point",
      "rating": 4.7,
      "review_count": 1280,
      "eta": "20-30 dk",
      "delivery_fee": 24.9,
      "image_url": "https://cdn.app.com/burgerpoint.jpg"
    }
  ]
}
```

---

# 4. Restaurant Service

## GET /api/v1/vendors?page=1&limit=20

### Response

```json
{
  "page": 1,
  "limit": 20,
  "total": 120,
  "data": [
    {
      "id": "vendor_101",
      "name": "Burger Point",
      "kind": "RESTAURANT",
      "rating": 4.7,
      "review_count": 1280,
      "distance_km": 2.4,
      "campaign_badges": [
        "30 TL indirim",
        "Ücretsiz teslimat"
      ],
      "working_hours": {
        "open": "10:00",
        "close": "02:00",
        "is_open": true
      },
      "delivery_info": {
        "eta_range": "20-30 dk",
        "minimum_basket_amount": 180,
        "delivery_fee": 24.9
      }
    }
  ]
}
```

---

## GET /api/v1/vendors/{vendor_id}

### Response

```json
{
  "id": "vendor_101",
  "name": "Burger Point",
  "kind": "RESTAURANT",
  "rating": 4.7,
  "review_count": 1280,
  "distance_km": 2.4,
  "campaign_badges": [
    "30 TL indirim",
    "Ücretsiz teslimat"
  ],
  "working_hours": {
    "open": "10:00",
    "close": "02:00",
    "is_open": true
  },
  "delivery_info": {
    "eta_range": "20-30 dk",
    "minimum_basket_amount": 180,
    "delivery_fee": 24.9
  },
  "menu_sections": [
    {
      "id": "section_1",
      "title": "Burger Menüler",
      "products": [
        {
          "id": "prod_1",
          "name": "Double Smash Burger",
          "description": "Çift köfte cheddar peynir",
          "price": 210,
          "badge": "En Çok Satan",
          "image_url": "https://cdn.app.com/burger.png",
          "is_available": true,
          "allergens": ["gluten", "dairy"],
          "calories": 820,
          "option_groups": [
            {
              "id": "drink",
              "title": "İçecek Seçimi",
              "is_required": true,
              "max_selections": 1,
              "options": [
                { "name": "Kola", "price": 0 },
                { "name": "Ayran", "price": 5 }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

---

# 5. Order Service

## POST /api/v1/orders/checkout/preview

### Request

```json
{
  "vendor_id": "vendor_101",
  "items": [
    {
      "product_id": "prod_1",
      "quantity": 2
    }
  ]
}
```

### Response

```json
{
  "items_subtotal": 420,
  "delivery_fee": 24.9,
  "service_fee": 8.99,
  "discount_amount": 40,
  "total_amount": 413.89
}
```

---

## POST /api/v1/orders

### Request

```json
{
  "vendor_id": "vendor_101",
  "address_id": "addr_1",
  "items": [
    {
      "product_id": "prod_1",
      "quantity": 2
    }
  ],
  "payment_method_id": "card_1",
  "note": "Zili çalma"
}
```

### Response

```json
{
  "order_id": "order_555",
  "message": "Order created successfully",
  "vendor_id": "vendor_101",
  "status": "preparing",
  "total_price": 360,
  "address_snapshot": {
    "address_title": "Ev",
    "city": "Antalya",
    "district": "Kepez",
    "neighborhood": "Kültür Mah",
    "street": "3818 Sokak",
    "building_no": "8",
    "floor": "3",
    "apartment_no": "6",
    "address_description": "Kapı zili çalışmıyor",
    "location": {
      "lat": 36.884804,
      "lng": 30.704044
    }
  }
}
```

---

## GET /api/v1/orders?page=1&limit=10

### Response

```json
{
  "page": 1,
  "limit": 10,
  "total": 24,
  "data": [
    {
      "id": "order_555",
      "vendor_name": "Burger Point",
      "status": "DELIVERED",
      "total_amount": 413.89,
      "date_label": "Bugün 13:05",
      "address_snapshot": {
        "address_title": "Ev",
        "city": "Antalya",
        "district": "Kepez",
        "neighborhood": "Kültür Mah",
        "street": "3818 Sokak",
        "building_no": "8",
        "floor": "3",
        "apartment_no": "6",
        "address_description": "Kapı zili çalışmıyor",
        "location": {
          "lat": 36.884804,
          "lng": 30.704044
        }
      },
      "item_summary": "Double Smash Burger x2",
      "delivered_item_count": 2
    }
  ]
}
```

---

## GET /api/v1/orders/{order_id}

### Response

```json
{
  "id": "order_555",
  "status": "DELIVERING",
  "status_label": "Kurye yolda",
  "eta_range": "13:32 - 13:38",
  "active_step_index": 2,
  "address_snapshot": {
    "address_title": "Ev",
    "city": "Antalya",
    "district": "Kepez",
    "neighborhood": "Kültür Mah",
    "street": "3818 Sokak",
    "building_no": "8",
    "floor": "3",
    "apartment_no": "6",
    "address_description": "Kapı zili çalışmıyor",
    "location": {
      "lat": 36.884804,
      "lng": 30.704044
    }
  },
  "steps": [
    { "title": "Sipariş alındı", "is_completed": true },
    { "title": "Hazırlanıyor", "is_completed": true },
    { "title": "Kurye yolda", "is_completed": false },
    { "title": "Teslim edildi", "is_completed": false }
  ]
}
```

---

# 6. Payment Service

## GET /api/v1/payments/methods

### Response

```json
{
  "wallet_balance": 120.5,
  "saved_cards": [
    {
      "id": "card_1",
      "title": "Mastercard",
      "detail": "**** 2741",
      "is_default": true
    }
  ]
}
```

---

## POST /api/v1/payments/cards

### Request

```json
{
  "card_number": "5555444433331111",
  "expire_month": "12",
  "expire_year": "28",
  "cvv": "123"
}
```

### Response

```json
{
  "card_id": "card_2",
  "message": "Card added successfully"
}
```

---

## DELETE /api/v1/payments/cards/{id}

### Response

```json
{
  "message": "Card deleted"
}
```

---

## POST /api/v1/payments/intent

### Request

```json
{
  "order_id": "order_555",
  "payment_method_id": "card_1"
}
```

### Response

```json
{
  "client_secret": "pi_123456_secret_abc"
}
```

---

# 7. Campaign Service

## GET /api/v1/campaigns?page=1&limit=20

### Response

```json
{
  "page": 1,
  "limit": 20,
  "total": 5,
  "data": [
    {
      "id": "camp_1",
      "title": "300 TL üzeri 40 TL indirim",
      "minimum_basket": 300,
      "discount_amount": 40
    }
  ]
}
```

---

## GET /api/v1/vendors/{vendor_id}/campaigns?page=1&limit=20

### Response

```json
{
  "page": 1,
  "limit": 20,
  "total": 3,
  "data": [
    {
      "id": "camp_1",
      "title": "300 TL üzeri 40 TL indirim"
    }
  ]
}
```

---

# 8. Review Service

## GET /api/v1/vendors/{vendor_id}/reviews?page=1&limit=20

### Response

```json
{
  "page": 1,
  "limit": 20,
  "total": 1280,
  "data": [
    {
      "user_name": "Ahmet K.",
      "rating": 5,
      "comment": "Çok hızlı geldi",
      "date": "2026-03-09"
    }
  ]
}
```

---

## POST /api/v1/orders/{order_id}/rating

### Request

```json
{
  "rating": 5,
  "comment": "Çok hızlı ve sıcaktı"
}
```

### Response

```json
{
  "message": "Review submitted successfully"
}
```

---

# 9. Search & Discovery Service

## GET /api/v1/search/discovery

Kullanım: Arama ekranı ilk açıldığında "Geçmiş Aramalar", "Zincir Restoranlar" ve "Mutfaklar" listesini döndürür.

### Response

```json
{
  "sections": [
    {
      "title": "Zincir Restoranlar",
      "type": "HORIZONTAL_LIST",
      "items": [
        { "id": "v_1", "name": "Komagene", "logo_url": "..." },
        { "id": "v_2", "name": "Domino's Pizza", "logo_url": "..." },
        { "id": "v_3", "name": "Burger King", "logo_url": "..." }
      ]
    },
    {
      "title": "Mutfaklar",
      "type": "GRID",
      "items": [
        { "id": "cat_1", "name": "Döner", "image_url": "...", "color_code": "#FDECEC" },
        { "id": "cat_2", "name": "Hamburger", "image_url": "...", "color_code": "#FFF4E5" },
        { "id": "cat_3", "name": "Çiğ Köfte", "image_url": "...", "color_code": "#EEF7ED" }
      ]
    }
  ]
}
```

---

## GET /api/v1/search?q={keyword}&lat={lat}&lng={lng}

Kullanım: Kullanıcı bir kelime yazıp arattığında çalışan ana arama motoru. Restoran içi arama ve global aramaları destekler. (Eğer belirli bir restoran içi arama gerekiyorsa `vendor_id={id}` query parametresi veya `/vendors/{vendor_id}/search` özel endpoint'i de desteklenebilir, aşağıda ortak olarak listelenmesi hedeflenmiştir).

### Response

```json
{
  "total_count": 42,
  "vendors": [
    {
      "id": "vendor_101",
      "name": "Burger Point",
      "rating": 4.7,
      "is_sponsored": true,
      "image_url": "...",
      "eta": "20-30 dk"
    }
  ],
  "products": [
    {
      "id": "prod_5",
      "name": "Double Smash Burger",
      "price_label": "210,00 TL",
      "vendor_name": "Burger Point"
    }
  ]
}
```
