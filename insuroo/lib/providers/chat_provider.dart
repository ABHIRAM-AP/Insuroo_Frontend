import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/voice_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final VoiceService _voiceService = VoiceService();

  final List<ChatMessage> _messages = [];

  bool _isLoading = false;
  bool _isServerOnline = false;
  bool _isRecording = false;
  bool _isSpeaking = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isServerOnline => _isServerOnline;
  bool get isRecording => _isRecording;
  bool get isSpeaking => _isSpeaking;

  ChatProvider() {
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    _isServerOnline = await _apiService.checkHealth();
    notifyListeners();
  }

  Future<void> sendMessage(String question) async {
    if (question.trim().isEmpty) return;

    _messages.add(ChatMessage(
      text: question,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    try {
      final answer = await _apiService.askQuestion(question);
      _messages.add(ChatMessage(
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        text: 'Sorry, I encountered an error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // ─── Voice ─────────────────────────────────────────────────────────────

  Future<void> startVoiceInput() async {
    try {
      await _voiceService.startRecording();
      _isRecording = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Voice start error: $e');
    }
  }

  Future<void> stopVoiceInput() async {
    if (!_isRecording) return;
    try {
      _isRecording = false;
      notifyListeners();

      final transcript = await _voiceService.stopAndTranscribe();
      if (transcript.trim().isEmpty) return;

      // Send the transcribed text into the normal chat flow
      _messages.add(ChatMessage(
        text: transcript,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      notifyListeners();

      String answer = '';
      try {
        answer = await _apiService.askQuestion(transcript);
        _messages.add(ChatMessage(
          text: answer,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } catch (e) {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } finally {
        _isLoading = false;
        notifyListeners();
      }

      // Speak the answer back
      if (answer.isNotEmpty) {
        _isSpeaking = true;
        notifyListeners();
        try {
          await _voiceService.speakAnswer(answer);
        } finally {
          _isSpeaking = false;
          notifyListeners();
        }
      }
    } catch (e) {
      _isRecording = false;
      _isLoading = false;
      notifyListeners();
      debugPrint('Voice stop error: $e');
    }
  }

  // ─── Misc ───────────────────────────────────────────────────────────────

  Future<void> retryHealthCheck() async {
    await _checkHealth();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
