import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../services/supebase_service.dart';
import '../models/profile_model.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ProfileModel? _profile;


  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  
  Future<void> _loadProfile() async {
    try {
      final profile = await SupabaseService().getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al cargar el perfil: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _profile == null) return;

    if (!_profile!.hasRemainingChats) {
      _showErrorSnackBar('Has agotado tus créditos mensuales de IA');
      return;
    }

    final chatProvider = context.read<ChatProvider>();
    chatProvider.clearError();

    final success = await chatProvider.sendMessage(message);
    
    if (success && mounted) {
      _messageController.clear();
      _scrollToBottom();
      await _loadProfile(); // Recargar perfil
    }

    if (mounted && chatProvider.error != null) {
      _showErrorSnackBar(chatProvider.error!);
      chatProvider.clearError();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Kiwiz',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      backgroundColor: Colors.green.shade700,
      elevation: 2,
      actions: [
        StreamBuilder<ProfileModel>(
          stream: SupabaseService().profileStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final profile = snapshot.data!;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Consultas de IA: ${profile.chatUsed} / ${profile.chatLimit}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 16),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  
  
  Widget _buildChatBubble(Message message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? Colors.green.shade600 : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
              ),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistory() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          itemCount: chatProvider.messages.length,
          itemBuilder: (context, index) {
            return _buildChatBubble(chatProvider.messages[index]);
          },
        );
      },
    );
  }

  
  
  Widget _buildBottomInputBar() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final isLoading = chatProvider.isLoading;
        final hasRemainingChats = _profile?.hasRemainingChats ?? false;
        final isEnabled = !isLoading && hasRemainingChats;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: isEnabled,
                  maxLines: null,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    
                    hintText: isEnabled
                        ? 'Escribe tu consulta...'
                        : 'Has agotado tus créditos mensuales de IA',
                    hintStyle: TextStyle(
                      color: isEnabled ? Colors.grey.shade500 : Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isEnabled ? Colors.grey.shade100 : Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: isEnabled ? _sendMessage : null,
                  icon: const Icon(Icons.send_rounded),
                  color: isEnabled ? Colors.green.shade600 : Colors.grey.shade400,
                  style: IconButton.styleFrom(
                    backgroundColor: isEnabled 
                        ? Colors.green.shade50 
                        : Colors.grey.shade100,
                    shape: const CircleBorder(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildChatHistory(),
          ),
          _buildBottomInputBar(),
        ],
      ),
    );
  }
}