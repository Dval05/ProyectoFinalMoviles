import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/remote/chatbot_datasource.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  ChatbotRepositoryImpl(this.remoteDataSource);

  final ChatbotDataSource remoteDataSource;

  @override
  Future<ChatMessage> enviarMensaje(
    String mensaje,
    Map<String, dynamic> contexto,
  ) async {
    try {
      final data = await remoteDataSource.enviarMensaje(mensaje, contexto);

      return ChatMessage(
        text: data['text'] ?? '',
        isUser: false,
        timestamp: DateTime.now(),
        action: data['action'],
        actionData: data['action_data'],
      );
    } catch (e) {
      // Retornar un mensaje de error como si fuera del bot si falla
      return ChatMessage(
        text: 'Error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<ChatMessage> enviarAudio(
    String filePath,
    Map<String, dynamic> contexto,
  ) async {
    try {
      final data = await remoteDataSource.enviarAudio(filePath, contexto);

      return ChatMessage(
        text: data['text'] ?? '',
        isUser: false,
        timestamp: DateTime.now(),
        action: data['action'],
        actionData: data['action_data'],
      );
    } catch (e) {
      return ChatMessage(
        text: 'Error de Audio: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }
}
