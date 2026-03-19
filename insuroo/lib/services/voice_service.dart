import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceService {
  static const String _baseUrl = 'http://127.0.0.1:8000';

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  // ─── Recording ───────────────────────────────────────────────────────────

  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice_input.wav';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav),
      path: path,
    );

    _isRecording = true;
  }

  /// Stops recording, uploads WAV to backend, returns the transcribed text.
  Future<String> stopAndTranscribe() async {
    final path = await _recorder.stop();
    _isRecording = false;

    if (path == null) throw Exception('Recording path was null');

    final file = File(path);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/voice/transcribe'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path,
          filename: 'audio.wav'),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Transcription failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['text'] as String? ?? '';
  }

  // ─── Playback ────────────────────────────────────────────────────────────

  /// POST text to /voice/speak, receive WAV bytes, play via audioplayers.
  Future<void> speakAnswer(String text) async {
    if (text.trim().isEmpty) return;

    // Split into 450-char chunks to match backend limit per request
    final chunks = <String>[];
    for (var i = 0; i < text.length; i += 450) {
      chunks.add(text.substring(i, (i + 450).clamp(0, text.length)));
    }

    for (final chunk in chunks) {
      final response = await http.post(
        Uri.parse('$_baseUrl/voice/speak'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': chunk}),
      );

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) continue;

      // Write WAV bytes to a temp file for audioplayers to play
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/tts_output.wav';
      await File(path).writeAsBytes(response.bodyBytes);

      await _player.play(DeviceFileSource(path));

      // Wait for playback to finish before next chunk
      await _player.onPlayerComplete.first;
    }
  }

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
