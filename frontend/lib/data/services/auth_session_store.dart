import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_models.dart';

class AuthSessionStore {
  static final AuthSessionStore _instance = AuthSessionStore._internal();

  factory AuthSessionStore() => _instance;

  AuthSessionStore._internal();

  static const _sessionKey = 'auth_session';
  static const _onboardingKey = 'auth_onboarding_seen';

  final ValueNotifier<AuthSession?> sessionNotifier = ValueNotifier(null);
  final ValueNotifier<bool> onboardingSeenNotifier = ValueNotifier(false);

  AuthSession? get session => sessionNotifier.value;

  bool get isLoggedIn => session != null && !session!.isExpired;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawSession = prefs.getString(_sessionKey);
    if (rawSession != null && rawSession.isNotEmpty) {
      sessionNotifier.value = AuthSession.fromRawJson(rawSession);
    }
    onboardingSeenNotifier.value = prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> saveSession(AuthSession session) async {
    sessionNotifier.value = session;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, session.toRawJson());
  }

  Future<void> clearSession() async {
    sessionNotifier.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> setOnboardingSeen() async {
    onboardingSeenNotifier.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }
}
