import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'depir_pin';
  static const _biometricKey = 'depir_biometric';
  static final _localAuth = LocalAuthentication();

  /// آیا PIN تنظیم شده؟
  static Future<bool> hasPIN() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  /// ذخیره PIN
  static Future<void> setPIN(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  /// بررسی PIN
  static Future<bool> checkPIN(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    return stored == pin;
  }

  /// آیا اثر انگشت فعاله؟
  static Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _biometricKey);
    return val == 'true';
  }

  /// فعال/غیرفعال کردن اثر انگشت
  static Future<void> setBiometric(bool enabled) async {
    await _storage.write(
        key: _biometricKey, value: enabled ? 'true' : 'false');
  }

  /// آیا دستگاه اثر انگشت داره؟
  static Future<bool> deviceSupportsBiometric() async {
    final available = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();
    return available && isSupported;
  }

  /// احراز هویت با اثر انگشت
  static Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'برای ورود به دپیر اثر انگشت خود را بگذارید',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// حذف همه داده‌های احراز هویت
  static Future<void> clearAuth() async {
    await _storage.deleteAll();
  }

  /// ✅ وضعیت قفل بودن اپ
  static bool _isUnlocked = false;

  static bool get isUnlocked => _isUnlocked;

  static void unlock() {
    _isUnlocked = true;
  }

  static void lock() {
    _isUnlocked = false;
  }
}