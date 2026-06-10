import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/localization_service.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeChanged;

  const SettingsScreen({
    super.key,
    this.themeMode = ThemeMode.system,
    this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  bool _obscureKey = true;
  bool _saving = false;
  bool _testing = false;
  bool? _testResult;

  static const List<Map<String, String>> _presetModels = [
    {'id': 'big-pickle', 'name': 'Big Pickle', 'desc': 'Free, 200K context'},
    {'id': 'deepseek-v4-flash-free', 'name': 'DeepSeek V4 Flash Free', 'desc': 'Free model'},
    {'id': 'gpt-5.4-nano', 'name': 'GPT 5.4 Nano', 'desc': 'Fast & cheap'},
    {'id': 'gpt-5.4-mini', 'name': 'GPT 5.4 Mini', 'desc': 'Balanced'},
    {'id': 'gpt-5.1-codex', 'name': 'GPT 5.1 Codex', 'desc': 'Best for coding'},
    {'id': 'claude-sonnet-4-5', 'name': 'Claude Sonnet 4.5', 'desc': 'Anthropic'},
    {'id': 'gemini-3-pro', 'name': 'Gemini 3 Pro', 'desc': 'Google'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final api = context.read<ApiService>();
    await api.loadSettings();
    _apiKeyController.text = api.apiKey ?? '';
    _modelController.text = api.model;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final loc = context.read<LocalizationService>();
      final api = context.read<ApiService>();
      if (_apiKeyController.text.isNotEmpty) {
        await api.saveApiKey(_apiKeyController.text.trim());
      }
      if (_modelController.text.isNotEmpty) {
        await api.saveModel(_modelController.text.trim());
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.strings.saved),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _testConnection() async {
    if (_apiKeyController.text.trim().isEmpty) {
      final loc = context.read<LocalizationService>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.strings.errorNoKey)),
      );
      return;
    }

    setState(() {
      _testing = true;
      _testResult = null;
    });

    try {
      final api = context.read<ApiService>();
      await api.saveApiKey(_apiKeyController.text.trim());
      if (_modelController.text.isNotEmpty) {
        await api.saveModel(_modelController.text.trim());
      }
      final result = await api.testConnection();
      setState(() {
        _testResult = result;
        _testing = false;
      });
    } catch (_) {
      setState(() {
        _testResult = false;
        _testing = false;
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.watch<LocalizationService>();
    final isRtl = loc.isRtl;
    final s = loc.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settings),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check, size: 18),
            label: Text(s.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            theme: theme,
            icon: Icons.key,
            title: s.settingsApiConfig,
            children: [
              Text(s.settingsApiDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline)),
              const SizedBox(height: 16),
              TextField(
                controller: _apiKeyController,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  labelText: s.apiKey,
                  hintText: 'sk-...',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKey ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _testing ? null : _testConnection,
                      icon: _testing
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _testResult == true
                                  ? Icons.check_circle
                                  : _testResult == false
                                      ? Icons.error
                                      : Icons.wifi_find,
                              size: 18,
                            ),
                      label: Text(_testing
                          ? s.testing
                          : _testResult == true
                              ? s.connected
                              : _testResult == false
                                  ? s.failed
                                  : s.testConnection),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sectionCard(
            theme: theme,
            icon: Icons.smart_toy_outlined,
            title: s.model,
            children: [
              Text(s.modelId,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline)),
              const SizedBox(height: 8),
              TextField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: s.modelId,
                  hintText: 'big-pickle',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.model_training, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              Text(s.modelQuickSelect,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _presetModels.map<Widget>((m) {
                  final selected = _modelController.text == m['id'];
                  return ChoiceChip(
                    label: Text(m['name']!, style: const TextStyle(fontSize: 12)),
                    avatar: Icon(
                      selected ? Icons.check : Icons.smart_toy_outlined,
                      size: 14,
                    ),
                    selected: selected,
                    onSelected: (_) => _modelController.text = m['id']!,
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sectionCard(
            theme: theme,
            icon: Icons.palette_outlined,
            title: s.appearance,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.brightness_6, color: theme.colorScheme.primary),
                title: Text(s.darkMode),
                trailing: Switch(
                  value: widget.themeMode == ThemeMode.dark,
                  onChanged: (v) {
                    widget.onThemeChanged?.call(
                      v ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),
              if (widget.themeMode != ThemeMode.system)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.themeMode == ThemeMode.dark
                        ? s.darkModeEnabled
                        : s.lightModeEnabled,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.language, color: theme.colorScheme.primary),
                title: Text(s.language),
                subtitle: Text(isRtl ? s.arabic : s.english),
                trailing: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'en', label: Text(s.en)),
                    ButtonSegment(value: 'ar', label: Text(s.ar)),
                  ],
                  selected: {isRtl ? 'ar' : 'en'},
                  onSelectionChanged: (selected) {
                    final code = selected.first;
                    loc.setLocale(Locale(code));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sectionCard(
            theme: theme,
            icon: Icons.info_outline,
            title: s.about,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('OpenCode AI'),
                subtitle: Text(s.version),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.apiEndpoint),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
