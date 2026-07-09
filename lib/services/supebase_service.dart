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
    
}