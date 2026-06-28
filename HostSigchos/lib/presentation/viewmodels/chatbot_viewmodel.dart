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
    // Añadir mensaje de bienvenida
    _messages.add(
      ChatMessage(
        text:
            '¡Hola! Soy tu asistente virtual de HostSigchos. ¿En qué te puedo ayudar hoy con tus reservas?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    _initTts();
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
    if (_messages.isNotEmpty) {
      await flutterTts.speak(_messages.first.text);
    }
  }

  final EnviarMensajeUseCase enviarMensajeUseCase;
  final EnviarAudioUseCase enviarAudioUseCase;

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
    await flutterTts.speak(botResponse.text);
  }

  Future<void> sendAudioMessage(
    String filePath, {
    Map<String, dynamic> contexto = const {},
  }) async {
    // Agregar mensaje "visual" del usuario
    final userMessage = ChatMessage(
      text: '🎵 Mensaje de voz',
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
    await flutterTts.speak(botResponse.text);
  }
}
