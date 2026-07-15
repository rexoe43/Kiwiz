import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class EnvConfig {
  static EnvConfig? _instance;
  static const _secureStorage = FlutterSecureStorage();
  
  static const String _keySupabaseUrl = 'supabase_url';
  static const String _keySupabaseAnonKey = 'supabase_anon_key';
  
  static String? _cachedSupabaseUrl;
  static String? _cachedSupabaseAnonKey;

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
      
      final envUrl = dotenv.env['SUPABASE_URL'];
      final envAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
      
      if (envUrl == null || envAnonKey == null) {
        throw Exception('Variables de entorno no encontradas en .env');
      }
      
      await _secureStorage.write(key: _keySupabaseUrl, value: envUrl);
      await _secureStorage.write(key: _keySupabaseAnonKey, value: envAnonKey);
      
      _cachedSupabaseUrl = envUrl;
      _cachedSupabaseAnonKey = envAnonKey;
      
      print('Configuración cargada desde .env y almacenada de forma segura');
    } catch (e) {
      print('Error al inicializar configuración: $e');
    }
  }
  
  static Future<String> getSupabaseUrl() async {
    if (_cachedSupabaseUrl != null) {
      return _cachedSupabaseUrl!;
    }
    
    try {
      final stored = await _secureStorage.read(key: _keySupabaseUrl);
      if (stored != null) {
        _cachedSupabaseUrl = stored;
        return stored;
      }
    } catch (e) {
      print('Error al leer almacenamiento seguro: $e');
    }
    
    throw Exception('No se pudo obtener la URL de Supabase');
  }
  
  static Future<String> getSupabaseAnonKey() async {
    if (_cachedSupabaseAnonKey != null) {
      return _cachedSupabaseAnonKey!;
    }
    
    try {
      final stored = await _secureStorage.read(key: _keySupabaseAnonKey);
      if (stored != null) {
        _cachedSupabaseAnonKey = stored;
        return stored;
      }
    } catch (e) {
      print(' Error al leer almacenamiento seguro: $e');
    }
    
    throw Exception('No se pudo obtener la Anon Key de Supabase');
  }
  
  static Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keySupabaseUrl);
    await _secureStorage.delete(key: _keySupabaseAnonKey);
    _cachedSupabaseUrl = null;
    _cachedSupabaseAnonKey = null;
  }
}