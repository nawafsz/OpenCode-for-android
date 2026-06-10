import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ApiService extends ChangeNotifier {
  static const String _baseUrl = 'https://opencode.ai/zen/v1';
  static const String _apiKeyKey = 'opencode_api_key';
  static const String _modelKey = 'opencode_model';
  static const String _defaultModel = 'big-pickle';

  String? _apiKey;
  String _model = _defaultModel;
  bool _isConnected = false;

  String? get apiKey => _apiKey;
  String get model => _model;
  bool get isConnected => _isConnected;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  ApiService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyKey);
    _model = prefs.getString(_modelKey) ?? _defaultModel;
    _isConnected = _apiKey != null && _apiKey!.isNotEmpty;
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    _apiKey = key;
    _isConnected = key.isNotEmpty;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
    notifyListeners();
  }

  Future<void> saveModel(String model) async {
    _model = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelKey, model);
    notifyListeners();
  }

  Future<void> loadSettings() => _loadSettings();

  Future<String> sendMessage({
    required List<ChatMessage> messages,
    String? apiKey,
  }) async {
    final key = apiKey ?? _apiKey;
    if (key == null || key.isEmpty) {
      throw Exception('API key not configured. Go to Settings to add it.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages.map((m) => m.toMap()).toList(),
        'max_tokens': 32000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
        error['error']['message'] ?? 'API Error: ${response.statusCode}',
      );
    }
  }

  Future<bool> testConnection() async {
    if (_apiKey == null || _apiKey!.isEmpty) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': 'Say "ok"'}
          ],
          'max_tokens': 10,
        }),
      );
      _isConnected = response.statusCode == 200;
      notifyListeners();
      return _isConnected;
    } catch (_) {
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }
}
