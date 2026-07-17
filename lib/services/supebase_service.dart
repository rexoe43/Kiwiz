import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class SupabaseService {
  static SupabaseClient? _client;
  
  
  
  static SupabaseClient get client {
    _client ??= Supabase.instance.client;
    return _client!;
  }
  
  Future<bool> isAuthenticated() async {
    try {
      final session = client.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }
  
  // Log in
  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Log out
  Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  
  User? getCurrentUser() {
    return client.auth.currentUser;
  }
  
  // Stream for real time
  Stream<ProfileModel> profileStream() {
    final user = getCurrentUser();
    if (user == null) {
      return Stream.value(const ProfileModel(
        chatLimit: 20,
        chatUsed: 0,
        hasRemainingChats: true,
      ));
    }
    
    return client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map((data) {
          if (data.isEmpty) {
            return const ProfileModel(
              chatLimit: 20,
              chatUsed: 0,
              hasRemainingChats: true,
            );
          }
          return ProfileModel.fromJson(data.first);
        });
  }

  // Obtain the user profile
  Future<ProfileModel> getProfile() async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return const ProfileModel(
          chatLimit: 20,
          chatUsed: 0,
          hasRemainingChats: true,
        );
      }
      
      final response = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (response == null) {
        // Crear perfil si no existe
        await createProfile(user.id);
        return const ProfileModel(
          chatLimit: 20,
          chatUsed: 0,
          hasRemainingChats: true,
        );
      }
      
      return ProfileModel.fromJson(response);
    } catch (e) {
      debugPrint(' Error al obtener perfil: $e');
      return const ProfileModel(
        chatLimit: 20,
        chatUsed: 0,
        hasRemainingChats: true,
      );
    }
  }

  /// New perfil for the user
  Future<void> createProfile(String userId) async {
    try {
      await client.from('profiles').insert({
        'id': userId,
        'chat_limit': 20,
        'chats_used': 0,
        'has_remaining_chats': true,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint(' Error al crear perfil: $e');
    }
  }

  /// Update the used credits
  Future<void> updateChatsUsed(int newValue) async {
    try {
      final user = getCurrentUser();
      if (user == null) return;
      
      await client
          .from('profiles')
          .update({
            'chats_used': newValue,
            'has_remaining_chats': newValue < 20,
          })
          .eq('id', user.id);
    } catch (e) {
      debugPrint('Error al actualizar créditos: $e');
    }
  }
}