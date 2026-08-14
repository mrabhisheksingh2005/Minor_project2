import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../../../core/services/chat_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _suggestions = [
    'How to treat tomato blight?',
    'Recipe for neem oil spray',
    'Best fertilizer for rice field',
    'How to store potatoes safely'
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _renameConversation(BuildContext context, ChatProvider provider, String threadId, String currentLabel) {
    final controller = TextEditingController(text: currentLabel);
    showDialog(
      context: context,
      builder: (context) {
        return DiagnosticsDialog(controller: controller, provider: provider, threadId: threadId);
      },
    );
  }

  void _speakMessage(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volume_up, color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Voice Synthesizer (TTS)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              const LinearProgressIndicator(color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Reading aloud crop diagnosis response to farmer...',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                text.length > 100 ? '${text.substring(0, 100)}...' : text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Stop Playback'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startVoiceListening(BuildContext context, ChatProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return VoiceListeningSheet(provider: provider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    _scrollToBottom();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Agri AI Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Conversation Drawer',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New Chat',
            onPressed: () {
              chatProvider.startNewThread();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Started a new conversation thread!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.4),
              ),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Chat History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Start New Conversation'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  chatProvider.startNewThread();
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: chatProvider.threads.length,
                itemBuilder: (context, idx) {
                  final thread = chatProvider.threads[idx];
                  final isActive = thread.id == chatProvider.currentThreadId;
                  return ListTile(
                    selected: isActive,
                    selectedTileColor: colorScheme.primary.withOpacity(0.08),
                    leading: Icon(
                      isActive ? Icons.chat_bubble : Icons.chat_bubble_outline,
                      color: isActive ? colorScheme.primary : Colors.grey,
                    ),
                    title: Text(
                      thread.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _renameConversation(context, chatProvider, thread.id, thread.label),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => chatProvider.deleteThread(thread.id),
                        ),
                      ],
                    ),
                    onTap: () {
                      chatProvider.switchThread(thread.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.messages.isEmpty
                ? _buildEmptyState(context, colorScheme, theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      return _buildMessageBubble(context, message, colorScheme, theme);
                    },
                  ),
          ),
          if (chatProvider.isTyping) _buildTypingIndicator(colorScheme),
          if (chatProvider.messages.length <= 1 && !chatProvider.isTyping)
            _buildSuggestions(context, chatProvider, colorScheme),
          _buildInputField(context, chatProvider, colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colors, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: colors.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No messages yet', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Type or speak a question below to begin', style: TextStyle(color: theme.hintColor)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    ColorScheme colors,
    ThemeData theme,
  ) {
    final isUser = message.isUser;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isUser ? colors.primary : colors.surfaceVariant.withOpacity(0.7);
    final textColor = isUser ? Colors.white : colors.onSurfaceVariant;
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 18, color: Colors.green),
                  tooltip: 'Read Aloud',
                  onPressed: () => _speakMessage(context, message.text),
                ),
                const SizedBox(width: 4),
              ],
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(color: textColor, height: 1.4, fontSize: 13.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(timeStr, style: TextStyle(color: theme.hintColor, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            'Agri AI is typing',
            style: TextStyle(fontSize: 12, color: colors.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, ChatProvider provider, ColorScheme colors) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        itemBuilder: (context, idx) {
          final text = _suggestions[idx];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(text, style: const TextStyle(fontSize: 12)),
              backgroundColor: colors.primary.withOpacity(0.06),
              side: BorderSide(color: colors.primary.withOpacity(0.15)),
              onPressed: () {
                provider.sendMessage(text);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    ChatProvider provider,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.15))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.mic, color: colors.primary, size: 26),
            tooltip: 'Speak Query',
            onPressed: () => _startVoiceListening(context, provider),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Ask Agri AI anything...',
                  border: InputBorder.none,
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    provider.sendMessage(text.trim());
                    _messageController.clear();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: colors.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
                final text = _messageController.text.trim();
                if (text.isNotEmpty) {
                  provider.sendMessage(text);
                  _messageController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DiagnosticsDialog extends StatelessWidget {
  const DiagnosticsDialog({
    super.key,
    required this.controller,
    required this.provider,
    required this.threadId,
  });

  final TextEditingController controller;
  final ChatProvider provider;
  final String threadId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Conversation'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Chat Label'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              provider.renameThread(threadId, controller.text.trim());
            }
            Navigator.pop(context);
          },
          child: const Text('Rename'),
        ),
      ],
    );
  }
}

class VoiceListeningSheet extends StatefulWidget {
  final ChatProvider provider;
  const VoiceListeningSheet({super.key, required this.provider});

  @override
  State<VoiceListeningSheet> createState() => _VoiceListeningSheetState();
}

class _VoiceListeningSheetState extends State<VoiceListeningSheet> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _listeningStatus = "Listening to crop query...";
  String _transcribingText = "";
  bool _isFinished = false;

  final List<String> _voiceShortcuts = [
    "How to manage early tomato blight in UP?",
    "Best NPK ratio for potato leaves?",
    "Organic spray recipe for chili thrips.",
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Simulate transcribing typing
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _transcribingText = "How to treat ";
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        setState(() {
          _transcribingText = "How to treat late tomato blight in monsoon?";
          _listeningStatus = "Speech processed successfully!";
          _isFinished = true;
          _animController.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text(
            _listeningStatus,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 24),
          // Pulsing microphone wave animation
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Container(
                padding: EdgeInsets.all(16 + (_animController.value * 12)),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: colors.primary,
                  child: const Icon(Icons.mic, color: Colors.white, size: 36),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _transcribingText.isEmpty ? "Speak now..." : _transcribingText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: _transcribingText.isEmpty ? FontStyle.italic : FontStyle.normal,
                color: _transcribingText.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (!_isFinished) ...[
            Text(
              'Or tap a quick command:',
              style: TextStyle(fontSize: 11, color: theme.hintColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._voiceShortcuts.map((phrase) => Card(
              elevation: 0,
              color: colors.primary.withOpacity(0.04),
              child: ListTile(
                dense: true,
                title: Text(phrase, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.keyboard_voice, size: 16),
                onTap: () {
                  widget.provider.sendMessage(phrase);
                  Navigator.pop(context);
                },
              ),
            )),
          ] else ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: () {
                widget.provider.sendMessage(_transcribingText);
                Navigator.pop(context);
              },
              child: const Text('Send Voice Input'),
            ),
          ],
        ],
      ),
    );
  }
}
