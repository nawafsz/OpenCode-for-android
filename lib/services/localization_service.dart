import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const Locale defaultLocale = Locale('en');

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static const _strings = {
    'en': _EnglishStrings(),
    'ar': _ArabicStrings(),
  };

  Locale _locale = defaultLocale;

  Locale get locale => _locale;
  bool get isRtl => _locale.languageCode == 'ar';

  LocalizationService() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  BaseStrings get strings => _strings[_locale.languageCode] ?? _strings['en']!;
}

abstract class BaseStrings {
  const BaseStrings();
  String get appName;
  String get chat;
  String get files;
  String get settings;
  String get newSession;
  String get clearChat;
  String get quickActions;
  String get noMessages;
  String get startConversation;
  String get askAboutCode;
  String get thinking;
  String get opencodeAI;
  String get poweredBy;
  String get getApiKey;
  String get settingsApiConfig;
  String get settingsApiDesc;
  String get apiKey;
  String get model;
  String get modelId;
  String get modelQuickSelect;
  String get testConnection;
  String get connected;
  String get failed;
  String get testing;
  String get save;
  String get saved;
  String get cancel;
  String get delete;
  String get appearance;
  String get darkMode;
  String get lightMode;
  String get language;
  String get english;
  String get arabic;
  String get about;
  String get version;
  String get apiEndpoint;
  String get welcomeTitle;
  String get welcomeDesc;
  String get welcomeWrite;
  String get welcomeDebug;
  String get welcomeExplain;
  String get welcomeOptimize;
  String get quickWrite;
  String get quickDebug;
  String get quickExplain;
  String get quickOptimize;
  String get errorNoKey;
  String get errorApi;
  String get noFiles;
  String get openFile;
  String get recentFiles;
  String get saveToDevice;
  String get clearConfirm;
  String get clearConfirmMsg;
  String get sessions;
  String get currentSession;
  String get messages;
  String get deleteSession;
  String get en;
  String get ar;
  String get codeAssistant;
  String get getStarted;
  String get skip;
  String get continue_;
  String get darkModeEnabled;
  String get lightModeEnabled;
  String get changeLanguage;
  String get appDescription;
}

class _EnglishStrings extends BaseStrings {
  const _EnglishStrings();
  @override final String appName = 'OpenCode AI';
  @override final String chat = 'Chat';
  @override final String files = 'Files';
  @override final String settings = 'Settings';
  @override final String newSession = 'New session';
  @override final String clearChat = 'Clear chat';
  @override final String quickActions = 'Quick actions';
  @override final String noMessages = 'No messages yet';
  @override final String startConversation = 'Start a conversation';
  @override final String askAboutCode = 'Ask about code...';
  @override final String thinking = 'Thinking...';
  @override final String opencodeAI = 'OpenCode AI';
  @override final String poweredBy = 'Powered by OpenCode Zen (big-pickle)';
  @override final String getApiKey = 'Get your free API key at opencode.ai/zen';
  @override final String settingsApiConfig = 'API Configuration';
  @override final String settingsApiDesc = 'Connect to OpenCode Zen API for AI-powered coding assistance.';
  @override final String apiKey = 'API Key';
  @override final String model = 'Model';
  @override final String modelId = 'Model ID';
  @override final String modelQuickSelect = 'Quick select:';
  @override final String testConnection = 'Test connection';
  @override final String connected = 'Connected';
  @override final String failed = 'Failed';
  @override final String testing = 'Testing...';
  @override final String save = 'Save';
  @override final String saved = 'Settings saved';
  @override final String cancel = 'Cancel';
  @override final String delete = 'Delete';
  @override final String appearance = 'Appearance';
  @override final String darkMode = 'Dark mode';
  @override final String lightMode = 'Light mode';
  @override final String language = 'Language';
  @override final String english = 'English';
  @override final String arabic = 'العربية';
  @override final String about = 'About';
  @override final String version = 'v1.0.0';
  @override final String apiEndpoint = 'API Endpoint: https://opencode.ai/zen/v1';
  @override final String welcomeTitle = 'Welcome to OpenCode AI';
  @override final String welcomeDesc = 'Your AI-powered coding assistant. Write, debug, and optimize code with the help of AI.';
  @override final String welcomeWrite = 'Write code';
  @override final String welcomeDebug = 'Debug code';
  @override final String welcomeExplain = 'Explain code';
  @override final String welcomeOptimize = 'Optimize code';
  @override final String quickWrite = 'Write a function that';
  @override final String quickDebug = 'Help me debug this code';
  @override final String quickExplain = 'Explain this code';
  @override final String quickOptimize = 'Review and optimize this code';
  @override final String errorNoKey = 'API key not configured. Go to Settings to add it.';
  @override final String errorApi = 'API Error';
  @override final String noFiles = 'No files yet';
  @override final String openFile = 'Open a code file';
  @override final String recentFiles = 'RECENT FILES';
  @override final String saveToDevice = 'Save to device';
  @override final String clearConfirm = 'Clear conversation';
  @override final String clearConfirmMsg = 'Delete all messages in this session?';
  @override final String sessions = 'SESSIONS';
  @override final String currentSession = 'Current session';
  @override final String messages = 'messages';
  @override final String deleteSession = 'Delete session';
  @override final String en = 'English';
  @override final String ar = 'العربية';
  @override final String codeAssistant = 'Code Assistant';
  @override final String getStarted = 'Get Started';
  @override final String skip = 'Skip';
  @override final String continue_ = 'Continue';
  @override final String darkModeEnabled = 'Dark mode enabled';
  @override final String lightModeEnabled = 'Light mode enabled';
  @override final String changeLanguage = 'Change language';
  @override final String appDescription = 'An open source AI coding agent for your Android device.';
}

class _ArabicStrings extends BaseStrings {
  const _ArabicStrings();
  @override final String appName = 'OpenCode AI';
  @override final String chat = 'المحادثة';
  @override final String files = 'الملفات';
  @override final String settings = 'الإعدادات';
  @override final String newSession = 'جلسة جديدة';
  @override final String clearChat = 'مسح المحادثة';
  @override final String quickActions = 'إجراءات سريعة';
  @override final String noMessages = 'لا توجد رسائل بعد';
  @override final String startConversation = 'ابدأ محادثة';
  @override final String askAboutCode = 'اسأل عن كود...';
  @override final String thinking = 'جارٍ التفكير...';
  @override final String opencodeAI = 'OpenCode AI';
  @override final String poweredBy = 'مدعوم من OpenCode Zen (big-pickle)';
  @override final String getApiKey = 'احصل على مفتاح API مجاني من opencode.ai/zen';
  @override final String settingsApiConfig = 'إعدادات API';
  @override final String settingsApiDesc = 'اتصل بـ OpenCode Zen API للحصول على مساعدة برمجة بالذكاء الاصطناعي.';
  @override final String apiKey = 'مفتاح API';
  @override final String model = 'النموذج';
  @override final String modelId = 'معرف النموذج';
  @override final String modelQuickSelect = 'اختيار سريع:';
  @override final String testConnection = 'اختبار الاتصال';
  @override final String connected = 'متصل';
  @override final String failed = 'فشل';
  @override final String testing = 'جارٍ الاختبار...';
  @override final String save = 'حفظ';
  @override final String saved = 'تم حفظ الإعدادات';
  @override final String cancel = 'إلغاء';
  @override final String delete = 'حذف';
  @override final String appearance = 'المظهر';
  @override final String darkMode = 'الوضع الداكن';
  @override final String lightMode = 'الوضع الفاتح';
  @override final String language = 'اللغة';
  @override final String english = 'English';
  @override final String arabic = 'العربية';
  @override final String about = 'حول';
  @override final String version = 'الإصدار 1.0.0';
  @override final String apiEndpoint = 'نقطة النهاية: https://opencode.ai/zen/v1';
  @override final String welcomeTitle = 'مرحباً بك في OpenCode AI';
  @override final String welcomeDesc = 'مساعد البرمجة بالذكاء الاصطناعي. اكتب، صحح، وحسّن الأكواد بمساعدة AI.';
  @override final String welcomeWrite = 'كتابة كود';
  @override final String welcomeDebug = 'تصحيح الأخطاء';
  @override final String welcomeExplain = 'شرح الكود';
  @override final String welcomeOptimize = 'تحسين الكود';
  @override final String quickWrite = 'اكتب دالة تقوم بـ';
  @override final String quickDebug = 'ساعدني في تصحيح هذا الكود';
  @override final String quickExplain = 'اشرح لي هذا الكود';
  @override final String quickOptimize = 'راجع وحسّن هذا الكود';
  @override final String errorNoKey = 'مفتاح API غير مضبوط. اذهب إلى الإعدادات لإضافته.';
  @override final String errorApi = 'خطأ في API';
  @override final String noFiles = 'لا توجد ملفات بعد';
  @override final String openFile = 'افتح ملف كود';
  @override final String recentFiles = 'الملفات الحديثة';
  @override final String saveToDevice = 'حفظ على الجهاز';
  @override final String clearConfirm = 'مسح المحادثة';
  @override final String clearConfirmMsg = 'هل تريد حذف جميع الرسائل في هذه الجلسة؟';
  @override final String sessions = 'الجلسات';
  @override final String currentSession = 'الجلسة الحالية';
  @override final String messages = 'رسائل';
  @override final String deleteSession = 'حذف الجلسة';
  @override final String en = 'English';
  @override final String ar = 'العربية';
  @override final String codeAssistant = 'مساعد برمجة';
  @override final String getStarted = 'ابدأ الآن';
  @override final String skip = 'تخطي';
  @override final String continue_ = 'متابعة';
  @override final String darkModeEnabled = 'الوضع الداكن مفعل';
  @override final String lightModeEnabled = 'الوضع الفاتح مفعل';
  @override final String changeLanguage = 'تغيير اللغة';
  @override final String appDescription = 'عامل ذكاء اصطناعي مفتوح المصدر للبرمجة على جهاز الأندرويد الخاص بك.';
}
