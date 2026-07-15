import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supebase_service.dart';

// Model of the message
class Message {
    final String content;
    final bool isUser;
    final DateTime timestamp;

    Message({
        required this.content,
        required this.isUser,
        DateTime? timestamp,
    }) : timestamp = timestamp ?? DateTime.now();

    // Copy with the new values
    Message copyWith({
        String? content,
        bool? isUser,
        DateTime? timestamp,
    }) {
        return Message(
            contetn: content ?? this.content,
            isUser: isUser ?? this.isUser,
            timestamp: timestamp ?? this.timestamp,
        );
    }
}

// Provider for the chat
class ChatProvider extends ChangeNotifier {
    final SupabaseService _supabaseService = SupabaseService();
}