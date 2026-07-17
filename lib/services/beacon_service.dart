// lib/services/beacon_service.dart
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class BeaconService {
  static final BeaconService _instance = BeaconService._internal();
  factory BeaconService() => _instance;
  BeaconService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  bool _reported = false;

  
  Future<void> reportUsage() async {
    
    if (_reported) return;
    _reported = true;

    try {
      
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      
      final packageInfo = await PackageInfo.fromPlatform();

      
      final beaconData = {
        'app_name': packageInfo.appName,
        'app_version': packageInfo.version,
        'package_name': packageInfo.packageName,
        'device_model': androidInfo.model,
        'device_brand': androidInfo.brand,
        'android_version': androidInfo.version.release,
        'sdk_version': androidInfo.version.sdkInt,
        'timestamp': DateTime.now().toIso8601String(),
        'is_production': !kDebugMode, // false en debug, true en release
      };

      // Sent to the edge Function
      try {
        await _supabase.functions.invoke(
          'beacon',
          body: beaconData,
        );
        debugPrint('Beacon enviado exitosamente');
      } catch (e) {
        
        debugPrint('Beacon no enviado (error ignorado)');
      }


      
    } catch (e) {
      
      debugPrint('Error en BeaconService: $e');
    }
  }
}