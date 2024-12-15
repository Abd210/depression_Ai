import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class ChatMessage {
  final String text;
  final bool isUser; // true if user message, false if assistant
  ChatMessage({required this.text, required this.isUser});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health Chatbot',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAssistantTyping = false;

  // Replace this with your backend URL (Flask app endpoint)
  final String apiUrl = "https://flask-chatbot-3uw8.onrender.com/chat";

  Future<void> _sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isAssistantTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_message": userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantReply = data["assistant"] ?? "Sorry, I couldn't understand.";
        await _typeMessage(assistantReply);
      } else {
        setState(() {
          _messages.add(ChatMessage(text: "Error: Unable to connect to the server.", isUser: false));
          _isAssistantTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Error: $e", isUser: false));
        _isAssistantTyping = false;
      });
    }
    _scrollToBottom();
  }

  Future<void> _typeMessage(String fullMessage) async {
    String currentMessage = "";
    for (var word in fullMessage.split(" ")) {
      await Future.delayed(const Duration(milliseconds: 50)); // Adjust typing speed here
      setState(() {
        currentMessage += "$word ";
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.removeLast(); // Remove incomplete assistant message
        }
        _messages.add(ChatMessage(text: currentMessage.trim(), isUser: false));
      });
      _scrollToBottom();
    }

    setState(() {
      _isAssistantTyping = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final bubbleColor = isUser ? Colors.blue[300]! : Colors.white;
    final textColor = isUser ? Colors.white : Colors.black87;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 0),
      bottomRight: Radius.circular(isUser ? 0 : 16),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(isUser: false),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                message.text,
                style: TextStyle(color: textColor),
              ),
            ),
          ),
          if (isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: isUser ? Colors.blue[700] : Colors.green[700],
        child: Icon(
          isUser ? Icons.person : Icons.smart_toy,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          _buildAvatar(isUser: false),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dotAnimation(),
                const SizedBox(width: 4),
                _dotAnimation(delay: 200),
                const SizedBox(width: 4),
                _dotAnimation(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dotAnimation({int delay = 0}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      width: 6,
      height: 6,
      margin: EdgeInsets.only(top: delay == 0 ? 0 : 2),
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mental Health Chatbot'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: _messages.length + (_isAssistantTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isAssistantTyping && index == _messages.length) {
                      return _buildTypingIndicator();
                    } else {
                      return _buildMessageBubble(_messages[index]);
                    }
                  },
                ),
              ),
              _buildInputArea(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: const TextStyle(color: Colors.black54),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, shape: const CircleBorder(),
              padding: const EdgeInsets.all(14),
              elevation: 5,
            ),
            onPressed: () => _sendMessage(_controller.text),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
