import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supebase_service.dart';

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
}

// Provider for the chat funcionality
class ChatProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Clear the error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  
  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty) return false;

    // Verify if the user has remaining chats
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
      
      final supabase = Supabase.instance.client;
      final response = await supabase.functions.invoke(
        'chat-llama',
        body: {
          'message': content,
          'history': _messages
          .where((m) => !m.isUser)
          .map((m) => m.content)
          .toList(),
        },
      );

      
      if (response.data != null) {
        final aiResponse = response.data['response'] as String? ?? 
                          'Lo siento, no pude procesar tu consulta.';
        
        _messages.add(Message(content: aiResponse, isUser: false));
        
        // Update the credits
        await _supabaseService.updateChatsUsed(
          (await _supabaseService.getProfile()).chatUsed + 1
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Respuesta vacía de la IA');
      }
    } catch (e) {
      _error = 'Error al procesar tu consulta: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      
      // If the user fail to delete the message
      // _messages.removeLast();
      // notifyListeners();
      
      return false;
    }
  }

  // Clear the History
  void clearChatHistory() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}