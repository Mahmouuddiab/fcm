import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Simulates loading conversation history from a remote server database
  Future<void> _loadChatHistory() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _messages.addAll([
          {
            "text": "Hello! I have a question regarding my booking request.",
            "isMe": false,
            "time": "11:02 AM"
          },
          {
            "text": "Hi there! Sure thing, how can I help you today?",
            "isMe": true,
            "time": "11:05 AM"
          },
          {
            "text": "Is the pickup point the same one listed on the map receipt details?",
            "isMe": false,
            "time": "11:06 AM"
          },
        ]);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        "text": text,
        "isMe": true,
        "time": "Just now",
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Mock an immediate auto-reply answer for interactive testing
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            "text": "Thank you for message! Our representative will check this shortly.",
            "isMe": false,
            "time": "Just now",
          });
        });
        _scrollToBottom();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Support Agent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Chat ID: ${widget.chatId ?? "N/A"}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Chat bubble list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(
                  text: message['text'],
                  isMe: message['isMe'],
                  time: message['time'],
                );
              },
            ),
          ),
          // Input entry row bar panel
          _buildMessageInputRow(),
        ],
      ),
    );
  }

  Widget _buildChatBubble({required String text, required bool isMe, required String time}) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceVariant = Colors.grey[200];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, // <-- FIXED: Changed ; to ,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isMe ? primaryColor : surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black45,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Theme.of(context).cardColor,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}