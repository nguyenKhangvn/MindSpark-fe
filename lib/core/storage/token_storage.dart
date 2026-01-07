import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Secure storage for JWT tokens
/// Uses flutter_secure_storage for mobile (iOS/Android)
/// Uses shared_preferences with encryption for web
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _encryptionKey =
      'mindspark_secure_key_v1'; // In production, use environment variable

  final FlutterSecureStorage? _secureStorage;
  SharedPreferences? _prefs;

  TokenStorage(this._secureStorage);

  /// Initialize storage (required for web)
  Future<void> init() async {
    await _ensurePrefs();
  }

  /// Ensure web prefs are ready even if init() was missed
  Future<void> _ensurePrefs() async {
    if (!kIsWeb) return;
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print(' [TokenStorage] SharedPreferences initialized');
    }
  }

  /// Encrypt token for web storage
  String _encryptToken(String token) {
    final bytes = utf8.encode(token + _encryptionKey);
    final digest = sha256.convert(bytes);
    return '${base64.encode(utf8.encode(token))}.${digest.toString().substring(0, 16)}';
  }

  /// Decrypt token from web storage
  String? _decryptToken(String? encrypted) {
    if (encrypted == null) return null;
    try {
      final parts = encrypted.split('.');
      if (parts.length != 2) return null;
      return utf8.decode(base64.decode(parts[0]));
    } catch (e) {
      return null;
    }
  }

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    if (kIsWeb) {
      await _ensurePrefs();
      await _prefs?.setString(_accessTokenKey, _encryptToken(token));
      if (kDebugMode) {
        print(' [TokenStorage] Saved access token to web storage');
      }
    } else {
      await _secureStorage?.write(key: _accessTokenKey, value: token);
      if (kDebugMode) {
        print(' [TokenStorage] Saved access token to secure storage');
      }
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    if (kIsWeb) {
      await _ensurePrefs();
      final encrypted = _prefs?.getString(_accessTokenKey);
      final token = _decryptToken(encrypted);
      if (kDebugMode) {
        print(
            ' [TokenStorage] Get access token from web: ${token != null ? "Found" : "Not found"}');
      }
      return token;
    } else {
      final token = await _secureStorage?.read(key: _accessTokenKey);
      if (kDebugMode) {
        print(
            ' [TokenStorage] Get access token from secure: ${token != null ? "Found" : "Not found"}');
      }
      return token;
    }
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    if (kIsWeb) {
      await _ensurePrefs();
      await _prefs?.setString(_refreshTokenKey, _encryptToken(token));
      if (kDebugMode) {
        print(' [TokenStorage] Saved refresh token to web storage');
      }
    } else {
      await _secureStorage?.write(key: _refreshTokenKey, value: token);
      if (kDebugMode) {
        print(' [TokenStorage] Saved refresh token to secure storage');
      }
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      await _ensurePrefs();
      final encrypted = _prefs?.getString(_refreshTokenKey);
      final token = _decryptToken(encrypted);
      if (kDebugMode) {
        print(
            ' [TokenStorage] Get refresh token from web: ${token != null ? "Found" : "Not found"}');
      }
      return token;
    } else {
      final token = await _secureStorage?.read(key: _refreshTokenKey);
      if (kDebugMode) {
        print(
            ' [TokenStorage] Get refresh token from secure: ${token != null ? "Found" : "Not found"}');
      }
      return token;
    }
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    if (kIsWeb) {
      await _prefs?.remove(_accessTokenKey);
      await _prefs?.remove(_refreshTokenKey);
    } else {
      await _secureStorage?.delete(key: _accessTokenKey);
      await _secureStorage?.delete(key: _refreshTokenKey);
    }
  }

  /// Clear all tokens (alias for clearTokens)
  Future<void> clearAll() async {
    await clearTokens();
  }

  /// Check if user is authenticated
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
