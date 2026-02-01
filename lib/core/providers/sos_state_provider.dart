import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

@immutable
class SosState {
  final bool isLoaded;
  final bool isActive;
  final String? sosId;
  final String? location;
  final int? activatedAtMillis;

  const SosState({
    required this.isLoaded,
    required this.isActive,
    this.sosId,
    this.location,
    this.activatedAtMillis,
  });

  const SosState.initial()
      : isLoaded = false,
        isActive = false,
        sosId = null,
        location = null,
        activatedAtMillis = null;
}

class SosStateNotifier extends StateNotifier<SosState> {
  SosStateNotifier() : super(const SosState.initial()) {
    Future.microtask(() async {
      await _loadFromStorage(reload: true);
    });
  }

  static const String _sosActiveKey = 'sos_active';
  static const String _activeSosIdKey = 'active_sos_id';
  static const String _activeLocationKey = 'active_location';
  static const String _activeSosTimestampKey = 'active_sos_timestamp';

  Timer? _expiryTimer;

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  Future<void> activate({
    required String sosId,
    String? location,
    int? activatedAtMillis,
  }) async {
    final activatedAt = activatedAtMillis ?? DateTime.now().millisecondsSinceEpoch;
    state = SosState(
      isLoaded: true,
      isActive: true,
      sosId: sosId,
      location: location,
      activatedAtMillis: activatedAt,
    );
    await _saveToStorage();
    _scheduleExpiry(activatedAt);
  }

  Future<void> deactivate() async {
    await _setInactive();
  }

  Future<void> refreshFromStorage() async {
    await _loadFromStorage(reload: true);
  }

  void _scheduleExpiry(int activatedAtMillis) {
    _expiryTimer?.cancel();
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(activatedAtMillis)
        .add(AppConstants.alertTtl);
    final remaining = expiresAt.difference(DateTime.now());

    if (remaining.isNegative || remaining == Duration.zero) {
      _setInactive();
      return;
    }

    _expiryTimer = Timer(remaining, () {
      _setInactive();
    });
  }

  Future<void> _loadFromStorage({bool reload = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (reload) {
        await prefs.reload();
      }

      final isActive = prefs.getBool(_sosActiveKey) ?? false;
      final sosId = prefs.getString(_activeSosIdKey);
      final location = prefs.getString(_activeLocationKey);
      final storedTimestamp = prefs.getInt(_activeSosTimestampKey);
      final nowMillis = DateTime.now().millisecondsSinceEpoch;

      if (isActive) {
        final activatedAt = storedTimestamp ?? nowMillis;
        final age = Duration(milliseconds: nowMillis - activatedAt);

        if (age >= AppConstants.alertTtl) {
          await _setInactive(markLoaded: true);
          return;
        }

        state = SosState(
          isLoaded: true,
          isActive: true,
          sosId: sosId,
          location: location,
          activatedAtMillis: activatedAt,
        );

        _scheduleExpiry(activatedAt);

        if (storedTimestamp == null) {
          await _saveToStorage();
        }
      } else {
        state = const SosState(isLoaded: true, isActive: false);
        _expiryTimer?.cancel();
        if (sosId != null || location != null || storedTimestamp != null) {
          await _saveToStorage();
        }
      }
    } catch (e) {
      debugPrint('SOS state load failed: $e');
      state = const SosState(isLoaded: true, isActive: false);
    }
  }

  Future<void> _setInactive({bool markLoaded = false}) async {
    _expiryTimer?.cancel();
    _expiryTimer = null;
    state = SosState(
      isLoaded: markLoaded ? true : state.isLoaded,
      isActive: false,
    );
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_sosActiveKey, state.isActive);
      if (state.sosId != null) {
        await prefs.setString(_activeSosIdKey, state.sosId!);
      } else {
        await prefs.remove(_activeSosIdKey);
      }
      if (state.location != null) {
        await prefs.setString(_activeLocationKey, state.location!);
      } else {
        await prefs.remove(_activeLocationKey);
      }
      if (state.activatedAtMillis != null) {
        await prefs.setInt(_activeSosTimestampKey, state.activatedAtMillis!);
      } else {
        await prefs.remove(_activeSosTimestampKey);
      }
    } catch (e) {
      debugPrint('SOS state save failed: $e');
    }
  }
}

final sosStateProvider = StateNotifierProvider<SosStateNotifier, SosState>((ref) {
  return SosStateNotifier();
});
