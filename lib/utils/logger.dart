import 'package:flutter/foundation.dart';

class AppLogger {
    static void info(String message) {
        if (kDebugMode) {
            print('INFO: $message');
        }
    }

    static void warning(String message) {
        if (kDebugMode) {
            print('WARNING: $message');
        }
    }

    static void error(String message, [dynamic error]) {
        if (kDebugMode) {
            print('ERROR: $message');
            if (error != null) {
                print(' Details: $error');
            }
        }
    }

    static void success(String message) {
        if (kDebugMode) {
            print('SUCCESS: $message');
        }
    }

    static void debug(String message) {
        if (kDebugMode) {
            print('DEBUG: $message');
        }
    }
}