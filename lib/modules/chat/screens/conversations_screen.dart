import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stichanda_customer/modules/chat/cubit/chat_cubit.dart';
import 'package:stichanda_customer/modules/chat/models/conversation.dart';

import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    if (uid.isNotEmpty) {
      context.read<ChatCubit>().loadConversations(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        buildWhen: (previous, current) =>
            current is ConversationsLoading ||
            current is ConversationsLoaded ||
            current is ChatError,
        builder: (context, state) {

          if (state is ConversationsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ConversationsLoaded) {
            final list = state.conversations;

            if (list.isEmpty) return Center(child: Text('No conversations yet'));
            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final Conversation conv = list[index];
                final other = conv.participants.firstWhere((e) => e != uid, orElse: () => '');

                return _ConversationTile(conversation: conv, otherUid: other);
              },
            );
          } else if (state is ChatError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          // Preserve current UI for other chat states (e.g., ChatPeerLoaded)
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ConversationTile extends StatefulWidget {
  final Conversation conversation;
  final String otherUid;
  const _ConversationTile({required this.conversation, required this.otherUid});

  @override
  State<_ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<_ConversationTile> {
  String? name;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadPeer(widget.otherUid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (p, n) => n is ChatPeerLoaded && n.uid == widget.otherUid,
      listener: (context, state) {
        if (state is ChatPeerLoaded) {
          setState(() {
            name = state.name;
            imageUrl = state.imageUrl;
          });
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty && imageUrl!='') ? NetworkImage(imageUrl!) : null,
          child: (imageUrl == null || imageUrl!.isEmpty)
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(name ?? 'User'),
        subtitle: Text(widget.conversation.lastMessage ?? ''),
        trailing: Text(_formatTime(widget.conversation.lastUpdated)),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: widget.conversation)));
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}'
        ;
    return '${dt.year}/${dt.month}/${dt.day}';
  }
}
