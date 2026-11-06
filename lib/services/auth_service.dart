import 'dart:convert';
import 'dart:io';

/// Local (offline) authentication service.
/// Accounts are persisted on-device in a small JSON file inside the app's
/// private sandbox, with salted + hashed passwords. No backend and no extra
/// packages are required — suitable for a demo / assignment.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _salt = 'sqp-kicsit-242201089';

  Map<String, dynamic> _data = {'users': <String, dynamic>{}, 'session': null};
  bool _loaded = false;
  String? currentEmail;
  String? currentName;

  File get _file => File('${Directory.systemTemp.path}/sqp_auth.json');

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      if (await _file.exists()) {
        _data = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
      }
    } catch (_) {/* corrupt or unavailable storage -> start fresh */}
  }

  Future<void> _save() async {
    try {
      await _file.writeAsString(jsonEncode(_data));
    } catch (_) {/* storage unavailable (e.g. web) -> in-memory only */}
  }

  Map<String, dynamic> get _users =>
      (_data['users'] as Map).cast<String, dynamic>();

  /// Loads persisted session. Returns true if a user is logged in.
  Future<bool> init() async {
    await _load();
    currentEmail = _data['session'] as String?;
    currentName = currentEmail == null ? null : _users[currentEmail]?['name'];
    return currentEmail != null;
  }

  bool get isLoggedIn => currentEmail != null;

  /// 64-bit FNV-1a hash applied iteratively over salt + password.
  static String hashPassword(String password) {
    var bytes = utf8.encode('$_salt:$password');
    var h = BigInt.parse('cbf29ce484222325', radix: 16);
    final prime = BigInt.parse('100000001b3', radix: 16);
    final mask = (BigInt.one << 64) - BigInt.one;
    for (var round = 0; round < 1000; round++) {
      for (final b in bytes) {
        h = ((h ^ BigInt.from(b)) * prime) & mask;
      }
    }
    return h.toRadixString(16).padLeft(16, '0');
  }

  /// Returns null on success, or an error message.
  Future<String?> signup(String name, String email, String password) async {
    await _load();
    email = email.trim().toLowerCase();
    if (_users.containsKey(email)) {
      return 'An account with this email already exists.';
    }
    _users[email] = {'name': name.trim(), 'password': hashPassword(password)};
    await _save();
    return null;
  }

  /// Returns null on success, or an error message.
  Future<String?> login(String email, String password) async {
    await _load();
    email = email.trim().toLowerCase();
    final user = _users[email];
    if (user == null) return 'No account found for this email.';
    if (user['password'] != hashPassword(password)) return 'Incorrect password.';
    currentEmail = email;
    currentName = user['name'];
    _data['session'] = email;
    await _save();
    return null;
  }

  Future<void> logout() async {
    currentEmail = null;
    currentName = null;
    _data['session'] = null;
    await _save();
  }

  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email';
  }

  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
