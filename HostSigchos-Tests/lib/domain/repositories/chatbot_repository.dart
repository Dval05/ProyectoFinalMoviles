import '../entities/chat_message.dart';

abstract class ChatbotRepository {
  Future<ChatMessage> enviarMensaje(
    String mensaje,
    Map<String, dynamic> contexto,
  );
  Future<ChatMessage> enviarAudio(
    String filePath,
    Map<String, dynamic> contexto,
  );
}
