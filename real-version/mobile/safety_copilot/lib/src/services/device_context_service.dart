import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class DeviceContext {
  DeviceContext({
    required this.platform,
    required this.batteryLevel,
    required this.isCharging,
    required this.lat,
    required this.lng,
  });

  final String platform;
  final int? batteryLevel;
  final bool? isCharging;
  final double? lat;
  final double? lng;
}

class DeviceContextService {
  DeviceContextService({
    Battery? battery,
  }) : _battery = battery ?? Battery();

  final Battery _battery;

  Future<DeviceContext> readContext() async {
    final batteryLevel = await _readBatteryLevel();
    final isCharging = await _readCharging();
    final location = await _readLocation();
    return DeviceContext(
      platform: Platform.isAndroid ? 'android' : 'ios',
      batteryLevel: batteryLevel,
      isCharging: isCharging,
      lat: location?.latitude,
      lng: location?.longitude,
    );
  }

  Future<int?> _readBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (_) {
      return null;
    }
  }

  Future<bool?> _readCharging() async {
    try {
      final state = await _battery.batteryState;
      return state == BatteryState.charging ||
          state == BatteryState.full;
    } catch (_) {
      return null;
    }
  }

  Future<Position?> _readLocation() async {
    final locationPerm = await permission.Permission.locationWhenInUse.request();
    if (!locationPerm.isGranted) {
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
