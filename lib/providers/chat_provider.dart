import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supebase_service.dart';

/// Modelo de mensaje
class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Message copyWith({
    String? content,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return Message(
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convertir a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'role': isUser ? 'user' : 'assistant',
      'content': content,
    };
  }
}

/// Provider que maneja el estado reactivo y la comunicación con la Edge Function
class ChatProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty) return false;

    final profile = await _supabaseService.getProfile();
    if (!profile.hasRemainingChats) {
      _error = 'Has agotado tus créditos mensuales de IA';
      notifyListeners();
      return false;
    }

    _messages.add(Message(content: content, isUser: true));
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      
      final history = _messages.map((m) => m.toJson()).toList();
      
      
      final response = await _supabaseClient.functions.invoke(
        'chat-llama', 
        body: {
          'message': content,
          'history': history, 
        },
        method: HttpMethod.post,
      );

      // Procesar respuesta
      if (response.status == 200 && response.data != null) {
        // Extraer la respuesta de la IA
        final aiResponse = response.data['response'] as String?;
        
        if (aiResponse != null && aiResponse.isNotEmpty) {
          _messages.add(Message(content: aiResponse, isUser: false));
          
          final updatedProfile = await _supabaseService.getProfile();
          await _supabaseService.updateChatsUsed(updatedProfile.chatUsed + 1);
          
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          throw Exception('La IA no generó una respuesta válida');
        }
      } else {
        final errorMsg = response.data?['error'] ?? 'Error desconocido';
        throw Exception('Error en la Edge Function: $errorMsg');
      }
      
    } catch (e) {
      // Catch any exception
      _error = 'Error al procesar tu consulta: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      
      
      
      return false;
    }
  }

  /// Limpiar historial de chat
  void clearChatHistory() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}