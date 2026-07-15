import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../services/supabase_service.dart';
import '../models/profile_model.dart';

clas ChatScreen extends StatefulWidget {
    const ChatScreen({super.key});

    @override
    State<ChatScreen> createState() => _ChatScreensState();
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
        _messagesController.dispose();
        _scrollController.dispose();
        super.dispose();
    }

    Future<void> _loadProfile() async {
        try{
            final profile = await SupbaseService().getProfile();
            if (mounted) {
                setState(() {
                    _profile = profile;
                });
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
            if ( message.isEmpty || _profile == null) return;

            if (!_prfile!.hasRemainingChats) {
                _showErrorSnackBar('Has agotado tus créditos mensuales de IA');
                return;
            }

            final chatProvider = context.read<ChatProvider>();
            chatProvider.clearError();

            final sucerss = await chatProvider.sendMessage(message);

            if (sucess && mounted) {
                _messageContrller.clear();
                _scrollToBottom();
                await _loadProfile();
            }

            if (mounted && chatProvider.error != null) {
                _showErrorSnackBar(chatProvider.error!);
                chatProvider.clearError();
            }
        }

        void _scrollToBottom() {
            WidgetsBinding.instance.addPostFrameCallback((_) {
                if ( _scrollController.hasClients){
                    _scrollController.animateTo(
                        _scrollController.position.maxScrolExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                    );
                }
            });
        }

        
    }
}