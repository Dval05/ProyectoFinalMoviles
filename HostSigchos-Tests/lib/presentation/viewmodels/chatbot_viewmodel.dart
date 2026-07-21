import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/chatbot/enviar_audio_usecase.dart';
import '../../domain/usecases/chatbot/enviar_mensaje_usecase.dart';

class ChatbotViewModel extends ChangeNotifier {
  ChatbotViewModel({
    required this.enviarMensajeUseCase,
    required this.enviarAudioUseCase,
  }) {
    _messages.add(
      ChatMessage(
        text: '¡Hola! Soy tu asistente virtual. ¿Prefieres comunicarte solo por texto o también con audio? Puedes activar el volumen arriba. ¿En qué te ayudo hoy?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    _initTts();
  }

  void updateLanguage(String languageCode, String welcomeMessage) {
    flutterTts.setLanguage(languageCode == 'en' ? 'en-US' : 'es-US');
    if (_messages.length == 1 && !_messages[0].isUser) {
      _messages[0] = ChatMessage(
        text: welcomeMessage,
        isUser: _messages[0].isUser,
        timestamp: _messages[0].timestamp,
        action: _messages[0].action,
        actionData: _messages[0].actionData,
      );
      notifyListeners();
    }
  }

  final FlutterTts flutterTts = FlutterTts();

  Future<void> _initTts() async {
    await flutterTts.setLanguage(
      'es-US',
    ); // Preferible para español latino/neutro
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1);
    await flutterTts.setPitch(1);

    // Hablar el mensaje inicial
    if (_messages.isNotEmpty && _isAudioEnabled) {
      await flutterTts.speak(_messages.first.text);
    }
  }

  final EnviarMensajeUseCase enviarMensajeUseCase;
  final EnviarAudioUseCase enviarAudioUseCase;

  bool _isAudioEnabled = true;
  bool get isAudioEnabled => _isAudioEnabled;

  void toggleAudio() {
    _isAudioEnabled = !_isAudioEnabled;
    notifyListeners();
  }

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(
    String text, {
    Map<String, dynamic> contexto = const {},
  }) async {
    if (text.trim().isEmpty) return;

    // Agregar mensaje del usuario
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.insert(0, userMessage);
    _isLoading = true;
    notifyListeners();

    // Obtener respuesta del bot
    final botResponse = await enviarMensajeUseCase.execute(text, contexto);

    _messages.insert(0, botResponse);
    _isLoading = false;
    notifyListeners();

    // Leer respuesta del bot en voz alta
    if (_isAudioEnabled) {
      await flutterTts.speak(botResponse.text);
    }
  }

  Future<void> sendAudioMessage(
    String filePath, {
    required String voiceMessageLabel,
    Map<String, dynamic> contexto = const {},
  }) async {
    // Agregar mensaje "visual" del usuario
    final userMessage = ChatMessage(
      text: voiceMessageLabel,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.insert(0, userMessage);
    _isLoading = true;
    notifyListeners();

    // Obtener respuesta del bot a partir del audio
    final botResponse = await enviarAudioUseCase.execute(filePath, contexto);

    _messages.insert(0, botResponse);
    _isLoading = false;
    notifyListeners();

    // Leer respuesta del bot en voz alta
    if (_isAudioEnabled) {
      await flutterTts.speak(botResponse.text);
    }
  }
}
