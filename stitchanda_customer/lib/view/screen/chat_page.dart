import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../base/bottom_nav_scaffold.dart';
import '../../data/models/tailor_model.dart';
import '../../controller/tailor_cubit.dart';

class ChatPage extends StatefulWidget {
  final Tailor? tailor;
  const ChatPage({super.key, this.tailor});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _chatSearchController = TextEditingController();

  // Simple in-memory messages store for demo
  final List<_Message> _messages = [
    _Message(text: 'Hi! How can I help you?', fromTailor: true, time: DateTime.now().subtract(const Duration(minutes: 5))),
    _Message(text: 'I want to stitch a 3-piece suit.', fromTailor: false, time: DateTime.now().subtract(const Duration(minutes: 4))),
    _Message(text: 'Sure! Do you have a preferred style?', fromTailor: true, time: DateTime.now().subtract(const Duration(minutes: 3))),
  ];

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _chatSearchController.addListener(() {
      setState(() {
        _searchQuery = _chatSearchController.text.trim().toLowerCase();
      });
    });

    if (widget.tailor != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottomSafe();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _chatSearchController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, fromTailor: false, time: DateTime.now()));
    });
    _textController.clear();

    // Optional: simulate tailor reply
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_Message(text: 'Got it! I\'ll share options shortly.', fromTailor: true, time: DateTime.now()));
      });
      _scrollToBottom();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    _scrollToBottomSafe();
  }

  void _scrollToBottomSafe() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      try {
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          _scrollController.animateTo(
            maxScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final inShell = context.findAncestorWidgetOfExactType<BottomNavScaffold>() != null;
    if (!inShell) {
      return const BottomNavScaffold(initialIndex: 0);
    }

    final tailor = widget.tailor;

    // If no tailor passed, show chats inbox list driven by TailorCubit (Firestore data)
    if (tailor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                controller: _chatSearchController,
                decoration: const InputDecoration(
                  hintText: 'Search tailors',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<TailorCubit, TailorState>(
                builder: (context, state) {
                  if (state is TailorLoading || state is TailorInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is TailorError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Failed to load tailors: ${state.message}'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => context.read<TailorCubit>().loadTailors(),
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    );
                  }

                  final loaded = state as TailorLoaded;
                  final allTailors = loaded.tailors;
                  final filtered = _searchQuery.isEmpty
                      ? allTailors
                      : allTailors.where((t) =>
                          t.name.toLowerCase().contains(_searchQuery) ||
                          t.area.toLowerCase().contains(_searchQuery) ||
                          t.category.toLowerCase().contains(_searchQuery),
                        ).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No tailors found'));
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        leading: _Avatar(name: t.name),
                        title: Text(
                          t.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          t.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chat_outlined, color: Color(0xFFD29356)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(tailor: t),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // Conversation view with selected tailor
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _Avatar(name: tailor.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tailor.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    tailor.area,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isMe = !m.fromTailor;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFD29356) : const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(m.time),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.black45,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _MessageInput(
            controller: _textController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(
          left: 12,
          right: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 12,
          top: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefixIcon: Icon(Icons.message_outlined),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              width: 48,
              child: ElevatedButton(
                onPressed: onSend,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6D7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return 'T';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _Message {
  final String text;
  final bool fromTailor;
  final DateTime time;
  _Message({required this.text, required this.fromTailor, required this.time});
}
