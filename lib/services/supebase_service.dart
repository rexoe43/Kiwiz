import 'dart:async';
import 'package:supebase_flutter/supebase_flutter.dart';
import '../models/profile_model.dart';

class SupebaseService {
    final SupabaseClient _client = Supabase.instance.client;

    Stream<ProfileModel> profileStream() {
        return _client
            .from('profiles')
            .stream(primaryKey: ['id'])
            .eq('id', _client.auth.currentUser!.id)
            .map((data ) {
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

    Future<ProfileModel> getProfile() async {
        try {
            final response = await _client
            .from('profiles')
            .select()
            .eq('id', _client.auth.currentUser!.id)
            .single();

        return ProfileModel.fromJson(response);
        } catch (e) {
            return const ProfileModel(
                chatLimit: 20,
                chatUsed: 0,
                hasRemainingChats: true,
            );
        }
    }

    Future<void> updateChatsUsed(int newValue) async {
        await _client
        .from('profiles')
        .update({'chat_used': newValue})
        .eq('id', _client.auth.currenUser!.id);
    }

    Future<void> signOut() async {
        await _client.auth.signOut();
    }
}