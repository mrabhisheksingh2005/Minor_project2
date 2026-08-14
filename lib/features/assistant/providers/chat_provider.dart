import 'package:flutter/material.dart';
import '../../../core/services/chat_service.dart';

class ChatThread {
  final String id;
  String label;
  final List<ChatMessage> messages;

  ChatThread({
    required this.id,
    required this.label,
    required this.messages,
  });
}

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final List<ChatThread> _threads = [];
  String? _currentThreadId;
  bool _isTyping = false;

  List<ChatThread> get threads => _threads;
  String? get currentThreadId => _currentThreadId;
  bool get isTyping => _isTyping;

  // Dynamically resolve messages of the active thread
  List<ChatMessage> get messages {
    if (_threads.isEmpty) return const [];
    final active = _threads.firstWhere(
      (t) => t.id == _currentThreadId,
      orElse: () => _threads.first,
    );
    return active.messages;
  }

  ChatProvider() {
    // Start initial default thread
    startNewThread(initialLabel: "Welcome Conversation");
  }

  void startNewThread({String? initialLabel}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final thread = ChatThread(
      id: id,
      label: initialLabel ?? 'New Discussion',
      messages: [
        ChatMessage(
          text: "Hello! I am AgriVision's AI Assistant. You can ask me about crop diseases, pest controls, fertilizers, watering advice, or how to use our scanning features. How can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
        )
      ],
    );
    _threads.add(thread);
    _currentThreadId = id;
    notifyListeners();
  }

  void switchThread(String id) {
    if (_threads.any((t) => t.id == id)) {
      _currentThreadId = id;
      notifyListeners();
    }
  }

  void renameThread(String id, String newLabel) {
    final idx = _threads.indexWhere((t) => t.id == id);
    if (idx != -1 && newLabel.trim().isNotEmpty) {
      _threads[idx].label = newLabel.trim();
      notifyListeners();
    }
  }

  void deleteThread(String id) {
    if (_threads.length <= 1) {
      // Keep at least one active thread
      clearChat();
      return;
    }
    _threads.removeWhere((t) => t.id == id);
    if (_currentThreadId == id) {
      _currentThreadId = _threads.last.id;
    }
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final activeThread = _threads.firstWhere(
      (t) => t.id == _currentThreadId,
      orElse: () => _threads.first,
    );

    // Auto-rename chat from first user message if still default label
    if (activeThread.label == 'New Discussion' || activeThread.label == 'Welcome Conversation') {
      final words = text.split(' ');
      final title = words.take(4).join(' ');
      activeThread.label = title.length > 24 ? '${title.substring(0, 22)}...' : title;
    }

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    activeThread.messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    try {
      final responseText = await _chatService.getResponse(text);
      activeThread.messages.add(ChatMessage(
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (_) {
      activeThread.messages.add(ChatMessage(
        text: "Sorry, I encountered an issue processing your query. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    final activeThread = _threads.firstWhere(
      (t) => t.id == _currentThreadId,
      orElse: () => _threads.first,
    );
    activeThread.messages.clear();
    activeThread.messages.add(ChatMessage(
      text: "Hello! I am AgriVision's AI Assistant. You can ask me about crop diseases, pest controls, fertilizers, watering advice, or how to use our scanning features. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    activeThread.label = "Reset Conversation";
    notifyListeners();
  }
}
