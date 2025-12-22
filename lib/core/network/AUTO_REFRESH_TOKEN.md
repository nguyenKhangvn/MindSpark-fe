# Auto Refresh Token Implementation

## 🎯 Mục đích

Tự động refresh access token khi hết hạn (401 Unauthorized) mà không cần user login lại.

## 🔄 Luồng hoạt động

```
Request API với access token
         ↓
    DioApiClient
         ↓
  Backend trả về 401
         ↓
Error Interceptor phát hiện 401
         ↓
Gọi onRefreshToken() callback
         ↓
AuthRepository.refreshToken()
         ↓
POST /auth/refresh (không qua interceptor)
         ↓
Lưu access token & refresh token mới
         ↓
Retry request ban đầu với token mới
         ↓
Trả về kết quả cho user
```

## 📝 Implementation Details

### 1. **DioApiClient** ([dio_api_client.dart](dio_api_client.dart))

- **onRefreshToken callback**: Gọi khi gặp 401
- **Error Interceptor**: Tự động retry request sau khi refresh
- **postWithoutInterceptor()**: Tránh circular loop khi refresh

### 2. **AuthRepository** ([auth_repository_impl.dart](../../features/auth/data/repositories/auth_repository_impl.dart))

- **refreshToken()**: Gọi API `/auth/refresh`
- Lưu token mới vào TokenStorage
- Clear tokens nếu refresh thất bại

### 3. **Dependency Injection** ([injection_container.dart](../di/injection_container.dart))

- Đăng ký AuthRepository trước
- Đăng ký DioApiClient
- Setup callback sau khi tất cả dependencies đã ready

## 🚀 Cách sử dụng

**Không cần làm gì!** Hệ thống tự động xử lý:

```dart
// User gọi API bình thường
await deckCubit.getDecks();

// Nếu access token hết hạn:
// 1. Backend trả về 401
// 2. DioApiClient tự động refresh token
// 3. Retry request với token mới
// 4. User nhận được dữ liệu (không biết gì về refresh)
```

## ⚠️ Lưu ý

### Tránh Circular Dependency

- Refresh token request **KHÔNG** được qua interceptor
- Sử dụng `postWithoutInterceptor()` thay vì `post()`

### Khi nào Clear Tokens?

- Refresh token hết hạn
- Refresh token invalid
- Network error khi refresh

### Backend Requirements

API `/auth/refresh` phải:

- Accept: `{ "refreshToken": "..." }`
- Return: `{ "accessToken": "...", "refreshToken": "..." }`

## 🧪 Testing

```dart
// Test 1: Access token hết hạn
// Expected: Tự động refresh và retry

// Test 2: Refresh token hết hạn
// Expected: Clear tokens và navigate to login

// Test 3: Network error khi refresh
// Expected: Clear tokens và show error
```

## 📊 Flow Diagram

```
┌─────────────────────────────────────────────────────┐
│                    User Action                      │
│              (e.g., getDecks())                     │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
         ┌────────────────┐
         │  DioApiClient  │
         │   GET /decks   │
         └────────┬───────┘
                  │
                  ▼
        ┌─────────────────┐
        │     Backend     │
        │  Returns 401    │
        └─────────┬───────┘
                  │
                  ▼
     ┌────────────────────────┐
     │  Error Interceptor     │
     │  Detects 401           │
     └────────┬───────────────┘
              │
              ▼
   ┌──────────────────────────┐
   │  onRefreshToken()        │
   │  callback triggered      │
   └──────────┬───────────────┘
              │
              ▼
   ┌──────────────────────────┐
   │  AuthRepository          │
   │  .refreshToken()         │
   └──────────┬───────────────┘
              │
              ▼
   ┌──────────────────────────┐
   │  POST /auth/refresh      │
   │  (no interceptor)        │
   └──────────┬───────────────┘
              │
     ┌────────┴────────┐
     │                 │
     ▼                 ▼
 Success           Failure
     │                 │
     │                 ▼
     │        ┌────────────────┐
     │        │ Clear Tokens   │
     │        │ Return false   │
     │        └────────────────┘
     │
     ▼
┌─────────────────────┐
│  Save new tokens    │
│  Return true        │
└─────────┬───────────┘
          │
          ▼
   ┌──────────────────┐
   │  Retry original  │
   │  request with    │
   │  new token       │
   └──────────┬───────┘
              │
              ▼
     ┌────────────────┐
     │   Success!     │
     │ User gets data │
     └────────────────┘
```

---

**Created**: December 20, 2025  
**Status**: ✅ Production Ready
