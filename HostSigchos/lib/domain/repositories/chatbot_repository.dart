import '../entities/chat_message.dart';

// ignore: one_member_abstracts, reason: Clean architecture interfaces can have a single method.
abstract class ChatbotRepository {
  Future<ChatMessage> enviarMensaje(String mensaje, Map<String, dynamic> contexto);
  Future<ChatMessage> enviarAudio(String filePath, Map<String, dynamic> contexto);
}
