import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/localization_service.dart';
import '../widgets/message_bubble.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final List<Map<String, String>> _sessions = [];
  String _currentSessionId = 'default';

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final loc = context.read<LocalizationService>();
    final s = loc.strings;
    setState(() {
      _messages.add(ChatMessage(
        id: 'welcome',
        role: MessageRole.assistant,
        content: '# ${s.welcomeTitle}\n\n${s.welcomeDesc}\n\n---\n> ${s.getApiKey}',
        timestamp: DateTime.now(),
      ));
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

  void _newSession() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _sessions.insert(0, {
        'id': id,
        'title': 'Session ${_sessions.length + 1}',
      });
      _currentSessionId = id;
      _messages.clear();
    });
    _addWelcomeMessage();
  }

  void _switchSession(String id) {
    setState(() {
      _currentSessionId = id;
      _messages.clear();
    });
    _addWelcomeMessage();
  }

  void _deleteSession(String id) {
    setState(() {
      _sessions.removeWhere((s) => s['id'] == id);
      if (_currentSessionId == id) {
        _currentSessionId = 'default';
        _messages.clear();
        _addWelcomeMessage();
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final api = context.read<ApiService>();
    final loc = context.read<LocalizationService>();
    final s = loc.strings;

    if (!api.hasApiKey) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.errorNoKey),
            action: SnackBarAction(
              label: s.settings,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),
        );
      }
      return;
    }

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    final loadingMessage = ChatMessage(
      id: 'loading',
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );

    setState(() {
      _messages.add(userMessage);
      _messages.add(loadingMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final responseContent = await api.sendMessage(
        messages: _messages.where((m) => m.id != 'loading').toList(),
      );

      setState(() {
        _messages.removeWhere((m) => m.id == 'loading');
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: MessageRole.assistant,
          content: responseContent,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.id == 'loading');
        _messages.add(ChatMessage(
          id: 'error',
          role: MessageRole.assistant,
          content: '**${s.errorApi}:** $e',
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _showQuickActions() {
    final loc = context.read<LocalizationService>();
    final s = loc.strings;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(s.newSession),
              onTap: () { Navigator.pop(ctx); _newSession(); },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: Text(s.welcomeWrite),
              onTap: () { Navigator.pop(ctx); _insertPrompt(s.quickWrite); },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(s.welcomeDebug),
              onTap: () { Navigator.pop(ctx); _insertPrompt(s.quickDebug); },
            ),
            ListTile(
              leading: const Icon(Icons.explore),
              title: Text(s.welcomeExplain),
              onTap: () { Navigator.pop(ctx); _insertPrompt(s.quickExplain); },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: Text(s.welcomeOptimize),
              onTap: () { Navigator.pop(ctx); _insertPrompt(s.quickOptimize); },
            ),
          ],
        ),
      ),
    );
  }

  void _insertPrompt(String prompt) {
    _messageController.text = prompt;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: prompt.length),
    );
  }

  void _clearChat() {
    final loc = context.read<LocalizationService>();
    final s = loc.strings;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.clearConfirm),
        content: Text(s.clearConfirmMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
              });
              _addWelcomeMessage();
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final api = context.watch<ApiService>();
    final loc = context.watch<LocalizationService>();
    final s = loc.strings;

    return Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.code, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('OpenCode AI',
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold)),
                            Text('${_sessions.length + 1} ${s.sessions}',
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () { Navigator.pop(context); _newSession(); },
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(s.newSession),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(s.sessions.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontWeight: FontWeight.w600)),
                    ),
                    ListTile(
                      selected: _currentSessionId == 'default',
                      leading: const Icon(Icons.chat),
                      title: Text(s.currentSession),
                      subtitle: Text('${_messages.length} ${s.messages}'),
                      onTap: () { Navigator.pop(context); _switchSession('default'); },
                    ),
                    ...List.generate(_sessions.length, (i) {
                      final ses = _sessions[i];
                      return ListTile(
                        selected: _currentSessionId == ses['id'],
                        leading: const Icon(Icons.chat_outlined),
                        title: Text(ses['title']!),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => _deleteSession(ses['id']!),
                        ),
                        onTap: () { Navigator.pop(context); _switchSession(ses['id']!); },
                      );
                    }),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
                ),
                child: ListTile(
                  leading: Icon(Icons.settings_outlined,
                      color: theme.colorScheme.outline),
                  title: Text(s.settings,
                      style: TextStyle(color: theme.colorScheme.outline)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Row(
            children: [
              Builder(
                builder: (ctx) => InkWell(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.widgets_outlined, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: api.isConnected
                      ? Colors.green.withAlpha(30)
                      : Colors.orange.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: api.isConnected ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      api.model,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: api.isConnected ? Colors.green.shade700 : Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_comment_outlined),
              tooltip: s.newSession,
              onPressed: _newSession,
            ),
            IconButton(
              icon: const Icon(Icons.auto_fix_high),
              tooltip: s.quickActions,
              onPressed: _showQuickActions,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: s.clearChat,
              onPressed: _clearChat,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.code, size: 64,
                              color: theme.colorScheme.outlineVariant),
                          const SizedBox(height: 16),
                          Text(s.noMessages,
                              style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.outline)),
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            onPressed: _showQuickActions,
                            icon: const Icon(Icons.auto_fix_high, size: 18),
                            label: Text(s.quickActions),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) =>
                          MessageBubble(message: _messages[index]),
                    ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 8, right: 8, top: 8,
                bottom: MediaQuery.of(context).padding.bottom + 8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 44,
                    child: InkWell(
                      onTap: _showQuickActions,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(Icons.add, size: 20,
                            color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      maxLines: 6,
                      minLines: 1,
                      onSubmitted: _isLoading ? null : (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: s.askAboutCode,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44, width: 44,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white,
                              ),
                            )
                  : const Icon(Icons.arrow_upward),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
