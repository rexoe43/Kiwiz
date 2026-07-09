// User Perfil 

class ProfileModel {
    final int chatLimit;
    final int chatUsed;
    final bool hasRemainingChats;

    const ProfileModel({
        required this.chatLimit,
        required this.chatUsed,
        required this.hasRemainingChats
    });

    // JSON
    factory ProfileModel.fromJson(Map<String, dynamic> json){
        return ProfileModel(
            chatLimit: json['chat_limit'] ?? 20,
            chatUsed: json['chat_used'] ?? 0,
            hasRemainingChats: json['has_remaining_chats'] ?? true,
        );
    }

    // Converting to JSON
    Map<String, dynamic> toJson() {
        return {
            'chat_limit': chatLimit,
            'chats_used': chatUsed,
            'has_remaining_chats': hasRemainingChats,
        };
    }

    // Copy
    ProfileModel copyWith({
        int? chatLimit,
        int? chatUsed,
        bool? hasRemainingChats,
    }) {
        return ProfileModel(
            chatLimit: chatLimit ?? this.chatLimit,
            chatUsed: chatUsed ?? this.chatUsed,
            hasRemainingChats: hasRemainingChats ?? this.hasRemainingChats,
        );
    }
}