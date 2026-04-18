import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/alert_model.dart';
import '../models/circle_model.dart';
import '../models/device_model.dart';
import '../models/trip_model.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/device_context_service.dart';
import '../services/local_notification_service.dart';

class AppState extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final DeviceContextService _deviceContextService = DeviceContextService();
  final LocalNotificationService _notificationService = LocalNotificationService();
  final Uuid _uuid = const Uuid();

  SharedPreferences? _prefs;
  Timer? _heartbeatTimer;

  bool initialized = false;
  bool busy = false;
  String? error;
  String status = 'Ready';

  String? token;
  String? deviceId;
  UserModel? user;
  TripModel? activeTrip;
  List<CircleModel> circles = [];
  List<AlertModel> alerts = [];
  List<DeviceModel> devices = [];

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  Future<void> bootstrap() async {
    _prefs = await SharedPreferences.getInstance();
    token = _prefs?.getString('token');
    deviceId = _prefs?.getString('device_id') ?? _uuid.v4();
    await _prefs?.setString('device_id', deviceId!);
    await _notificationService.init();

    if (isAuthenticated) {
      await _registerDevice();
      await refresh();
      _startHeartbeatTicker();
    }

    initialized = true;
    notifyListeners();
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    final cleanPhone = _normalizePhone(phone);
    await _runBusy(() async {
      final payload = await _api.post('/auth/login', body: {
        'phone': cleanPhone,
        'password': password,
      });
      token = payload['token'] as String;
      await _prefs?.setString('token', token!);
      await _registerDevice();
      await refresh();
      _startHeartbeatTicker();
      status = 'Logged in';
    });
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    final cleanPhone = _normalizePhone(phone);
    await _runBusy(() async {
      await _api.post('/auth/register', body: {
        'name': name,
        'phone': cleanPhone,
        'password': password,
      });
      final payload = await _api.post('/auth/login', body: {
        'phone': cleanPhone,
        'password': password,
      });
      token = payload['token'] as String;
      await _prefs?.setString('token', token!);
      await _registerDevice();
      await refresh();
      _startHeartbeatTicker();
      status = 'Account created and logged in';
    });
  }

  Future<void> logout() async {
    token = null;
    user = null;
    activeTrip = null;
    circles = [];
    alerts = [];
    devices = [];
    _heartbeatTimer?.cancel();
    await _prefs?.remove('token');
    status = 'Logged out';
    notifyListeners();
  }

  Future<void> refresh() async {
    if (!isAuthenticated) {
      return;
    }

    await _runBusy(() async {
      final responses = await Future.wait([
        _api.get('/auth/me', token: token),
        _api.get('/circles/my', token: token),
        _api.get('/alerts/my', token: token),
        _api.get('/trips/active/me', token: token),
        _api.get('/devices/my', token: token),
      ]);

      user = UserModel.fromJson(responses[0]['user'] as Map<String, dynamic>);
      circles = ((responses[1]['circles'] as List<dynamic>? ?? const []))
          .map((item) => CircleModel.fromJson(item as Map<String, dynamic>))
          .toList();
      alerts = ((responses[2]['alerts'] as List<dynamic>? ?? const []))
          .map((item) => AlertModel.fromJson(item as Map<String, dynamic>))
          .toList();
      final tripJson = responses[3]['trip'];
      activeTrip = tripJson == null
          ? null
          : TripModel.fromJson(tripJson as Map<String, dynamic>);
      devices = ((responses[4]['devices'] as List<dynamic>? ?? const []))
          .map((item) => DeviceModel.fromJson(item as Map<String, dynamic>))
          .toList();

      status = 'Dashboard synced';
    });
  }

  Future<void> createCircle(String name) async {
    await _runBusy(() async {
      await _api.post(
        '/circles',
        token: token,
        body: {'name': name},
      );
      await refresh();
      status = 'Circle created';
    });
  }

  Future<void> addMember({
    required String circleId,
    required String phone,
    required String label,
  }) async {
    final cleanPhone = _normalizePhone(phone);
    await _runBusy(() async {
      await _api.post(
        '/circles/$circleId/members',
        token: token,
        body: {
          'phone': cleanPhone,
          'label': label,
        },
      );
      await refresh();
      status = 'Member added';
    });
  }

  Future<void> startTrip({
    required String circleId,
    required String destinationName,
    required double destinationLat,
    required double destinationLng,
    required int etaSeconds,
  }) async {
    await _runBusy(() async {
      final context = await _deviceContextService.readContext();
      final payload = await _api.post(
        '/trips/start',
        token: token,
        body: {
          'circleId': circleId,
          'destinationName': destinationName,
          'destinationLat': destinationLat,
          'destinationLng': destinationLng,
          'etaSeconds': etaSeconds,
          'routePoints': [
            {
              'lat': context.lat ?? destinationLat,
              'lng': context.lng ?? destinationLng,
            },
            {
              'lat': destinationLat,
              'lng': destinationLng,
            }
          ],
        },
      );
      activeTrip = TripModel.fromJson(payload['trip'] as Map<String, dynamic>);
      await sendLocationPing();
      await refresh();
      status = 'Trip started';
    });
  }

  Future<void> sendLocationPing() async {
    if (activeTrip == null) {
      throw ApiException('No active trip');
    }

    await _runBusy(() async {
      final context = await _deviceContextService.readContext();
      final payload = await _api.post(
        '/trips/${activeTrip!.id}/location',
        token: token,
        body: {
          'lat': context.lat ?? activeTrip!.destinationLat,
          'lng': context.lng ?? activeTrip!.destinationLng,
          'speedMps': 4.0,
          'batteryLevel': context.batteryLevel,
          'isCharging': context.isCharging ?? false,
        },
      );

      final generated = payload['generatedAlerts'] as List<dynamic>? ?? const [];
      for (final raw in generated) {
        final alert = AlertModel.fromJson(raw as Map<String, dynamic>);
        await _notificationService.show(
          title: 'Safety Alert: ${alert.type.toUpperCase()}',
          body: alert.message,
        );
      }
      await sendHeartbeat();
      await refresh();
      status = 'Location updated';
    });
  }

  Future<void> sendHeartbeat() async {
    if (!isAuthenticated || deviceId == null) {
      return;
    }
    final context = await _deviceContextService.readContext();
    await _api.post(
      '/devices/heartbeat',
      token: token,
      body: {
        'deviceId': deviceId,
        'tripId': activeTrip?.id,
        'batteryLevel': context.batteryLevel,
        'isCharging': context.isCharging,
        'lat': context.lat,
        'lng': context.lng,
      },
    );
  }

  Future<void> triggerSos({required bool silent}) async {
    if (activeTrip == null) {
      throw ApiException('No active trip');
    }
    await _runBusy(() async {
      final context = await _deviceContextService.readContext();
      await _api.post(
        '/trips/${activeTrip!.id}/sos',
        token: token,
        body: {
          'mode': silent ? 'silent' : 'normal',
          'lat': context.lat,
          'lng': context.lng,
          'note': silent ? 'Silent trigger from mobile app' : 'Manual SOS from mobile app',
        },
      );
      await refresh();
      status = silent ? 'Silent SOS sent' : 'SOS sent';
    });
  }

  Future<void> markArrived() async {
    if (activeTrip == null) {
      return;
    }
    await _runBusy(() async {
      await _api.post('/trips/${activeTrip!.id}/arrive', token: token);
      await refresh();
      status = 'Trip marked arrived';
    });
  }

  Future<void> endTrip() async {
    if (activeTrip == null) {
      return;
    }
    await _runBusy(() async {
      await _api.post('/trips/${activeTrip!.id}/end', token: token);
      await refresh();
      status = 'Trip ended';
    });
  }

  Future<void> acknowledgeAlert(String alertId) async {
    await _runBusy(() async {
      await _api.post('/alerts/$alertId/ack', token: token);
      await refresh();
      status = 'Alert acknowledged';
    });
  }

  Future<void> _registerDevice() async {
    if (!isAuthenticated || deviceId == null) {
      return;
    }
    final context = await _deviceContextService.readContext();
    await _api.post(
      '/devices/register',
      token: token,
      body: {
        'deviceId': deviceId,
        'fcmToken': 'placeholder-fcm-token-$deviceId',
        'platform': context.platform,
        'appVersion': '1.0.0',
      },
    );
  }

  void _startHeartbeatTicker() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 45),
      (_) {
        sendHeartbeat().catchError((_) {});
      },
    );
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    error = null;
    busy = true;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      if (e is ApiException) {
        error = e.message;
      } else {
        error = e.toString();
      }
      status = 'Action failed';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  String _normalizePhone(String input) {
    return input.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }
}
